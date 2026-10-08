---
title: "Lite model: wheat growth under water x nitrogen stress"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Lite model: wheat growth under water x nitrogen stress}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



## Overview

This vignette demonstrates the simplified ("lite") integrated model
`spacsys_lite_run()`: daily coupling of soil water, soil C/N cycling
and RUE-based wheat growth, with growth co-limited by temperature,
water (transpiration ratio) and nitrogen (supply/demand). Inputs are
minimal -- daily Tmax/Tmin/precipitation, a few soil properties and
initial pools.

## Minimal inputs


``` r
set.seed(7)
n <- 180
weather <- data.frame(
  date   = seq(as.Date("2026-03-01"), by = "day", length.out = n),
  tmax   = 20 + 7 * sin(2 * pi * (1:n) / n) + rnorm(n, 0, 2),
  tmin   = 10 + 4 * sin(2 * pi * (1:n) / n) + rnorm(n, 0, 1.5),
  precip = pmax(0, rnorm(n, 2, 5))
)
# Only Tmax/Tmin/precip are required: radiation and PET are estimated.
# Add a `sunshine` column (h/d) when available for better radiation
# via Angstrom-Prescott (FAO56); PET then uses Priestley-Taylor.
w <- weather_complete(weather, lat_deg = 35, t_base = 2)
head(w[c("date", "tmax", "tmin", "precip", "rad", "pet")], 3)
#>         date     tmax     tmin   precip       rad      pet
#> 1 2026-03-01 24.81879 13.42839 3.013438 14.169510 3.069733
#> 2 2026-03-02 18.09475 13.76970 0.000000  8.807023 1.743074
#> 3 2026-03-03 19.34311 12.12042 1.716822 11.479132 2.258433

soil <- soil_init(depth_mm = c(200, 300, 500), soc = c(2500, 1500, 800))
soil
#>   depth_mm  fc   wp  sat bulk_density  ph theta_init c_litter c_humus nh4 no3
#> 1      200 0.3 0.12 0.45         1.35 6.5       0.21      125    2375   1   3
#> 2      300 0.3 0.12 0.45         1.35 6.5       0.21       75    1425   1   3
#> 3      500 0.3 0.12 0.45         1.35 6.5       0.21       40     760   1   3
#>   ch4_con
#> 1       0
#> 2       0
#> 3       0
```

## Water x nitrogen scenarios


``` r
fert <- data.frame(date = as.Date(c("2026-04-10", "2026-05-20")),
                   nh4_add = c(6, 4), no3_add = c(0, 0))
run_scenario <- function(w, fert_in = NULL) {
  out <- spacsys_lite_run(w, soil, crop_default_params("wheat"),
                          n_inputs = fert_in, lat_deg = 35)
  out$scenario <- deparse(substitute(w))
  out
}
w_dry <- weather; w_dry$precip <- weather$precip * 0.25

scenarios <- rbind(
  run_scenario(weather),
  run_scenario(weather, fert),
  run_scenario(w_dry, fert)
)
scenarios$scenario <- rep(c("rainfed", "rainfed + 100 kg N/ha",
                            "dry + 100 kg N/ha"), each = n)
```

## Growth and yield response


``` r
cols <- c("darkgreen", "steelblue", "firebrick")
matplot(scenarios$date[1:n],
        sapply(split(scenarios$lai, scenarios$scenario), identity),
        type = "l", lty = 1, col = cols, xlab = "Date", ylab = "LAI",
        main = "Canopy development")
legend("topleft", legend = levels(factor(scenarios$scenario)),
       col = cols, lty = 1, bty = "n")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

``` r

tapply(scenarios$w_grain, scenarios$scenario,
       function(x) round(tail(x, 1) / 100, 2))  # t/ha
#>     dry + 100 kg N/ha               rainfed rainfed + 100 kg N/ha 
#>                  0.59                  7.15                  7.15
```

## Stress diagnostics


``` r
agg <- aggregate(cbind(f_w, f_n) ~ scenario, data = scenarios,
                 FUN = function(x) round(sum(x < 0.9), 0))
names(agg)[2:3] <- c("water_stress_days", "N_stress_days")
agg
#>                scenario water_stress_days N_stress_days
#> 1     dry + 100 kg N/ha               143             0
#> 2               rainfed                12            16
#> 3 rainfed + 100 kg N/ha                12            16
tapply(scenarios$n_uptake, scenarios$scenario, sum)  # g N m-2, seasonal uptake
#>     dry + 100 kg N/ha               rainfed rainfed + 100 kg N/ha 
#>              17.20354              14.68463              24.68463
```

Water shortage cuts yield sharply through `f_w`; added fertiliser N is
taken up (luxury uptake when soil N already suffices) and only raises
yield once soil supply becomes limiting. All fluxes conserve mass --
see `?spacsys_lite_run` for the simplifications adopted.

> 提示：`weather` 加一列 `sunshine`（日照时数，h/d）即可让辐射
> 改用 Angstrom-Prescott 公式（FAO56）推算、PET 改用 Priestley-Taylor，
> 比纯温差法更准——中国气象站一般都有日照记录。
