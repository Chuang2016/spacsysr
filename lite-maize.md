---
title: "Lite model: maize response to drought x nitrogen"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Lite model: maize response to drought x nitrogen}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



## Overview

This vignette runs a 2 x 2 factorial with the lite model on maize (C4,
higher RUE and deeper roots than wheat/rice): two water regimes
(normal vs. 40% precipitation) crossed with two N rates (0 vs.
120 kg N ha-1). It shows how drought and nitrogen limitation interact,
and reports water-use efficiency (grain per mm of seasonal ET).

## Minimal inputs


``` r
set.seed(42)
n <- 140
weather <- data.frame(
  date   = seq(as.Date("2026-05-15"), by = "day", length.out = n),
  tmax   = 29 + 5 * sin(2 * pi * (1:n) / n) + rnorm(n, 0, 2),
  tmin   = 18 + 3 * sin(2 * pi * (1:n) / n) + rnorm(n, 0, 1.5),
  precip = pmax(0, rnorm(n, 5, 7))  # normal: ~PET; dry = 40% of this
)
w <- weather_complete(weather, lat_deg = 38, t_base = 8)
w_dry <- w; w_dry$precip <- w$precip * 0.4

soil <- soil_init(depth_mm = c(200, 300, 500),
                  soc = c(1200, 700, 400),   # modest fertility
                  nh4_init = 0.3, no3_init = 0.5)
crop <- crop_default_params("maize")
fert <- data.frame(date = as.Date(c("2026-05-20", "2026-07-05")),
                   nh4_add = c(7, 5), no3_add = c(0, 0))
```

## Factorial scenarios


``` r
run <- function(w_in, fert_in) spacsys_lite_run(w_in, soil, crop,
                                                n_inputs = fert_in,
                                                lat_deg = 38)
scenarios <- rbind(
  cbind(run(w, fert),     water = "normal", N = "120 kg/ha"),
  cbind(run(w, NULL),     water = "normal", N = "0"),
  cbind(run(w_dry, fert), water = "dry",    N = "120 kg/ha"),
  cbind(run(w_dry, NULL), water = "dry",    N = "0")
)
```

## Yield response


``` r
yld <- tapply(scenarios$w_grain, list(scenarios$water, scenarios$N),
              function(x) round(tail(x, 1) / 100, 2))  # t/ha
yld
#>           0 120 kg/ha
#> dry    0.91      1.28
#> normal 2.22      3.36

cols <- c("steelblue", "skyblue", "firebrick", "salmon")
matplot(scenarios$date[1:n],
        sapply(split(scenarios$lai, interaction(scenarios$water,
                                                scenarios$N)), identity),
        type = "l", lty = 1, col = cols, xlab = "Date", ylab = "LAI",
        main = "Maize canopy: drought x nitrogen")
legend("topleft", legend = c("normal+N", "normal-N", "dry+N", "dry-N"),
       col = cols, lty = 1, bty = "n")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

## Stress days and water-use efficiency


``` r
stress <- aggregate(cbind(f_w, f_n) ~ water + N, data = scenarios,
                    FUN = function(x) sum(x < 0.9))
names(stress)[3:4] <- c("water_stress_days", "N_stress_days")
stress
#>    water         N water_stress_days N_stress_days
#> 1    dry         0                81            75
#> 2 normal         0                 0            78
#> 3    dry 120 kg/ha                81            42
#> 4 normal 120 kg/ha                 0            54

# Grain (g m-2) per mm of seasonal actual ET
wue <- tapply(seq_len(nrow(scenarios)),
              interaction(scenarios$water, scenarios$N), function(i) {
  round(tail(scenarios$w_grain[i], 1) / sum(scenarios$aet_mm[i]), 2)
})
wue
#>            dry.0         normal.0    dry.120 kg/ha normal.120 kg/ha 
#>              Inf              Inf              Inf              Inf
```

Drought cuts yield through `f_w` even when N is ample; without fertiliser,
`f_N` binds instead. The interaction is visible in the yield table: N
fertiliser pays off most where water is not limiting. Note the lite
model's simplifications -- single daily water bucket, no vapour-pressure
or CO2 effects -- so treat these as teaching scenarios, not forecasts.

## Where do water and nitrogen go?


``` r
fate <- aggregate(cbind(runoff, drainage, n_leached, n_runoff) ~ water + N,
                  data = scenarios, FUN = sum)
fate[, 3:6] <- round(fate[, 3:6], 2)
names(fate)[3:6] <- c("runoff_mm", "drainage_mm", "N_leached", "N_runoff")
fate
#>    water         N runoff_mm drainage_mm N_leached N_runoff
#> 1    dry         0         0        0.00         0        0
#> 2 normal         0         0       23.59         0        0
#> 3    dry 120 kg/ha         0        0.00         0        0
#> 4 normal 120 kg/ha         0       23.59         0        0
```

Runoff here is mostly infiltration-excess: daily rain above
`params$infil_cap_mm` (default 40 mm/d) runs off before entering the soil
(Hortonian flow), plus saturation-excess when the topsoil is full.
`N_runoff` is the mineral N the runoff carries off the surface --
a loss pathway the N budget would otherwise miss. Leaching follows deep
drainage from the bottom layer.
