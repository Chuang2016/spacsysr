## Tests for R/openmeteo.R. Offline only: the JSON parser is tested on an
## inline sample response; live downloads are verified manually, not here
## (R CMD check must not depend on the network).

library(spacsysr)

ok <- function(msg) cat("ok -", msg, "\n")

sample_json <- paste0(
  '{"latitude":31.86,"daily_units":{"time":"iso8601"},',
  '"daily":{"time":["2026-10-05","2026-10-06"],',
  '"temperature_2m_max":[21.8,24.3],"temperature_2m_min":[14.0,11.7],',
  '"precipitation_sum":[0.0,3.2],"shortwave_radiation_sum":[19.43,null]}}')

d <- spacsysr:::.om_daily_arrays(sample_json)
stopifnot(all(c("time", "temperature_2m_max", "temperature_2m_min",
                "precipitation_sum", "shortwave_radiation_sum") %in%
                names(d)),
          identical(d$time, c("2026-10-05", "2026-10-06")),
          is.na(d$shortwave_radiation_sum[2]))
ok(".om_daily_arrays")

fc <- spacsysr:::.om_frame(d)
stopifnot(nrow(fc) == 2, identical(fc$date, as.Date(c("2026-10-05",
                                                     "2026-10-06"))),
          fc$tmax[1] == 21.8, fc$tmin[2] == 11.7,
          fc$precip[2] == 3.2, fc$rad[1] == 19.43, is.na(fc$rad[2]),
          all(fc$precip >= 0))
ok(".om_frame")

## rows without data (API nulls) are dropped
d_null <- spacsysr:::.om_daily_arrays(
  gsub('"temperature_2m_min":\\[14.0,11.7\\]',
       '"temperature_2m_min":[14.0,null]', sample_json, fixed = FALSE))
fc_null <- spacsysr:::.om_frame(d_null)
stopifnot(nrow(fc_null) == 1, fc_null$date == as.Date("2026-10-05"))
ok(".om_frame drops no-data rows")

## malformed input raises cleanly
err <- tryCatch({ spacsysr:::.om_daily_arrays("not json"); "no error" },
                error = function(e) "error")
stopifnot(err == "error")
ok("parser error handling")

## per-member nwp list plumbing (offline, tiny season)
set.seed(9)
wx <- data.frame(date = seq(as.Date("2024-06-10"), by = "day",
                            length.out = 150),
                 tmax = 30 + rnorm(150, 0, 1.5), tmin = 22 + rnorm(150, 0, 1),
                 precip = pmax(0, rnorm(150, 5, 8)))
soil <- soil_init(depth_mm = c(200, 300, 500), soc = c(2500, 1500, 800))
issue <- as.Date("2024-07-10")
obs <- wx[wx$date <= issue, ]
nwp1 <- wx[wx$date > issue & wx$date <= issue + 5, ]
nwp2 <- nwp1; nwp2$tmax <- nwp2$tmax + 2  # warmer member
tl <- wx[wx$date > issue + 5, ]
ens <- forecast_yield_ensemble(obs, list(nwp1, nwp2), list(tl, tl), soil,
                               crop = crop_default_params("rice"),
                               lat_deg = 32)
stopifnot(ens$n_ens == 2,
          diff(ens$yield$values) != 0,  # members really differ
          all(ens$agb$sd[ens$agb$date > issue] >= 0))
err2 <- tryCatch({
  forecast_yield_ensemble(obs, list(nwp1), list(tl, tl), soil,
                          crop = crop_default_params("rice"), lat_deg = 32)
  "no error"
}, error = function(e) "error")
stopifnot(err2 == "error")
ok("forecast_yield_ensemble per-member nwp")
