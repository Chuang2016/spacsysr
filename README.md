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

## Installation (on your Mac)

```r
# from the local source tarball:
install.packages("~/Downloads/spacsysr_0.1.0.tar.gz", repos = NULL, type = "source")
```

Requires R >= 4.0. No other packages needed.

> ⚠️ 打包前请把 `DESCRIPTION` 中的 `email = "qingfeng@example.com"`
> 换成你自己的邮箱（R 包构建要求维护者邮箱有效）。

## Quick start

```r
library(spacsysr)

# N2O-relevant example: simplified denitrification rate
denitrif_simplified(no3 = 8, kdeni = 0.5, f_temp = f_temp_q10(22),
                    f_water = f_water_denitrif(theta = 38, theta_s = 45,
                                               delta_theta = 10),
                    n_half = 5)

# Run the coupled daily driver on the bundled paddy example
weather <- load_example("paddy_weather")
soil    <- load_example("paddy_soil")
out <- spacsys_run(weather, soil, method = "simplified")
head(out)
plot(out$date, out$n2o, type = "l")
```

See `vignettes/n2o-paddy.Rmd` for a full worked N2O example.

## Citation / licence note

Equations are implemented from the SPACSYS technical manual
(Wu, 2022). The manual asks that the documentation not be reproduced
without written permission from Rothamsted Research; equations as
implemented here are intended for research use. If you plan to
redistribute this package beyond personal research, please verify
licensing with Rothamsted Research first.

## Roadmap

- Richards-equation soil water & heat transport (manual ch. 5-6)
- Farquhar C3/C4 photosynthesis and canopy integration (manual
  ch. 2.2)
- Full P cycling, 3-D roots, ruminant module
- Parameter calibration helpers against field N2O chamber data
