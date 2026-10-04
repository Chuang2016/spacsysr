# spacsysr 0.3.0

- New: simplified ("lite") daily integrated model `spacsys_lite_run()`
  coupling soil water, C/N cycling and crop growth with water/nitrogen
  stress responses -- few parameters, minimal inputs.
- New `R/weather.R`: Hargreaves / Priestley-Taylor PET, solar radiation
  estimation, thermal time, daylength, `weather_complete()`.
- New `R/plant_lite.R`: thermal-time phenology (Dindex 0-3), RUE-based
  growth co-limited by temperature/water/nitrogen, stage-dependent
  partitioning, senescence litter return, root elongation
  (wheat/rice/maize/generic parameter sets).
- New `R/soilcn_lite.R`: two-pool (litter+humus) decomposition with C:N
  stoichiometric mineralisation/immobilisation + simplified
  nitrification/denitrification.
- New `R/driver_lite.R`: `soil_init()` minimal-input soil builder,
  `root_weights()`, integrated daily driver.
- New parameter `up_frac_max` in `spacsys_default_params()` (max daily
  fraction of root-zone mineral N available for uptake).
- New vignette `lite-wheat` demonstrating water x nitrogen response.

# spacsysr 0.2.0

- New: Farquhar C3 / Yin & Struik C4 leaf photosynthesis + canopy
  sun/shade integration (manual ch. 2.2).
- New: 1-D Richards equation solver (Brooks-Corey / van Genuchten,
  Picard + Thomas), soil heat conduction, annual-wave lower BC
  (manual ch. 6-7).
- Note: manual eq. 301 (VG-Mualem) as printed differs from the standard
  Mualem form and is flagged "check against code"; the standard form is
  implemented.

# spacsysr 0.1.0

- First release: core SPACSYS soil biogeochemistry modules in pure base R.
- Response functions (Q10, moisture, WFPS, pH, Michaelis-Menten, inhibitor).
- SOM decomposition; simplified + microbiological nitrification/denitrification.
- N2O/NO emissions, NH3 volatilisation, CH4 production/oxidation.
- Plant respiration, tipping-bucket water balance, daily driver `spacsys_run()`.
- Bundled paddy example data and N2O vignette.
