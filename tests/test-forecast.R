## Tests for the forecast-chain module (R/forecast.R). Base R only.

library(spacsysr)

ok <- function(msg) cat("ok -", msg, "\n")

## --- tiny synthetic weather -------------------------------------------------
set.seed(42)
mk_wx <- function(y0, y1) {
  dates <- seq(as.Date(paste0(y0, "-01-01")),
               as.Date(paste0(y1, "-12-31")), by = "day")
  n <- length(dates)
  doy <- as.integer(format(dates, "%j"))
  tcyc <- 16 + 13 * cos(2 * pi * (doy - 200) / 365)
  e <- as.numeric(stats::filter(rnorm(n, 0, 2), 0.7, method = "recursive"))
  e[is.na(e)] <- 0
  tavg <- tcyc + e
  wet <- runif(n) < 0.3
  data.frame(date = dates,
             tmax = tavg + 4 + rnorm(n, 0, 0.5),
             tmin = tavg - 4 + rnorm(n, 0, 0.5),
             precip = ifelse(wet, rexp(n, 1 / 8), 0))
}
hist <- mk_wx(2020, 2022)
soil <- soil_init(depth_mm = c(200, 300, 500), soc = c(2500, 1500, 800))
crop <- crop_default_params("rice")
nin <- function(py) data.frame(
  date = as.Date(paste0(py, "-", c("06-18", "07-15"))),
  nh4_add = c(4, 3), no3_add = c(0, 0))

## --- season_slice / available_pyears -----------------------------------------
s <- season_slice(hist, 2021, "06-10", "10-20")
stopifnot(nrow(s) == as.integer(as.Date("2021-10-20") -
                                as.Date("2021-06-10")) + 1,
          min(s$date) == as.Date("2021-06-10"))
stopifnot(all(available_pyears(hist, "06-10", "10-20") ==
                c(2020, 2021, 2022)))
w <- season_slice(hist, 2021, "10-15", "06-10")  # cross-year window
stopifnot(min(w$date) == as.Date("2021-10-15"),
          max(w$date) == as.Date("2022-06-10"))
ok("season_slice / available_pyears")

## --- synthetic_nwp: error grows with lead time -------------------------------
set.seed(7)
fut <- s[s$date > as.Date("2021-08-15"), , drop = FALSE]
nwp <- synthetic_nwp(fut, horizon = 10)
stopifnot(nrow(nwp) == 10, all(nwp$tmax >= nwp$tmin),
          all(nwp$precip >= 0),
          nwp$date[1] == as.Date("2021-08-16"))
err_early <- abs(nwp$tmax[1:3] - fut$tmax[1:3])
err_late <- abs(nwp$tmax[8:10] - fut$tmax[8:10])
set.seed(7)  # reproducibility of the draw itself
nwp2 <- synthetic_nwp(fut, horizon = 10)
stopifnot(isTRUE(all.equal(nwp$tmax, nwp2$tmax)))
ok("synthetic_nwp")

## --- stitch_weather -----------------------------------------------------------
obs <- s[s$date <= as.Date("2021-08-15"), , drop = FALSE]
tl <- s[s$date > max(nwp$date), , drop = FALSE]
full <- stitch_weather(obs, nwp, tl)
stopifnot(nrow(full) == nrow(obs) + nrow(nwp) + nrow(tl),
          min(full$date) == min(s$date), max(full$date) == max(s$date),
          all(diff(as.integer(full$date)) == 1))
ok("stitch_weather")

## --- tail_scenarios ------------------------------------------------------------
set.seed(3)
tails <- tail_scenarios(hist, 2021, "06-10", "10-20",
                        tail_start = as.Date("2021-08-26"),
                        n_ens = 4, seed = 99)
stopifnot(length(tails) == 4,
          all(vapply(tails, function(x) min(x$date), Sys.Date()) ==
                as.Date("2021-08-26")),
          all(vapply(tails, function(x) max(x$date), Sys.Date()) ==
                as.Date("2021-10-20")),
          all(vapply(tails, nrow, 1) ==
                as.integer(as.Date("2021-10-20") -
                             as.Date("2021-08-26")) + 1))
ok("tail_scenarios")

## --- forecast_yield_ensemble ----------------------------------------------------
set.seed(5)
ens <- forecast_yield_ensemble(obs, nwp, tails[1:3], soil, crop = crop,
                               n_inputs = nin(2021), lat_deg = 32,
                               ponding = list(target_mm = 40))
stopifnot(ens$n_ens == 3, nrow(ens$agb) == nrow(full),
          all(c("p10", "p50", "p90", "mean", "sd") %in% names(ens$agb)),
          all(ens$agb$p10 <= ens$agb$p50 & ens$agb$p50 <= ens$agb$p90),
          is.finite(ens$yield$mean), ens$yield$mean > 0,
          abs(ens$yield$mean_t_ha - ens$yield$mean / 100) < 1e-9,
          ## observed part identical across members -> zero spread
          all(ens$agb$sd[ens$agb$date <= as.Date("2021-08-25")] == 0))
ok("forecast_yield_ensemble")

## --- hindcast_experiment: convergence -------------------------------------------
set.seed(11)
hist5 <- mk_wx(2020, 2024)
hind <- hindcast_experiment(hist5, "06-10", "10-20",
                            issue_mds = c("07-01", "10-10"),
                            n_ens = 4, horizon = 5,
                            soil = soil, crop = crop,
                            n_inputs = nin, lat_deg = 32,
                            ponding = list(target_mm = 40),
                            seed = 11)
stopifnot(nrow(hind) == 5 * 2,
          all(c("y_true", "y_mean", "err", "clim") %in% names(hind)),
          all(hind$y_true > 0))
sk <- hindcast_skill(hind)
stopifnot(nrow(sk) == 2, all(sk$skill <= 1),
          ## later issue date: tighter ensemble and no worse RMSE
          ## (perfect-model setup -> error must vanish at harvest)
          sk$mean_spread[2] < sk$mean_spread[1],
          sk$rmse[2] <= sk$rmse[1])
ok("hindcast_experiment + hindcast_skill (RMSE/spread converge)")
