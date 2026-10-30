/*
 * predict.js: run the exported MATLAB model (LSBoost v3) in the browser.
 *
 * window.EUI_MODEL comes from dashboard/model.js, written by
 * src/exportModelForWeb.m. The functions here mirror the MATLAB pipeline:
 *   encode()  = preprocessData + engineerLegacyFeatures for one building
 *   predict() = predict(finalModel, X), followed by the clamp at 0
 *               that writeSubmission applies
 * tests/web/checkPredict.mjs checks both against MATLAB's own output.
 *
 * Works as a browser script (attaches window.EUIPredict) and as a Node
 * module (module.exports) for the test.
 */
(function (root) {
  "use strict";

  const KWH_PER_KBTU = 0.29307107;
  const HOURS_PER_YEAR = 8760;

  // jsonencode writes 1-element arrays as scalars; normalise them.
  const arr = (v) => (v === undefined || v === null) ? [] : (Array.isArray(v) ? v : [v]);
  const rows = (v) => (Array.isArray(v) && Array.isArray(v[0])) ? v : [arr(v)];

  function create(model) {
    const predictors = arr(model.predictors);
    const isCat = arr(model.isCategorical);
    const levels = arr(model.levels).map(arr);
    const index = Object.fromEntries(predictors.map((p, i) => [p, i]));
    const weights = arr(model.weights);
    const states = arr(model.states);
    const baselines = rows(model.baselines);
    const reference = arr(model.reference);
    const referenceByType = Object.fromEntries(reference.map((r) => [r.facility, r]));

    // Prepare trees once: categorical split sets as Sets keyed by node.
    const trees = arr(model.trees).map((t) => {
      const catNodes = arr(t.catNodes);
      const toSet = (s) => new Set(String(s).split(",").map(Number));
      const leftSets = new Map(), rightSets = new Map();
      arr(t.catLeft).forEach((s, k) => leftSets.set(catNodes[k], toSet(s)));
      arr(t.catRight).forEach((s, k) => rightSets.set(catNodes[k], toSet(s)));
      return { cutVar: arr(t.cutVar), cutPoint: arr(t.cutPoint), left: arr(t.left),
               right: arr(t.right), value: arr(t.value), leftSets, rightSets };
    });

    const code = (name, level) => {
      const j = index[name];
      const k = levels[j].indexOf(String(level));
      if (k < 0) throw new Error(`Unknown level "${level}" for ${name}`);
      return k + 1;                                       // MATLAB codes are 1-based
    };
    const set = (x, name, value) => { if (name in index) x[index[name]] = value; };

    /** One building's predictor vector, built like the MATLAB pipeline. */
    function encode(inputs) {
      const s = states.findIndex((st) => st.name === inputs.state);
      if (s < 0) throw new Error(`Unknown climate state ${inputs.state}`);
      const x = baselines[s].slice();
      const area = Number(inputs.floorArea), yearBuilt = Number(inputs.yearBuilt);
      const ratingKnown = inputs.energyStar !== null && inputs.energyStar !== undefined &&
                          !Number.isNaN(Number(inputs.energyStar));
      const ref = referenceByType[inputs.facility];
      const rating = ratingKnown ? Number(inputs.energyStar) : ref.energyStarMedian;

      set(x, "facility_type", code("facility_type", inputs.facility));
      set(x, "building_class", code("building_class", inputs.buildingClass || "Commercial"));
      set(x, "floor_area", area);
      set(x, "year_built", yearBuilt);
      set(x, "energy_star_rating", rating);
      if ("energy_star_rating_missing" in index) {
        set(x, "energy_star_rating_missing", code("energy_star_rating_missing", ratingKnown ? "false" : "true"));
      }
      // Engineered features (src/engineerLegacyFeatures.m).
      const hdd = x[index.heating_degree_days], cdd = x[index.cooling_degree_days];
      set(x, "building_age", Math.min(Math.max(model.measurementYear - yearBuilt, 0), model.maxAge));
      set(x, "floor_area_x_hdd", area * hdd);
      set(x, "floor_area_x_cdd", area * cdd);
      set(x, "energy_star_x_floor_area", rating * area);
      return x;
    }

    /** Ensemble prediction for an encoded vector (MATLAB tree semantics). */
    function predictVector(x) {
      let total = 0;
      for (let t = 0; t < trees.length; t++) {
        const tree = trees[t];
        let node = 1;                                     // 1-based, as exported
        while (tree.left[node - 1] > 0) {
          const v = tree.cutVar[node - 1] - 1, value = x[v];
          let next;
          if (isCat[v]) {
            if (tree.leftSets.get(node).has(value)) next = tree.left[node - 1];
            else if (tree.rightSets.get(node).has(value)) next = tree.right[node - 1];
            else break;                                   // level unseen at this node: stop here
          } else {
            next = value < tree.cutPoint[node - 1] ? tree.left[node - 1] : tree.right[node - 1];
          }
          node = next;
        }
        total += weights[t] * tree.value[node - 1];
      }
      return total;
    }

    /** Full prediction for a building description, with derived quantities. */
    function predict(inputs) {
      const eui = Math.max(predictVector(encode(inputs)), 0);
      const kwh = eui * Number(inputs.floorArea) * KWH_PER_KBTU;
      const ref = referenceByType[inputs.facility];
      const pct = arr(ref.euiPercentiles);
      let percentile = 0;
      while (percentile < pct.length - 1 && pct[percentile + 1] <= eui) percentile++;
      return {
        eui,                                              // kBtu per sq ft per year
        annualMWh: kwh / 1000,
        averageKW: kwh / HOURS_PER_YEAR,                  // average power draw, all site energy
        peerMedianEUI: pct[10],
        peerPercentile: percentile * 5,
        peerCount: ref.count
      };
    }

    return { encode, predictVector, predict, states, reference, buildings: arr(model.buildings),
             facilities: reference.map((r) => r.facility), nTrees: trees.length };
  }

  const api = { create };
  if (typeof module !== "undefined" && module.exports) module.exports = api;
  else root.EUIPredict = api;
})(typeof window !== "undefined" ? window : globalThis);
