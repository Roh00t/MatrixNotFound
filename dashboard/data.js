window.DASHBOARD = {
  "status": "complete",
  "stage": "All steps complete",
  "step": 6,
  "totalSteps": 6,
  "data": {
    "trainRows": 75757,
    "testRows": 9705,
    "predictors": 62
  },
  "years": [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6"
  ],
  "modelTable": [
    {
      "Model": "Regression tree (baseline)",
      "LOYO_RMSE": 61.022223472396092,
      "CV_Runtime_min": 1.2500342229166668
    },
    {
      "Model": "LSBoost v1 (initial)",
      "LOYO_RMSE": 41.056059853939963,
      "CV_Runtime_min": 9.1465501909722224
    },
    {
      "Model": "LSBoost v2 (shrinkage)",
      "LOYO_RMSE": 41.848673686602034,
      "CV_Runtime_min": 3.924975392361111
    },
    {
      "Model": "LSBoost v3 (feature selection)",
      "LOYO_RMSE": 40.122702074480131,
      "CV_Runtime_min": 6.8515921493055556
    }
  ],
  "perYear": [
    [
      67.74791066485956,
      70.0569457528977,
      54.829691171087312,
      73.430744672533763,
      50.274347592583709,
      59.374174891229117
    ],
    [
      54.77788499361079,
      41.918829674687565,
      46.957946735879794,
      37.788516856660081,
      37.001935649125066,
      41.080749509684075
    ],
    [
      56.296075253914069,
      43.062385687378985,
      47.193053352980876,
      39.269097856152385,
      36.42256603367322,
      42.572729421412035
    ],
    [
      54.479587797595734,
      41.872789814728428,
      46.249150938489855,
      37.079656294605869,
      33.384032844345683,
      41.314206649994766
    ]
  ],
  "headline": {
    "bestModel": "LSBoost v3 (feature selection)",
    "bestRMSE": 40.122702074480131,
    "baselineRMSE": 61.022223472396092,
    "improvementPct": 34.249032907445645,
    "kfoldRMSE": 50.28737344607358,
    "kfoldOptimism": 10.734850026322512,
    "oofRMSE": 40.122702074480131,
    "radarBuildings": 22449,
    "radarFlagged": 1316,
    "radarFlaggedPct": 5.8621764889304639,
    "shortlistGWh": 1572.81114698548
  },
  "validationGap": [
    {
      "Scheme": "Random 5-fold",
      "Tree_RMSE": 50.28737344607358
    },
    {
      "Scheme": "Leave-one-year-out",
      "Tree_RMSE": 61.022223472396092
    }
  ],
  "radarByState": [
    {
      "state": "State_1",
      "buildings": 1036,
      "flaggedPct": 13.127413127413126,
      "excessGWh": 201.55916410052893
    },
    {
      "state": "State_10",
      "buildings": 4,
      "flaggedPct": 0,
      "excessGWh": 0.51707702745965589
    },
    {
      "state": "State_11",
      "buildings": 3221,
      "flaggedPct": 8.7860912760012422,
      "excessGWh": 771.33691900503993
    },
    {
      "state": "State_2",
      "buildings": 1401,
      "flaggedPct": 2.9978586723768736,
      "excessGWh": 469.46580875576274
    },
    {
      "state": "State_4",
      "buildings": 2612,
      "flaggedPct": 4.1730474732006124,
      "excessGWh": 1531.3291331511844
    },
    {
      "state": "State_6",
      "buildings": 13017,
      "flaggedPct": 5.0165168625643384,
      "excessGWh": 5341.0744169724994
    },
    {
      "state": "State_8",
      "buildings": 1158,
      "flaggedPct": 8.0310880829015545,
      "excessGWh": 522.9649870381935
    }
  ],
  "shortlist": [
    {
      "rank": 1,
      "train_id": 72672,
      "facility_type": "Mixed_Use_Commercial_and_Residential",
      "State_Factor": "State_11",
      "floor_area": 494835,
      "year_built": 1992,
      "actual_eui": 903.66757470000027,
      "expected_eui": 89.451211361218114,
      "excess_pct": 910.23514488903663,
      "excess_MWh_per_year": 118079.14126549229
    },
    {
      "rank": 2,
      "train_id": 63948,
      "facility_type": "Public_Assembly_Other",
      "State_Factor": "State_6",
      "floor_area": 631216,
      "year_built": 1956,
      "actual_eui": 648.12431689999983,
      "expected_eui": 107.11077834549164,
      "excess_pct": 505.09719648328905,
      "excess_MWh_per_year": 100082.71586267369
    },
    {
      "rank": 3,
      "train_id": 9527,
      "facility_type": "Education_College_or_university",
      "State_Factor": "State_2",
      "floor_area": 420653,
      "year_built": 1973,
      "actual_eui": 933.4271756,
      "expected_eui": 286.54895133291888,
      "excess_pct": 225.74789447249583,
      "excess_MWh_per_year": 79747.939789729149
    },
    {
      "rank": 4,
      "train_id": 12698,
      "facility_type": "Education_College_or_university",
      "State_Factor": "State_4",
      "floor_area": 2.944091E+6,
      "year_built": 1896,
      "actual_eui": 167.9362814,
      "expected_eui": 97.361185924720246,
      "excess_pct": 72.487916827398237,
      "excess_MWh_per_year": 60894.161389290741
    },
    {
      "rank": 5,
      "train_id": 62698,
      "facility_type": "Industrial",
      "State_Factor": "State_6",
      "floor_area": 423196,
      "year_built": 1952,
      "actual_eui": 579.9112022,
      "expected_eui": 104.59749091259377,
      "excess_pct": 454.42171426903457,
      "excess_MWh_per_year": 58951.49817077865
    },
    {
      "rank": 6,
      "train_id": 62061,
      "facility_type": "Industrial",
      "State_Factor": "State_6",
      "floor_area": 1.546246E+6,
      "year_built": 1937,
      "actual_eui": 268.5642077,
      "expected_eui": 145.72564725222747,
      "excess_pct": 84.294400309067683,
      "excess_MWh_per_year": 55665.518330899751
    },
    {
      "rank": 7,
      "train_id": 73983,
      "facility_type": "Commercial_Other",
      "State_Factor": "State_11",
      "floor_area": 429405,
      "year_built": 1981,
      "actual_eui": 637.9592769,
      "expected_eui": 197.55243130246856,
      "excess_pct": 222.93162513562456,
      "excess_MWh_per_year": 55423.520403317736
    },
    {
      "rank": 8,
      "train_id": 9533,
      "facility_type": "Education_College_or_university",
      "State_Factor": "State_2",
      "floor_area": 1.047627E+6,
      "year_built": 1945,
      "actual_eui": 379.2928033,
      "expected_eui": 220.80778210161631,
      "excess_pct": 71.775106696850244,
      "excess_MWh_per_year": 48659.52385840036
    },
    {
      "rank": 9,
      "train_id": 60807,
      "facility_type": "Service_Vehicle_service_repair_shop",
      "State_Factor": "State_6",
      "floor_area": 247669,
      "year_built": 2009,
      "actual_eui": 679.8374317,
      "expected_eui": 51.436100978568504,
      "excess_pct": 1221.7126080051496,
      "excess_MWh_per_year": 45612.271066343455
    },
    {
      "rank": 10,
      "train_id": 61161,
      "facility_type": "Health_Care_Inpatient",
      "State_Factor": "State_6",
      "floor_area": 2.971874E+6,
      "year_built": 1932,
      "actual_eui": 358.9166667,
      "expected_eui": 308.68429794639525,
      "excess_pct": 16.273056027724447,
      "excess_MWh_per_year": 43750.900935689977
    },
    {
      "rank": 11,
      "train_id": 58018,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 177276,
      "year_built": 1913,
      "actual_eui": 819.8538251,
      "expected_eui": 99.05725852904763,
      "excess_pct": 727.65648603083969,
      "excess_MWh_per_year": 37448.601435458484
    },
    {
      "rank": 12,
      "train_id": 57239,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.702331E+6,
      "year_built": 1949,
      "actual_eui": 102.4193989,
      "expected_eui": 30.94988136363736,
      "excess_pct": 230.92016637043176,
      "excess_MWh_per_year": 35656.4258659353
    },
    {
      "rank": 13,
      "train_id": 56771,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.160832E+6,
      "year_built": 1930,
      "actual_eui": 234.1584699,
      "expected_eui": 134.90019155980985,
      "excess_pct": 73.579049215940245,
      "excess_MWh_per_year": 33768.289269066605
    },
    {
      "rank": 14,
      "train_id": 56254,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 2.577575E+6,
      "year_built": 1986,
      "actual_eui": 120.17076499999999,
      "expected_eui": 77.2161856356859,
      "excess_pct": 55.628983756046068,
      "excess_MWh_per_year": 32448.433196605507
    },
    {
      "rank": 15,
      "train_id": 60426,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 948747,
      "year_built": 1927,
      "actual_eui": 212.6174863,
      "expected_eui": 109.74080145191219,
      "excess_pct": 93.745155390693768,
      "excess_MWh_per_year": 28604.892925484364
    },
    {
      "rank": 16,
      "train_id": 58775,
      "facility_type": "Commercial_Other",
      "State_Factor": "State_6",
      "floor_area": 334751,
      "year_built": 2008,
      "actual_eui": 333.9849727,
      "expected_eui": 51.355292079595692,
      "excess_pct": 550.34188138265461,
      "excess_MWh_per_year": 27727.620460769969
    },
    {
      "rank": 17,
      "train_id": 56719,
      "facility_type": "Education_College_or_university",
      "State_Factor": "State_6",
      "floor_area": 723777,
      "year_built": 1983,
      "actual_eui": 178.7103825,
      "expected_eui": 52.57444614137745,
      "excess_pct": 239.91871644150393,
      "excess_MWh_per_year": 26755.715140844153
    },
    {
      "rank": 18,
      "train_id": 56621,
      "facility_type": "Health_Care_Outpatient_Clinic",
      "State_Factor": "State_6",
      "floor_area": 335800,
      "year_built": 1970,
      "actual_eui": 366.795082,
      "expected_eui": 99.476608082871948,
      "excess_pct": 268.72495862990263,
      "excess_MWh_per_year": 26307.683894801357
    },
    {
      "rank": 19,
      "train_id": 57281,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.51178E+6,
      "year_built": 1949,
      "actual_eui": 150.886612,
      "expected_eui": 93.197717397415332,
      "excess_pct": 61.899471589617036,
      "excess_MWh_per_year": 25559.582927129613
    },
    {
      "rank": 20,
      "train_id": 68720,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_8",
      "floor_area": 1.20549E+6,
      "year_built": 1948,
      "actual_eui": 192.82839019999997,
      "expected_eui": 120.81127708286924,
      "excess_pct": 59.61125058526725,
      "excess_MWh_per_year": 25443.231546331768
    },
    {
      "rank": 21,
      "train_id": 60794,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 466063,
      "year_built": 1937,
      "actual_eui": 278.0382514,
      "expected_eui": 91.914729006248848,
      "excess_pct": 202.4958615513053,
      "excess_MWh_per_year": 25422.5341422604
    },
    {
      "rank": 22,
      "train_id": 13141,
      "facility_type": "Public_Assembly_Entertainment_culture",
      "State_Factor": "State_4",
      "floor_area": 1.008416E+6,
      "year_built": 1892,
      "actual_eui": 248.7404905,
      "expected_eui": 163.92244320566525,
      "excess_pct": 51.7427910636482,
      "excess_MWh_per_year": 25066.918412672534
    },
    {
      "rank": 23,
      "train_id": 55001,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.640631E+6,
      "year_built": 1958,
      "actual_eui": 93.14480874,
      "expected_eui": 41.403691727218359,
      "excess_pct": 124.96739989677675,
      "excess_MWh_per_year": 24878.240595802898
    },
    {
      "rank": 24,
      "train_id": 56797,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 764915,
      "year_built": 2005,
      "actual_eui": 319.0259563,
      "expected_eui": 210.7910383769661,
      "excess_pct": 51.347020611698426,
      "excess_MWh_per_year": 24263.504008932679
    },
    {
      "rank": 25,
      "train_id": 9727,
      "facility_type": "Education_College_or_university",
      "State_Factor": "State_2",
      "floor_area": 2.199157E+6,
      "year_built": 1864,
      "actual_eui": 117.62048490000002,
      "expected_eui": 81.2760847714835,
      "excess_pct": 44.717213225394332,
      "excess_MWh_per_year": 23424.303707226038
    },
    {
      "rank": 26,
      "train_id": 54743,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.23395E+6,
      "year_built": 1948,
      "actual_eui": 107.00683059999999,
      "expected_eui": 42.825837455344605,
      "excess_pct": 149.8651210535655,
      "excess_MWh_per_year": 23210.096461238725
    },
    {
      "rank": 27,
      "train_id": 68584,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_8",
      "floor_area": 103000,
      "year_built": 1929,
      "actual_eui": 788.3309765,
      "expected_eui": 58.238603687032118,
      "excess_pct": 1253.6227288971495,
      "excess_MWh_per_year": 22038.80214861095
    },
    {
      "rank": 28,
      "train_id": 60327,
      "facility_type": "Office_Bank_or_other_financial",
      "State_Factor": "State_6",
      "floor_area": 2.212675E+6,
      "year_built": 2008,
      "actual_eui": 210.52322400000003,
      "expected_eui": 176.92931244608519,
      "excess_pct": 18.987193862606425,
      "excess_MWh_per_year": 21784.678420788794
    },
    {
      "rank": 29,
      "train_id": 63243,
      "facility_type": "Industrial",
      "State_Factor": "State_6",
      "floor_area": 1.129933E+6,
      "year_built": 1986,
      "actual_eui": 196.4617486,
      "expected_eui": 131.58822416014584,
      "excess_pct": 49.300402717572666,
      "excess_MWh_per_year": 21482.911300087013
    },
    {
      "rank": 30,
      "train_id": 55810,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.521E+6,
      "year_built": 1944,
      "actual_eui": 129.2459016,
      "expected_eui": 81.256253772446584,
      "excess_pct": 59.059636150524028,
      "excess_MWh_per_year": 21391.91808280901
    },
    {
      "rank": 31,
      "train_id": 55566,
      "facility_type": "Commercial_Other",
      "State_Factor": "State_6",
      "floor_area": 216000,
      "year_built": 1995,
      "actual_eui": 438.7978142,
      "expected_eui": 104.02524726719226,
      "excess_pct": 321.8185735939021,
      "excess_MWh_per_year": 21192.225349891232
    },
    {
      "rank": 32,
      "train_id": 61994,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.49767E+6,
      "year_built": 1959,
      "actual_eui": 114.9849727,
      "expected_eui": 66.877866954044322,
      "excess_pct": 71.9327752767786,
      "excess_MWh_per_year": 21115.351227129086
    },
    {
      "rank": 33,
      "train_id": 53372,
      "facility_type": "Data_Center",
      "State_Factor": "State_6",
      "floor_area": 133983,
      "year_built": 1980,
      "actual_eui": 829.6270492000001,
      "expected_eui": 294.64634538372115,
      "excess_pct": 181.56705901767347,
      "excess_MWh_per_year": 21006.841832525806
    },
    {
      "rank": 34,
      "train_id": 59035,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.249E+6,
      "year_built": 1940,
      "actual_eui": 132.2377049,
      "expected_eui": 75.667799826293148,
      "excess_pct": 74.760869489494354,
      "excess_MWh_per_year": 20707.174259577376
    },
    {
      "rank": 35,
      "train_id": 55000,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.476675E+6,
      "year_built": 1951,
      "actual_eui": 88.55737705,
      "expected_eui": 40.943164462099269,
      "excess_pct": 116.29343557940372,
      "excess_MWh_per_year": 20606.03717304254
    },
    {
      "rank": 36,
      "train_id": 59871,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 293739,
      "year_built": 1905,
      "actual_eui": 498.73360660000003,
      "expected_eui": 259.40435300792109,
      "excess_pct": 92.2610784348599,
      "excess_MWh_per_year": 20602.994581771491
    },
    {
      "rank": 37,
      "train_id": 58749,
      "facility_type": "Laboratory",
      "State_Factor": "State_6",
      "floor_area": 324505,
      "year_built": 1968,
      "actual_eui": 475.19808739999996,
      "expected_eui": 264.58185602071438,
      "excess_pct": 79.603429557466029,
      "excess_MWh_per_year": 20030.241259627408
    },
    {
      "rank": 38,
      "train_id": 64017,
      "facility_type": "Commercial_Other",
      "State_Factor": "State_6",
      "floor_area": 292219,
      "year_built": 1961,
      "actual_eui": 327.4030055,
      "expected_eui": 99.27168070854276,
      "excess_pct": 229.80503922487284,
      "excess_MWh_per_year": 19537.379958916885
    },
    {
      "rank": 39,
      "train_id": 60860,
      "facility_type": "Industrial",
      "State_Factor": "State_6",
      "floor_area": 550667,
      "year_built": 1994,
      "actual_eui": 212.91666669999998,
      "expected_eui": 92.29910320818486,
      "excess_pct": 130.68118681473717,
      "excess_MWh_per_year": 19465.813245104913
    },
    {
      "rank": 40,
      "train_id": 59036,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 2.462789E+6,
      "year_built": 1970,
      "actual_eui": 138.8196721,
      "expected_eui": 113.05769588243204,
      "excess_pct": 22.786574603782533,
      "excess_MWh_per_year": 18594.278441906914
    },
    {
      "rank": 41,
      "train_id": 64696,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 3.636683E+6,
      "year_built": 1972,
      "actual_eui": 108.1038251,
      "expected_eui": 91.455681953203722,
      "excess_pct": 18.20350883755351,
      "excess_MWh_per_year": 17743.700478353461
    },
    {
      "rank": 42,
      "train_id": 61252,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.125906E+6,
      "year_built": 1970,
      "actual_eui": 151.9836066,
      "expected_eui": 98.9169995284376,
      "excess_pct": 53.647610951145268,
      "excess_MWh_per_year": 17510.413602506957
    },
    {
      "rank": 43,
      "train_id": 61991,
      "facility_type": "Multifamily_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 1.261187E+6,
      "year_built": 1948,
      "actual_eui": 94.54098361,
      "expected_eui": 47.48677300414905,
      "excess_pct": 99.089088664204851,
      "excess_MWh_per_year": 17392.05609178849
    },
    {
      "rank": 44,
      "train_id": 65284,
      "facility_type": "Education_Other_classroom",
      "State_Factor": "State_6",
      "floor_area": 1.2192E+6,
      "year_built": 1970,
      "actual_eui": 84.76775956,
      "expected_eui": 36.327569391735068,
      "excess_pct": 133.3427778938759,
      "excess_MWh_per_year": 17308.273268921705
    },
    {
      "rank": 45,
      "train_id": 63861,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 324836,
      "year_built": 1976,
      "actual_eui": 554.2814208,
      "expected_eui": 373.58791309336812,
      "excess_pct": 48.367064718571996,
      "excess_MWh_per_year": 17202.028094329766
    },
    {
      "rank": 46,
      "train_id": 13378,
      "facility_type": "Office_Uncategorized",
      "State_Factor": "State_4",
      "floor_area": 3.193966E+6,
      "year_built": 1972,
      "actual_eui": 85.38632148,
      "expected_eui": 67.40864408057017,
      "excess_pct": 26.669691468563023,
      "excess_MWh_per_year": 16828.167325037753
    },
    {
      "rank": 47,
      "train_id": 57722,
      "facility_type": "Health_Care_Inpatient",
      "State_Factor": "State_6",
      "floor_area": 309327,
      "year_built": 1924,
      "actual_eui": 607.136612,
      "expected_eui": 421.79858398716237,
      "excess_pct": 43.939936037926216,
      "excess_MWh_per_year": 16801.780911093723
    },
    {
      "rank": 48,
      "train_id": 56873,
      "facility_type": "Service_Vehicle_service_repair_shop",
      "State_Factor": "State_6",
      "floor_area": 430887,
      "year_built": 2015,
      "actual_eui": 174.7213115,
      "expected_eui": 43.38181663875023,
      "excess_pct": 302.75240881437071,
      "excess_MWh_per_year": 16585.61893784699
    },
    {
      "rank": 49,
      "train_id": 61899,
      "facility_type": "Health_Care_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 3.032242E+6,
      "year_built": 1962,
      "actual_eui": 341.7636612,
      "expected_eui": 323.17567044822658,
      "excess_pct": 5.7516677310494675,
      "excess_MWh_per_year": 16518.448610923715
    },
    {
      "rank": 50,
      "train_id": 61165,
      "facility_type": "Health_Care_Uncategorized",
      "State_Factor": "State_6",
      "floor_area": 81767,
      "year_built": 1939,
      "actual_eui": 997.8661202,
      "expected_eui": 308.87168042905711,
      "excess_pct": 223.06818119869487,
      "excess_MWh_per_year": 16510.747319711863
    }
  ],
  "submission": {
    "rows": 9705,
    "min": 0,
    "median": 64.7506121658962,
    "max": 650.58623166143389,
    "binEdges": [
      0,
      25,
      50,
      75,
      100,
      125,
      150,
      175,
      200,
      225,
      250,
      275,
      300
    ],
    "binCounts": [
      659,
      2329,
      3184,
      2057,
      675,
      301,
      131,
      86,
      73,
      57,
      46,
      107
    ]
  },
  "crossCheck": {
    "models": [
      {
        "Model": "LSBoost",
        "OOF_RMSE": 41.8071226164257,
        "OOF_MAE": 21.2847331960394,
        "MeanFoldRMSE": 41.8036729773358,
        "StdFoldRMSE": 0.601387766038508,
        "TemporalRMSE": 45.0486833894659,
        "CVModelSeconds": 341.5817466
      },
      {
        "Model": "Bag",
        "OOF_RMSE": 42.2018150720528,
        "OOF_MAE": 20.9875914496292,
        "MeanFoldRMSE": 42.2007885400194,
        "StdFoldRMSE": 0.329780220577692,
        "TemporalRMSE": 41.5379423839299,
        "CVModelSeconds": 423.2202133
      },
      {
        "Model": "Tree",
        "OOF_RMSE": 45.2568651821475,
        "OOF_MAE": 23.3859436243568,
        "MeanFoldRMSE": 45.25593313284,
        "StdFoldRMSE": 0.325010516083806,
        "TemporalRMSE": 44.8910271457807,
        "CVModelSeconds": 3.3893216
      },
      {
        "Model": "Mean",
        "OOF_RMSE": 58.2553663381562,
        "OOF_MAE": 33.7889526370119,
        "MeanFoldRMSE": 58.2542403189206,
        "StdFoldRMSE": 0.404051625018644,
        "TemporalRMSE": 57.2063708846684,
        "CVModelSeconds": 0.1658319
      }
    ],
    "ourYear6": 41.314206649994766,
    "ourModel": "LSBoost v3 (feature selection)"
  },
  "metrics": [
    {
      "MAE": 21.037646716487409,
      "MSE": 1609.8312217574924,
      "RMSE": 40.122702074480131,
      "R2": 0.52563388165033331,
      "MedianAE": 12.56523535957654
    }
  ],
  "ntu": [
    {
      "name": "The Hive",
      "year_built": 2015,
      "floor_area": 140000,
      "predicted_eui": 109.43138194727418,
      "predicted_MWh_per_year": 4489.964107841286,
      "climate_state": "State_2",
      "us_university_median_eui": 90.798560625
    },
    {
      "name": "The Arc",
      "year_built": 2018,
      "floor_area": 120000,
      "predicted_eui": 102.20557225945507,
      "predicted_MWh_per_year": 3594.4195706448972,
      "climate_state": "State_2",
      "us_university_median_eui": 90.798560625
    }
  ],
  "updated": "2026-10-30 14:08:12"
};
