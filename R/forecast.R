## Crop model x short-term weather forecast: rolling ensemble yield forecasting --
## Three-segment weather chain (observed | NWP 7-10 d | scenario ensemble)
## feeding spacsys_lite_run(), plus a leave-one-year-out hindcast protocol
## that quantifies how forecast skill for final yield converges as the
## season progresses. Pure base R, zero new dependencies.

## -- season helpers -------------------------------------------------------------

#' Slice one crop season out of a multi-year weather table
#'
#' @param hist data.frame with \code{date} (Date), \code{tmax},
#'   \code{tmin} (deg C), \code{precip} (mm d-1), covering several years.
#' @param pyear planting year (the year the season starts).
#' @param start_md,end_md season bounds as \code{"MM-DD"} strings. When
#'   \code{end_md < start_md} (e.g. winter wheat) the season ends in
#'   \code{pyear + 1}.
#' @return The season's weather rows, sorted by date.
#' @export
season_slice <- function(hist, pyear, start_md, end_md) {
  d0 <- as.Date(paste0(pyear, "-", start_md))
  d1 <- as.Date(paste0(pyear + (end_md < start_md), "-", end_md))
  s <- hist[hist$date >= d0 & hist$date <= d1, , drop = FALSE]
  s <- s[order(s$date), , drop = FALSE]
  n_expect <- as.integer(d1 - d0) + 1L
  if (nrow(s) != n_expect)
    stop("season_slice: incomplete weather for pyear ", pyear,
         " (got ", nrow(s), " of ", n_expect, " days)")
  rownames(s) <- NULL
  s
}

#' Planting years with complete seasons in a weather table
#'
#' @inheritParams season_slice
#' @return Sorted integer vector of planting years whose season
#'   (\code{start_md} to \code{end_md}) is fully covered by
#'   \code{hist}.
#' @export
available_pyears <- function(hist, start_md, end_md) {
  yrs <- sort(unique(as.integer(format(hist$date, "%Y"))))
  ok <- vapply(yrs, function(y) {
    d0 <- as.Date(paste0(y, "-", start_md))
    d1 <- as.Date(paste0(y + (end_md < start_md), "-", end_md))
    dd <- hist$date[hist$date >= d0 & hist$date <= d1]
    length(unique(dd)) == as.integer(d1 - d0) + 1L
  }, logical(1))
  yrs[ok]
}

## -- synthetic NWP (hindcast lab) ----------------------------------------------

#' Degrade true future weather into a synthetic NWP forecast
#'
#' Hindcast-lab stand-in for a real 7-10 day numerical weather
#' forecast: adds lead-time-dependent error to the actual future
#' weather. Temperature error is AR(1) in lead time with growing
#' innovation variance (the same perturbation is applied to
#' \code{tmax} and \code{tmin}, mimicking correlated NWP temperature
#' error); precipitation occurrence is flipped with a lead-time-growing
#' probability and wet-day amounts are multiplied by log-normal noise.
#' In operations, replace the output of this function with the real
#' forecast (e.g. CMA / ECMWF / Open-Meteo daily
#' \code{temperature_2m_max}, \code{temperature_2m_min},
#' \code{precipitation_sum}).
#'
#' @param actual data.frame with \code{date}, \code{tmax},
#'   \code{tmin}, \code{precip}, starting the day after the issue date.
#' @param horizon forecast horizon in days (default 10).
#' @param temp_sd0,temp_sd_day base and per-day growth of the
#'   temperature error SD (deg C).
#' @param temp_ar1 AR(1) coefficient of the temperature error across
#'   lead time.
#' @param pflip_day per-day growth of the wet/dry flip probability
#'   (capped at 0.3).
#' @param amt_sd0,amt_sd_day base and per-day growth of the log-amount
#'   noise SD.
#' @return A data.frame with \code{date}, \code{tmax}, \code{tmin},
#'   \code{precip} and \code{min(horizon, nrow(actual))} rows.
#' @export
synthetic_nwp <- function(actual, horizon = 10,
                          temp_sd0 = 0.5, temp_sd_day = 0.25,
                          temp_ar1 = 0.6,
                          pflip_day = 0.02,
                          amt_sd0 = 0.1, amt_sd_day = 0.08) {
  actual <- actual[order(actual$date),
                   c("date", "tmax", "tmin", "precip")]
  k <- min(horizon, nrow(actual))
  if (k < 1) stop("synthetic_nwp: no future weather to degrade")
  actual <- actual[seq_len(k), , drop = FALSE]
  lead <- seq_len(k)

  ## temperature: AR(1) error with growing innovation variance
  sd_k <- temp_sd0 + temp_sd_day * lead
  e <- numeric(k)
  e[1] <- rnorm(1, 0, sd_k[1])
  if (k > 1) for (i in 2:k)
    e[i] <- temp_ar1 * e[i - 1] +
      rnorm(1, 0, sd_k[i] * sqrt(max(0, 1 - temp_ar1^2)))
  tmax_f <- actual$tmax + e
  tmin_f <- actual$tmin + e
  tmin_f <- pmin(tmin_f, tmax_f - 0.5)  # keep physical ordering

  ## precipitation: flip occurrence, perturb amounts
  wet <- actual$precip > 0
  pflip <- pmin(pflip_day * lead, 0.3)
  flip <- runif(k) < pflip
  wet_f <- xor(wet, flip)
  wet_mean <- mean(actual$precip[wet])
  if (!is.finite(wet_mean) || wet_mean <= 0) wet_mean <- 5
  amt_sd <- amt_sd0 + amt_sd_day * lead
  base_amt <- ifelse(wet, pmax(actual$precip, 0.1), wet_mean)
  precip_f <- ifelse(wet_f, base_amt * exp(rnorm(k, 0, amt_sd)), 0)

  data.frame(date = actual$date, tmax = tmax_f, tmin = tmin_f,
             precip = precip_f)
}

## -- weather chain --------------------------------------------------------------

#' Stitch the three-segment weather chain
#'
#' Concatenates observed weather (up to the issue date), the NWP
#' forecast and one scenario tail into a single full-season weather
#' table ready for \code{\link{spacsys_lite_run}}. Warns (rather than
#' fails) when segment boundaries are not exactly contiguous, so that
#' slightly ragged real-world inputs still run.
#'
#' @param obs observed weather, \code{date <= issue_date}.
#' @param nwp forecast weather for the days after the issue date
#'   (e.g. from \code{\link{synthetic_nwp}} or a real NWP product).
#' @param tail one scenario realisation of the remaining season
#'   (may be a 0-row data.frame when the issue date is at the very
#'   end of the season).
#' @return A single weather data.frame with \code{date}, \code{tmax},
#'   \code{tmin}, \code{precip} (plus any of \code{rad},
#'   \code{sunshine}, \code{pet}, \code{irrig} present in all three).
#' @export
stitch_weather <- function(obs, nwp, tail) {
  need <- c("date", "tmax", "tmin", "precip")
  for (nm in c("obs", "nwp", "tail")) {
    x <- get(nm)
    if (!all(need %in% names(x)))
      stop("stitch_weather: '", nm, "' lacks required columns")
  }
  extras <- c("rad", "sunshine", "pet", "irrig")
  keep <- c(need, extras[extras %in% names(obs) &
                           extras %in% names(nwp) &
                           extras %in% names(tail)])
  obs <- obs[order(obs$date), keep, drop = FALSE]
  nwp <- nwp[order(nwp$date), keep, drop = FALSE]
  tail <- tail[order(tail$date), keep, drop = FALSE]
  if (nrow(nwp) > 0 && nwp$date[1] != max(obs$date) + 1)
    warning("stitch_weather: nwp does not start the day after obs ends")
  if (nrow(tail) > 0 && nrow(nwp) > 0 &&
      tail$date[1] != max(nwp$date) + 1)
    warning("stitch_weather: tail does not start the day after nwp ends")
  out <- rbind(obs, nwp, tail)
  rownames(out) <- NULL
  out
}

#' Draw scenario tails from historical analogue years
#'
#' For the part of the season beyond the NWP horizon, each ensemble
#' member borrows the corresponding calendar window from one
#' historical year (analogue-year resampling, which preserves the real
#' temporal structure of weather). Dates are re-based onto the current
#' season so the chain stays contiguous.
#'
#' @param hist multi-year weather table (see
#'   \code{\link{season_slice}}).
#' @param pyear current planting year.
#' @param start_md,end_md season bounds (\code{"MM-DD"}).
#' @param tail_start first Date needing a scenario (the day after the
#'   NWP window ends).
#' @param n_ens number of ensemble members.
#' @param exclude planting years to exclude from the draw (the
#'   hindcast year itself is excluded automatically via
#'   \code{pyear}).
#' @param seed optional seed for the year draw (does not touch the
#'   global RNG otherwise).
#' @return A list of \code{n_ens} data.frames with \code{date},
#'   \code{tmax}, \code{tmin}, \code{precip}.
#' @export
tail_scenarios <- function(hist, pyear, start_md, end_md, tail_start,
                           n_ens = 30, exclude = NULL, seed = NULL) {
  d0 <- as.Date(paste0(pyear, "-", start_md))
  d1 <- as.Date(paste0(pyear + (end_md < start_md), "-", end_md))
  tail_start <- as.Date(tail_start)
  empty <- hist[0, c("date", "tmax", "tmin", "precip"), drop = FALSE]
  if (tail_start > d1)
    return(replicate(n_ens, empty, simplify = FALSE))
  if (!is.null(seed)) {
    old <- if (exists(".Random.seed", envir = .GlobalEnv))
      get(".Random.seed", envir = .GlobalEnv) else NULL
    set.seed(seed)
    on.exit({
      if (is.null(old)) rm(".Random.seed", envir = .GlobalEnv)
      else assign(".Random.seed", old, envir = .GlobalEnv)
    }, add = TRUE)
  }
  md0 <- format(tail_start, "%m-%d")
  expect_n <- as.integer(d1 - tail_start) + 1L
  want_md <- format(seq(tail_start, d1, by = "day"), "%m-%d")
  cand <- setdiff(available_pyears(hist, start_md, end_md),
                  c(pyear, exclude))
  if (length(cand) < 1)
    stop("tail_scenarios: no donor years available")
  draw <- sample(cand, n_ens, replace = TRUE)
  lapply(draw, function(y) {
    donor <- season_slice(hist, y, start_md, end_md)
    dmd <- format(donor$date, "%m-%d")
    idx <- match(want_md, dmd)
    miss <- is.na(idx)
    if (any(miss)) {
      ## leap-day fallback: borrow 02-28 when the donor year has no 02-29
      fix <- ifelse(want_md[miss] == "02-29", "02-28", want_md[miss])
      idx[miss] <- match(fix, dmd)
    }
    if (any(is.na(idx)))
      stop("tail_scenarios: donor year ", y, " lacks needed dates")
    s <- donor[idx, c("date", "tmax", "tmin", "precip"), drop = FALSE]
    s$date <- seq(tail_start, by = "day", length.out = nrow(s))
    rownames(s) <- NULL
    s
  })
}

## -- ensemble forecast ----------------------------------------------------------

#' Ensemble yield forecast from a weather chain
#'
#' Runs \code{\link{spacsys_lite_run}} once per scenario tail over the
#' stitched full-season weather and summarises the ensemble:
#' above-ground biomass (leaf + stem + grain) trajectories as
#' P10/P50/P90 bands and the final grain-yield distribution.
#'
#' @param obs,nwp,tails as in \code{\link{stitch_weather}} /
#'   \code{\link{tail_scenarios}} (\code{tails} is a list).
#' @param soil,crop,params,n_inputs,lat_deg,ponding as in
#'   \code{\link{spacsys_lite_run}}.
#' @return A list with \code{runs} (one lite-model output per member),
#'   \code{agb} (data.frame: \code{date}, \code{p10}, \code{p50},
#'   \code{p90}, \code{mean}, \code{sd} of above-ground biomass,
#'   g DM m-2), \code{yield} (list with \code{values},
#'   \code{mean}, \code{sd}, \code{p10}, \code{p50}, \code{p90} in
#'   g m-2 and \code{mean_t_ha}), \code{n_ens} and \code{issue_date}.
#' @export
forecast_yield_ensemble <- function(obs, nwp, tails, soil,
                                    crop = crop_default_params(),
                                    params = spacsys_default_params(),
                                    n_inputs = NULL, lat_deg = 35,
                                    ponding = FALSE) {
  runs <- lapply(tails, function(tl) {
    w <- stitch_weather(obs, nwp, tl)
    spacsys_lite_run(w, soil, crop = crop, params = params,
                     n_inputs = n_inputs, lat_deg = lat_deg,
                     ponding = ponding)
  })
  dates <- runs[[1]]$date
  agb_mat <- sapply(runs, function(r)
    r$w_leaf + r$w_stem + r$w_grain)
  qs <- t(apply(agb_mat, 1, quantile, probs = c(0.1, 0.5, 0.9)))
  agb <- data.frame(date = dates, p10 = qs[, 1], p50 = qs[, 2],
                     p90 = qs[, 3], mean = rowMeans(agb_mat),
                     sd = apply(agb_mat, 1, sd))
  yv <- sapply(runs, function(r) tail(r$w_grain, 1))
  yq <- quantile(yv, probs = c(0.1, 0.5, 0.9))
  list(runs = runs, agb = agb,
       yield = list(values = yv, mean = mean(yv), sd = sd(yv),
                    p10 = yq[1], p50 = yq[2], p90 = yq[3],
                    mean_t_ha = mean(yv) / 100),
       n_ens = length(runs), issue_date = max(obs$date))
}

## -- hindcast experiment --------------------------------------------------------

#' Rolling hindcast: does the yield forecast converge through the season?
#'
#' Leave-one-year-out hindcast protocol. For each planting year, the
#' "true" yield is the lite-model run on the full observed season
#' (perfect-model setup: this validates the *forecast-chain design*,
#' not the crop model itself -- real validation needs measured
#' yields). Then, at each issue date, the chain is built from observed
#' weather so far + a synthetic NWP forecast
#' (\code{\link{synthetic_nwp}}) + analogue-year tails
#' (\code{\link{tail_scenarios}}, donor years exclude the hindcast
#' year), and the ensemble-mean yield is compared with the true
#' yield. Use \code{\link{hindcast_skill}} to aggregate into the
#' RMSE-vs-issue-date convergence curve.
#'
#' @param hist multi-year weather table (see
#'   \code{\link{season_slice}}).
#' @param start_md,end_md season bounds (\code{"MM-DD"}).
#' @param issue_mds character vector of issue dates (\code{"MM-DD"}),
#'   in chronological season order.
#' @param n_ens number of ensemble members per forecast.
#' @param horizon NWP horizon in days.
#' @param soil,crop,params,lat_deg,ponding as in
#'   \code{\link{spacsys_lite_run}}.
#' @param n_inputs fertiliser data.frame (absolute dates) or a
#'   function \code{function(pyear)} returning one (so dates shift
#'   with the hindcast year).
#' @param nwp_args extra arguments passed to
#'   \code{\link{synthetic_nwp}}.
#' @param seed optional seed for reproducibility.
#' @return A data.frame with one row per (year, issue date):
#'   \code{pyear}, \code{issue_md}, \code{issue_order},
#'   \code{issue_date}, \code{y_true}, \code{y_mean}, \code{y_sd},
#'   \code{y_p10}, \code{y_p50}, \code{y_p90}, \code{err}
#'   (ensemble mean minus true, g m-2), \code{clim} (leave-one-out
#'   climatological yield forecast, g m-2).
#' @export
hindcast_experiment <- function(hist, start_md, end_md, issue_mds,
                                n_ens = 20, horizon = 10,
                                soil, crop = crop_default_params(),
                                params = spacsys_default_params(),
                                n_inputs = NULL, lat_deg = 35,
                                ponding = FALSE,
                                nwp_args = list(), seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  pyears <- available_pyears(hist, start_md, end_md)
  if (length(pyears) < 2)
    stop("hindcast_experiment: need >= 2 complete years")
  get_nin <- function(py)
    if (is.function(n_inputs)) n_inputs(py) else n_inputs

  ## pass 1: true yields (perfect-model truth)
  y_true <- vapply(pyears, function(py) {
    s <- season_slice(hist, py, start_md, end_md)
    r <- spacsys_lite_run(s, soil, crop = crop, params = params,
                          n_inputs = get_nin(py), lat_deg = lat_deg,
                          ponding = ponding)
    tail(r$w_grain, 1)
  }, numeric(1))

  rows <- list()
  for (py in pyears) {
    season <- season_slice(hist, py, start_md, end_md)
    d0 <- min(season$date); d1 <- max(season$date)
    clim <- mean(y_true[pyears != py])
    for (i in seq_along(issue_mds)) {
      md <- issue_mds[i]
      issue_date <- as.Date(paste0(py + (md < start_md), "-", md))
      if (issue_date <= d0 || issue_date >= d1)
        stop("hindcast_experiment: issue date ", md,
             " outside season for pyear ", py)
      obs <- season[season$date <= issue_date, , drop = FALSE]
      fut <- season[season$date > issue_date, , drop = FALSE]
      nwp <- do.call(synthetic_nwp,
                     c(list(actual = fut, horizon = horizon), nwp_args))
      tails <- tail_scenarios(hist, py, start_md, end_md,
                              tail_start = max(nwp$date) + 1,
                              n_ens = n_ens)
      ens <- forecast_yield_ensemble(obs, nwp, tails, soil,
                                     crop = crop, params = params,
                                     n_inputs = get_nin(py),
                                     lat_deg = lat_deg,
                                     ponding = ponding)
      rows[[length(rows) + 1]] <- data.frame(
        pyear = py, issue_md = md, issue_order = i,
        issue_date = issue_date, y_true = y_true[pyears == py],
        y_mean = ens$yield$mean, y_sd = ens$yield$sd,
        y_p10 = ens$yield$p10, y_p50 = ens$yield$p50,
        y_p90 = ens$yield$p90,
        err = ens$yield$mean - y_true[pyears == py],
        clim = clim)
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

#' Aggregate hindcast output into the convergence curve
#'
#' @param hind data.frame from \code{\link{hindcast_experiment}}.
#' @return A data.frame with one row per issue date
#'   (\code{issue_md}, \code{issue_order}): \code{n_years},
#'   \code{rmse}, \code{bias}, \code{mae} of the ensemble-mean yield
#'   (t ha-1), \code{mean_spread} (mean ensemble SD, t ha-1),
#'   \code{rmse_clim} (RMSE of the climatological forecast) and
#'   \code{skill} = 1 - rmse/rmse_clim.
#' @export
hindcast_skill <- function(hind) {
  sk <- do.call(rbind, lapply(split(hind, hind$issue_order),
                              function(d) {
    rmse <- sqrt(mean(d$err^2)) / 100
    rmse_clim <- sqrt(mean((d$clim - d$y_true)^2)) / 100
    data.frame(issue_md = d$issue_md[1],
               issue_order = d$issue_order[1],
               n_years = nrow(d),
               rmse = rmse,
               bias = mean(d$err) / 100,
               mae = mean(abs(d$err)) / 100,
               mean_spread = mean(d$y_sd) / 100,
               rmse_clim = rmse_clim,
               skill = 1 - rmse / rmse_clim)
  }))
  sk <- sk[order(sk$issue_order), , drop = FALSE]
  rownames(sk) <- NULL
  sk
}
