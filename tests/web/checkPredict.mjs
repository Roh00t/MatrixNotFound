// Check that the browser model (dashboard/predict.js) reproduces MATLAB.
//
//   node tests/web/checkPredict.mjs
//
// model_check.json is written by src/exportModelForWeb.m (via
// tools/buildSimulator.m). It holds 500 encoded test rows with MATLAB's
// predict() output, and building scenarios run through the full MATLAB
// pipeline. Exits non-zero if any prediction differs by more than 1e-6.
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import vm from "node:vm";

const root = fileURLToPath(new URL("../../", import.meta.url));
const require = createRequire(import.meta.url);
const { create } = require(root + "dashboard/predict.js");

const sandbox = { window: {} };
vm.runInNewContext(readFileSync(root + "dashboard/model.js", "utf8"), sandbox);
const model = create(sandbox.window.EUI_MODEL);
const check = JSON.parse(readFileSync(root + "tests/web/model_check.json", "utf8"));

const tolerance = 1e-6;
let worst = 0;

check.X.forEach((x, i) => {
  worst = Math.max(worst, Math.abs(model.predictVector(x) - check.expected[i]));
});
console.log(`Tree walk: ${check.X.length} test rows, max |JS - MATLAB| = ${worst.toExponential(2)}`);

let worstScenario = 0;
for (const s of check.scenarios) {
  const got = model.predict({ state: s.state, facility: s.facility, buildingClass: s.buildingClass,
    yearBuilt: s.yearBuilt, floorArea: s.floorArea, energyStar: s.energyStar }).eui;
  worstScenario = Math.max(worstScenario, Math.abs(got - s.expected));
}
console.log(`Full pipeline: ${check.scenarios.length} scenarios, max |JS - MATLAB| = ${worstScenario.toExponential(2)}`);

for (const b of model.buildings) {
  const r = model.predict({ state: b.state, facility: b.facility, yearBuilt: b.yearBuilt,
    floorArea: b.floorArea, energyStar: null });
  console.log(`${b.name}: JS ${r.eui.toFixed(3)} vs MATLAB ${b.matlabEUI.toFixed(3)} kBtu/ft²/yr, ` +
              `${r.annualMWh.toFixed(0)} MWh/yr, ${r.averageKW.toFixed(0)} kW average`);
  worstScenario = Math.max(worstScenario, Math.abs(r.eui - b.matlabEUI));
}

if (worst > tolerance || worstScenario > tolerance) {
  console.error("FAIL: browser model does not match MATLAB");
  process.exit(1);
}
console.log("PASS: browser model matches MATLAB");
