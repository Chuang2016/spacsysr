# spacsysr

R implementation of the core biogeochemical process modules of the
**SPACSYS** (Soil-Plant-Atmosphere Continuum System) model,
following the technical manual *Wu, L. (2022). SPACSYS - FARMSYS:
Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical
Manual. Rothamsted Research, North Wyke, UK.*

## Scope — please read

SPACSYS is a large, farm-scale process model (originally Fortran/C++
with an MS SQL Server database) covering 3-D root architecture,
ruminant animals, full farm management and more. **This package does
not port all of SPACSYS.** It faithfully implements the
well-documented *soil biogeochemistry core* as standalone R
functions, exactly per the manual's equations (equation numbers and
manual page references are given in every help page):

- Response functions: Q10 temperature (eq. 39), soil-moisture
  decomposition response (eq. 175-176), WFPS (eq. 190),
  Michaelis-Menten substrate response (eq. 192), nitrifier pH
  response (eq. 191), denitrifier pH responses (eq. 199),
  nitrification-inhibitor decay (eq. 184)
- Soil organic matter decomposition (eq. 174)
- Nitrification — simplified (eq. 182-184) and microbiological,
  Blagodatsky & Richter style nitrifier biomass dynamics
  (eq. 187-188, 193)
- Denitrification — simplified (eq. 185-186) and microbiological
  4-step sequential reduction NO3- -> NO2- -> NO -> N2O -> N2 with
  competitive Michaelis-Menten kinetics and denitrifier biomass
  (eq. 194-198)
- N gaseous emissions: nitrification-sourced NO/N2O (eq. 200-201),
  diffusion-driven emission with Penman diffusivity (eq. 202-203)
- Ammonia volatilisation at and after slurry spreading
  (eq. 204-209)
- Methane oxidation (eq. 210-212) and production (eq. 213)
- Plant maintenance and growth respiration (eq. 39-41)
- A tipping-bucket soil water balance (simplified stand-in; the
  manual's full water module is on the roadmap)
- `spacsys_run()`: a simplified daily driver coupling the modules
  across soil layers — a teaching/research scaffold, not a full
  SPACSYS simulation

Pure base R. Zero dependencies. Installs anywhere.

## Installation

```r
# from the source tarball (pure base R, zero dependencies):
install.packages("spacsysr_0.4.0.tar.gz", repos = NULL, type = "source")
# or from GitHub (private repo, needs access):
# remotes::install_github("Chuang2016/spacsysr")
```

Requires R >= 4.0. No other packages needed.

## Quick start — the lite integrated model

Minimal inputs: daily Tmax/Tmin/precipitation, layered soil properties,
a crop type. Everything else (radiation, PET, thermal time) is estimated.

```r
library(spacsysr)

weather <- data.frame(
  date   = seq(as.Date("2026-05-01"), by = "day", length.out = 120),
  tmax   = rnorm(120, 26, 3), tmin = rnorm(120, 16, 2),
  precip = pmax(0, rnorm(120, 3, 5))
)
soil <- soil_init(depth_mm = c(200, 300, 500),
                  soc = c(2000, 1200, 600))

out <- spacsys_lite_run(weather, soil,
                        crop = crop_default_params("maize"),
                        lat_deg = 38)
tail(out$w_grain, 1) / 100   # grain yield, t/ha
plot(out$date, out$lai, type = "l")  # canopy development
```

Add fertiliser and get the GHG footprint in one line each:

```r
n_inputs <- data.frame(date = as.Date(c("2026-05-10", "2026-06-20")),
                       nh4_add = c(7, 5), no3_add = c(0, 0))
out <- spacsys_lite_run(weather, soil, crop_default_params("maize"),
                        n_inputs = n_inputs, lat_deg = 38)
ghg_footprint(out)   # seasonal CO2/CH4/N2O, CO2-eq, kg CO2-eq per t grain
```

## Tutorial

A full step-by-step tutorial is in `vignettes/tutorial.Rmd`
(and rendered with the package vignettes):

1. **What this package is** — two ways to use it: standalone process
   functions (77 total, each mapped to manual equation numbers) vs.
   the coupled `spacsys_lite_run()` driver.
2. **Inputs** — `weather_complete()` (Hargreaves PET/radiation from
   Tmax/Tmin only), `soil_init()`, `crop_default_params()`
   (wheat/rice/maize/generic).
3. **Scenarios** — fertiliser schedules (`n_inputs`), irrigation
   (`irrig` column), drought × nitrogen factorials.
4. **Outputs** — 30 daily columns: phenology, LAI, biomass, stress
   factors `f_t/f_w/f_n`, N2O/NO, CH4, CO2 (heterotrophic +
   autotrophic), leaching, mineralisation...
5. **GHG & carbon footprint** — `ghg_footprint()` sums the season into
   kg/ha CO2-eq (IPCC AR6 GWP100) and yield-scaled intensity.
6. **Build your own** — every process is a standalone function
   (`soil_water_step()`, `soilcn_lite_step()`, `plant_growth_step()`,
   `ch4_lite_step()`, ...); the lite driver is just one way to wire
   them together.

Worked case vignettes: `lite-wheat` (water × nitrogen),
`lite-rice` (flooded vs rainfed, yield vs N2O trade-off),
`lite-maize` (drought × nitrogen interaction), `n2o-paddy`.

## Module map

| Module | Key functions | Manual |
|---|---|---|
| Weather / PET | `weather_complete` (measured rad > sunshine Angstrom-Prescott > Hargreaves), `pet_hargreaves`, `pet_priestley_taylor`, `thermal_time` | ch. 1 |
| Soil water | `soil_water_step` (bucket), `soilwater_richards` (1-D Richards, VG/BC) | ch. 5 |
| Soil heat | `soil_heat_step` | ch. 6 |
| Soil C/N | `soilcn_lite_step`, `decompose_*`, `nitrif_*`, `denitrif_*` | ch. 4 |
| Gaseous N | `gaseous_*`, `volatilization` (NH3) | ch. 4 |
| Methane | `ch4_lite_step`, `ch4_plant_transport`, `ch4_ebullition`, `ch4_production`, `ch4_oxidation_*` | p. 65-67 |
| CO2 / GHG | `co2_autotrophic`, `root_respiration`, `ghg_co2eq`, `ghg_footprint` | p. 26, 57 |
| Plant growth (lite) | `plant_growth_step`, `phenology_step`, `crop_default_params` | ch. 2 |
| Photosynthesis | `farquhar_c3`, `yin_struik_c4`, canopy sun/shade integration | ch. 2.2 |
| Drivers | `spacsys_lite_run` (lite), `spacsys_run` (full biogeochemistry) | — |

## Citation / licence note

Equations are implemented from the SPACSYS technical manual
(Wu, 2022). The manual asks that the documentation not be reproduced
without written permission from Rothamsted Research; equations as
implemented here are intended for research use. If you plan to
redistribute this package beyond personal research, please verify
licensing with Rothamsted Research first.

## Roadmap

- Parameter calibration helpers against field GHG chamber data
- Full P cycling, 3-D roots, ruminant module
- Ponded-water layer for paddy CH4
