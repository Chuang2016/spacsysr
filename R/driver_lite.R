## Lite integrated driver: water + C/N + crop --------------------------------------
## Daily-step coupling of the simplified modules:
##   weather -> PET -> soil water -> decomposition/mineralisation ->
##   nitrification -> plant N uptake -> denitrification/gases ->
##   crop growth (water & N stressed) -> litter return.
## Minimal inputs: daily Tmax/Tmin/precip, layered soil properties,
## initial C/N pools. See README for the input recipe.

#' Build a layered soil table from minimal inputs
#'
#' Helper that assembles the \code{soil} data.frame required by
#' \code{\link{spacsys_lite_run}} from per-layer (or scalar) properties.
#' Soil organic carbon is split into litter and humus pools via
#' \code{litter_frac}.
#'
#' @param depth_mm layer thicknesses (mm).
#' @param fc,wp,sat field capacity, wilting point, saturation
#'   (volumetric fractions); scalars are recycled to all layers.
#' @param bulk_density bulk density (g cm-3); scalar or per layer.
#' @param ph soil pH; scalar or per layer.
#' @param soc soil organic carbon (g C m-2); scalar or per layer.
#' @param litter_frac fraction of SOC initialised as litter (default 0.05).
#' @param nh4_init,no3_init initial mineral N (g N m-2); scalar or per layer.
#' @param theta_init initial water content (fraction); defaults to the
#'   midpoint of wilting point and field capacity.
#' @return A soil data.frame with one row per layer.
#' @export
soil_init <- function(depth_mm, fc = 0.30, wp = 0.12, sat = 0.45,
                     bulk_density = 1.35, ph = 6.5, soc = 3000,
                     litter_frac = 0.05, nh4_init = 1, no3_init = 3,
                     theta_init = NULL) {
  n <- length(depth_mm)
  rep_len <- function(x) rep_len_inner(x, n)
  rep_len_inner <- function(x, n) rep(x, length.out = n)
  if (is.null(theta_init)) theta_init <- (rep_len(fc) + rep_len(wp)) / 2
  data.frame(
    depth_mm = depth_mm,
    fc = rep_len(fc), wp = rep_len(wp), sat = rep_len(sat),
    bulk_density = rep_len(bulk_density), ph = rep_len(ph),
    theta_init = rep_len(theta_init),
    c_litter = rep_len(soc) * litter_frac,
    c_humus = rep_len(soc) * (1 - litter_frac),
    nh4 = rep_len(nh4_init), no3 = rep_len(no3_init)
  )
}

#' Root-zone weighting for N uptake
#'
#' Exponential root distribution weights per layer, normalised over
#' layers within the current rooting depth.
#'
#' @param zmid_mm layer mid-point depths (mm).
#' @param root_depth_mm current rooting depth (mm).
#' @return Normalised weights summing to 1 (0 for layers below roots).
#' @export
root_weights <- function(zmid_mm, root_depth_mm) {
  w <- ifelse(zmid_mm <= root_depth_mm,
              exp(-3 * zmid_mm / root_depth_mm), 0)
  if (sum(w) == 0) w[1] <- 1
  w / sum(w)
}

#' Simplified daily SPACSYS-lite driver
#'
#' Couples, at a daily step over layered soil: Hargreaves/Priestley-Taylor
#' PET (see \code{\link{weather_complete}}), tipping-bucket soil water
#' (\code{\link{soil_water_step}}), two-pool decomposition with C:N
#' stoichiometric mineralisation, simplified nitrification and
#' denitrification (\code{\link{soilcn_lite_step}}), demand-driven plant N
#' uptake, and RUE-based crop growth limited by temperature, water and
#' nitrogen (\code{\link{plant_growth_step}}). Senesced leaf returns to
#' the top-layer litter pool.
#'
#' This is a deliberately simplified research/teaching scaffold with
#' few parameters -- not a full SPACSYS port.
#'
#' @param weather data.frame with \code{date} (Date), \code{tmax},
#'   \code{tmin} (deg C), \code{precip} (mm d-1); optional \code{rad}
#'   (MJ m-2 d-1), \code{pet} (mm d-1), \code{irrig} (mm d-1, added to
#'   precipitation).
#' @param soil data.frame, one row per layer (see
#'   \code{\link{soil_init}}), with \code{depth_mm}, \code{fc},
#'   \code{wp}, \code{sat}, \code{bulk_density}, \code{ph},
#'   \code{theta_init}, \code{c_litter}, \code{c_humus} (g C m-2),
#'   \code{nh4}, \code{no3} (g N m-2).
#' @param crop crop parameter list from
#'   \code{\link{crop_default_params}}.
#' @param params parameter list from
#'   \code{\link{spacsys_default_params}}.
#' @param n_inputs optional data.frame with \code{date} and any of
#'   \code{nh4_add}, \code{no3_add} (g N m-2, applied to the top layer).
#' @param lat_deg latitude (decimal degrees, +N), used for PET and
#'   thermal time when weather is incomplete.
#' @return A data.frame with one row per day: \code{date},
#'   \code{dindex}, \code{lai}, \code{w_leaf}, \code{w_stem},
#'   \code{w_root}, \code{w_grain} (g DM m-2), \code{growth} (g m-2 d-1),
#'   \code{n_uptake} (g N m-2 d-1), stress factors \code{f_t},
#'   \code{f_w}, \code{f_n}, \code{pet}, \code{aet} (mm d-1),
#'   \code{swc_root} (root-zone mean water fraction), \code{drainage},
#'   \code{runoff} (mm d-1), \code{n2o}, \code{no} (g N m-2 d-1),
#'   \code{n_leached}, \code{n_mineralised}, \code{n_nitrified},
#'   \code{n_denitrified} (g N m-2 d-1), \code{co2_c} (g C m-2 d-1).
#' @export
spacsys_lite_run <- function(weather, soil, crop = crop_default_params(),
                             params = spacsys_default_params(),
                             n_inputs = NULL, lat_deg = 35) {
  weather <- weather_complete(weather, lat_deg, t_base = crop$tbase)
  if ("irrig" %in% names(weather))
    weather$precip <- weather$precip + ifelse(is.na(weather$irrig), 0,
                                              weather$irrig)
  if (!is.null(n_inputs)) n_inputs$date <- as.Date(n_inputs$date)

  n_layer <- nrow(soil)
  depth_m <- soil$depth_mm / 1000
  zmid <- cumsum(soil$depth_mm) - soil$depth_mm / 2

  theta <- soil$theta_init
  c_litter <- soil$c_litter; c_humus <- soil$c_humus
  nh4 <- soil$nh4; no3 <- soil$no3

  pstate <- plant_init(crop)
  n_day <- nrow(weather)
  out <- data.frame(
    date = weather$date, dindex = 0, lai = 0,
    w_leaf = 0, w_stem = 0, w_root = 0, w_grain = 0, growth = 0,
    n_uptake = 0, f_t = 1, f_w = 1, f_n = 1,
    pet = 0, aet = 0, swc_root = 0, drainage = 0, runoff = 0,
    n2o = 0, no = 0, n_leached = 0, n_mineralised = 0,
    n_nitrified = 0, n_denitrified = 0, co2_c = 0
  )

  for (d in seq_len(n_day)) {
    tavg <- weather$tavg[d]

    ## fertiliser events -> top layer
    if (!is.null(n_inputs)) {
      ev <- n_inputs[n_inputs$date == weather$date[d], , drop = FALSE]
      if (nrow(ev) > 0) {
        if ("nh4_add" %in% names(ev)) nh4[1] <- nh4[1] + sum(ev$nh4_add)
        if ("no3_add" %in% names(ev)) no3[1] <- no3[1] + sum(ev$no3_add)
      }
    }

    ## PET split into potential transpiration / soil evaporation
    pet <- weather$pet[d]
    pt <- pet * (1 - exp(-crop$kext * pstate$lai))
    w <- soil_water_step(theta, weather$precip[d], pet,
                         soil$fc, soil$wp, soil$sat, soil$depth_mm)
    theta <- w$theta
    at <- if (pet > 0) w$aet_mm * pt / pet else 0
    f_w <- if (pt > 0.01) min(1, at / pt) else 1

    ## nitrate leaching with deep drainage (bottom layer)
    water_mm <- theta * soil$depth_mm
    leach_frac <- min(w$drainage_mm / max(sum(water_mm), 1e-6), 1)
    leached <- no3[n_layer] * leach_frac
    no3[n_layer] <- no3[n_layer] - leached

    ## plant N availability: max daily uptake fraction of the mineral N
    ## pool in rooted layers (single weighting -- see note below)
    rw <- root_weights(zmid, pstate$root_depth_mm)
    rooted <- zmid <= pstate$root_depth_mm
    n_avail <- params$up_frac_max * sum((nh4 + no3) * rooted)

    ## crop growth (updates phenology, biomass, N uptake, litter)
    g <- plant_growth_step(pstate, weather$rad[d], tavg, weather$gdd[d],
                           f_w, n_avail, crop)
    pstate <- g$state

    ## distribute N uptake over rooted layers (NH4 first, then NO3),
    ## capped by the local pool; report what was actually removed
    up_tot <- g$n_uptake
    up_actual <- 0
    for (i in seq_len(n_layer)) {
      up_i <- up_tot * rw[i]
      up_nh4 <- min(nh4[i], up_i * nh4[i] / max(nh4[i] + no3[i], 1e-9))
      up_no3 <- min(no3[i], up_i - up_nh4)
      nh4[i] <- nh4[i] - up_nh4
      no3[i] <- no3[i] - up_no3
      up_actual <- up_actual + up_nh4 + up_no3
    }
    ## correct bookkeeping where local pools were depleted
    pstate$n_uptake <- pstate$n_uptake - (up_tot - up_actual)

    ## soil C/N per layer
    theta_pct <- theta * 100
    for (i in seq_len(n_layer)) {
      s <- soilcn_lite_step(
        list(c_litter = c_litter[i], c_humus = c_humus[i],
             nh4 = nh4[i], no3 = no3[i]),
        tsoil = tavg, theta_pct = theta_pct[i],
        sat_pct = soil$sat[i] * 100, ph = soil$ph[i],
        depth_m = depth_m[i], params = params)
      c_litter[i] <- s$pools$c_litter; c_humus[i] <- s$pools$c_humus
      nh4[i] <- s$pools$nh4; no3[i] <- s$pools$no3
      out$n2o[d] <- out$n2o[d] + s$n2o
      out$no[d] <- out$no[d] + s$no
      out$n_mineralised[d] <- out$n_mineralised[d] + s$n_mineralised
      out$n_nitrified[d] <- out$n_nitrified[d] + s$n_nitrified
      out$n_denitrified[d] <- out$n_denitrified[d] + s$n_denitrified
      out$co2_c[d] <- out$co2_c[d] + s$co2_c
    }

    ## litter return to top layer
    c_litter[1] <- c_litter[1] + g$litter_c

    ## record
    out$dindex[d] <- g$dindex; out$lai[d] <- pstate$lai
    out$w_leaf[d] <- pstate$w_leaf; out$w_stem[d] <- pstate$w_stem
    out$w_root[d] <- pstate$w_root; out$w_grain[d] <- pstate$w_grain
    out$growth[d] <- g$growth; out$n_uptake[d] <- up_actual
    out$f_t[d] <- g$f_t; out$f_w[d] <- f_w; out$f_n[d] <- g$f_n
    out$pet[d] <- pet; out$aet[d] <- w$aet_mm
    out$swc_root[d] <- sum(theta * rw)
    out$drainage[d] <- w$drainage_mm; out$runoff[d] <- w$runoff_mm
    out$n_leached[d] <- leached
  }
  out
}
