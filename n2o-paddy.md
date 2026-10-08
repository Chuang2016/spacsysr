---
title: "Simulating N2O emissions from a paddy soil with spacsysr"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Simulating N2O emissions from a paddy soil}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



## Overview

This vignette demonstrates the `spacsysr` workflow on a nitrous oxide
(N2O) question: how do simplified vs. microbiological formulations of
nitrification/denitrification differ in their simulated N2O emissions
from a fertilised paddy soil? The example data are synthetic teaching
data (`load_example("paddy_weather")`, `load_example("paddy_soil")`).

## Setup


``` r
weather <- load_example("paddy_weather")
soil    <- load_example("paddy_soil")
params  <- spacsys_default_params()

# Two urea applications (g N m-2): basal + tillering
n_inputs <- data.frame(
  date    = as.Date(c("2026-05-10", "2026-06-15")),
  nh4_add = c(6, 4),
  no3_add = c(0, 0)
)
```

## Simplified formulation


``` r
out_simp <- spacsys_run(weather, soil, params, method = "simplified",
                        n_inputs = n_inputs)
```

## Microbiological formulation


``` r
out_micr <- spacsys_run(weather, soil, params, method = "microbial",
                        n_inputs = n_inputs)
```

## Compare N2O


``` r
plot(out_simp$date, out_simp$n2o * 1000, type = "l",
     xlab = "Date", ylab = expression(N[2]*O ~ (mg ~ N ~ m^{-2} ~ d^{-1})),
     main = "Daily N2O emission: simplified vs microbial")
lines(out_micr$date, out_micr$n2o * 1000, col = "red", lty = 2)
legend("topright", c("simplified", "microbial"), col = c("black", "red"),
       lty = c(1, 2))
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)

``` r

cat("Season total N2O (simplified):", sum(out_simp$n2o), "g N m-2\n")
#> Season total N2O (simplified): 0.501959 g N m-2
cat("Season total N2O (microbial): ", sum(out_micr$n2o), "g N m-2\n")
#> Season total N2O (microbial):  2.150749 g N m-2
```

## Process attribution


``` r
cat("Simplified: nitrified =", sum(out_simp$n_nitrified),
    ", denitrified =", sum(out_simp$n_denitrified),
    ", leached =", sum(out_simp$n_leached), "g N m-2\n")
#> Simplified: nitrified = 9.583208 , denitrified = 4.187529 , leached = 0.285105 g N m-2
cat("Microbial:  nitrified =", sum(out_micr$n_nitrified),
    ", denitrified =", sum(out_micr$n_denitrified),
    ", leached =", sum(out_micr$n_leached), "g N m-2\n")
#> Microbial:  nitrified = 0.06533134 , denitrified = 3.168064 , leached = 0.3590737 g N m-2
```

The denitrification peaks follow high-WFPS episodes after rainfall,
consistent with the SPACSYS moisture response (eq. 186) and the
anaerobic-fraction concept borrowed from DNDC.

## Notes for calibration

Key parameters to calibrate against chamber data: `knitri`, `kdeni`,
`n_half`, `delta_theta_denit`, `n2o_frac_denitrif` (simplified), and
`gd`, `ni50`, `f_n2o_max` (microbial). See `?spacsys_default_params`.

For field-scale paddy N2O with a real floodwater layer (dissolved-gas
routing, bund overflow) and batch scenario comparison, see the
`rice-ponding` vignette (`ponding` module + `run_scenarios()`).
