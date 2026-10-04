# spacsysr 0.4.0

- New: methane module per manual eq. 210-215 -- `ch4_plant_transport()`
  (aerenchyma transport, eq. 214), `ch4_ebullition()` (simplified eq. 215)
  and `ch4_lite_step()` (daily layer CH4 balance: production from anoxic
  respiration, rhizospheric + soil methanotrophic oxidation, plant
  transport, ebullition, atmospheric diffusion). Kinetic parameters without
  manual defaults are illustrative literature-typical values.
- New: CO2 autotrophic respiration -- `root_respiration()`,
  `shoot_respiration()`, `co2_autotrophic()` (maintenance + growth
  respiration; anoxic fraction diverted to CH4).
- New: GHG aggregation -- `ghg_co2eq()` (IPCC AR6 GWP100 defaults) and
  `ghg_footprint()` (seasonal CO2/CH4/N2O budget + yield-scaled carbon
  footprint intensity from a `spacsys_lite_run()` output).
- `spacsys_lite_run()` now simulates soil CH4 and autotrophic CO2:
  new output columns `ch4` (g CH4 m-2 d-1), `co2_auto_c`,
  `co2_total_c` (g C m-2 d-1); `soil_init()` gains `ch4_init`.
- New vignette `tutorial`: full package usage tutorial.

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
