## Simplified ("lite") crop growth -------------------------------------------------
## Daily-step, RUE-based crop growth with thermal-time phenology and
## water / nitrogen stress. A deliberately small-parameter alternative to
## the full SPACSYS hourly Farquhar + 3-D root formulation (manual ch. 2):
## growth = RUE x intercepted PAR x min(f_temp, f_water, f_N).

#' Default crop parameters (lite model)
#'
#' Small parameter set for the simplified crop growth module. Three
#' built-in parameterisations are provided; any element can be
#' overridden after the call.
#'
#' @param crop one of \code{"wheat"}, \code{"rice"}, \code{"maize"} or
#'   \code{"generic"}.
#' @return A named list of crop parameters:
#' \describe{
#'   \item{\code{tbase}}{base temperature for thermal time (deg C).}
#'   \item{\code{add_req}}{thermal time (deg C d) required for stages
#'     1-3: sowing-emergence, emergence-heading, heading-maturity.}
#'   \item{\code{rue}}{radiation use efficiency (g DM MJ-1 PAR).}
#'   \item{\code{kext}}{canopy light extinction coefficient.}
#'   \item{\code{sla}}{specific leaf area (m2 g-1).}
#'   \item{\code{part}}{3 x 4 partitioning matrix (rows = stages,
#'     cols = leaf/stem/root/grain).}
#'   \item{\code{n_conc}}{optimal N concentration of new leaf/stem/root/
#'     grain growth (g N g-1 DM).}
#'   \item{\code{root_depth_max}}{maximum rooting depth (mm).}
#'   \item{\code{root_elong}}{root elongation per thermal time
#'     (mm per deg C d).}
#'   \item{\code{t_min_g}, \code{t_opt_g}, \code{t_max_g}}{cardinal
#'     temperatures for growth (deg C).}
#'   \item{\code{k_sen}}{leaf senescence rate after heading (d-1).}
#'   \item{\code{w0}}{initial seedling dry weights
#'     c(leaf, stem, root) (g m-2).}
#' }
#' @export
crop_default_params <- function(crop = c("wheat", "rice", "maize",
                                         "generic")) {
  crop <- match.arg(crop)
  p <- list(
    kext = 0.55, sla = 0.022,
    part = rbind(c(0.35, 0.15, 0.50, 0.00),
                 c(0.30, 0.40, 0.30, 0.00),
                 c(0.05, 0.20, 0.05, 0.70)),
    n_conc = c(leaf = 0.045, stem = 0.018, root = 0.012, grain = 0.022),
    root_depth_max = 1200, root_elong = 1.5,
    k_sen = 0.02, w0 = c(leaf = 2, stem = 1, root = 2)
  )
  crop_specific <- list(
    wheat = list(tbase = 2, add_req = c(120, 1000, 800), rue = 2.8,
                 t_min_g = 0, t_opt_g = 22, t_max_g = 35),
    rice = list(tbase = 8, add_req = c(100, 1100, 700), rue = 2.5,
                t_min_g = 8, t_opt_g = 30, t_max_g = 42, kext = 0.5,
                root_depth_max = 600),
    maize = list(tbase = 8, add_req = c(120, 800, 900), rue = 3.2,
                 t_min_g = 8, t_opt_g = 30, t_max_g = 42,
                 root_depth_max = 1500),
    generic = list(tbase = 5, add_req = c(120, 900, 800), rue = 2.8,
                   t_min_g = 2, t_opt_g = 25, t_max_g = 38)
  )
  c(p, crop_specific[[crop]])
}

#' Initialise the lite crop state
#'
#' @param crop crop parameter list from
#'   \code{\link{crop_default_params}}.
#' @return A state list with \code{dindex} (0-3), organ dry weights
#'   \code{w_leaf}, \code{w_stem}, \code{w_root}, \code{w_grain}
#'   (g m-2), \code{lai}, \code{root_depth_mm} and cumulative
#'   \code{n_uptake} (g N m-2).
#' @export
plant_init <- function(crop = crop_default_params()) {
  w <- crop$w0
  list(dindex = 0, w_leaf = w[["leaf"]], w_stem = w[["stem"]],
       w_root = w[["root"]], w_grain = 0,
       lai = w[["leaf"]] * crop$sla, root_depth_mm = 100, n_uptake = 0)
}

#' Advance thermal-time phenology
#'
#' Development index \eqn{D_{index}} (0-3) advances by
#' \eqn{GDD / ADD_{req,stage}} within the current stage
#' (manual eq. p. 18, simplified: no photoperiod/vernalisation terms).
#'
#' @param dindex current development index (0-3).
#' @param gdd daily thermal time (deg C d).
#' @param add_req thermal-time requirement per stage (deg C d).
#' @return Updated development index.
#' @export
phenology_step <- function(dindex, gdd, add_req) {
  if (dindex >= 3) return(3)
  stage <- min(3, floor(dindex) + 1)
  min(3, dindex + gdd / add_req[stage])
}

#' Temperature response of growth (beta function)
#'
#' 0 below \code{t_min} / above \code{t_max}, 1 at \code{t_opt},
#' smooth in between.
#'
#' @param tavg daily mean temperature (deg C).
#' @param t_min minimum temperature (deg C).
#' @param t_opt optimum temperature (deg C).
#' @param t_max maximum temperature (deg C).
#' @return Growth temperature factor (0-1).
#' @export
f_temp_growth <- function(tavg, t_min, t_opt, t_max) {
  f <- (tavg - t_min) / (t_opt - t_min) *
    ((t_max - tavg) / (t_max - t_opt))^((t_max - t_opt) / (t_opt - t_min))
  pmax(0, pmin(1, ifelse(tavg <= t_min | tavg >= t_max, 0, f)))
}

#' Daily lite crop growth step
#'
#' Potential growth follows intercepted PAR and radiation use
#' efficiency; actual growth is co-limited by temperature, water
#' (transpiration ratio) and nitrogen (supply/demand). New biomass is
#' partitioned to organs by development stage; senesced leaf becomes
#' litter; roots elongate with thermal time.
#'
#' @param state crop state list from \code{\link{plant_init}}.
#' @param rad incoming solar radiation (MJ m-2 d-1).
#' @param tavg daily mean temperature (deg C).
#' @param gdd daily thermal time (deg C d).
#' @param f_w water stress factor (actual/potential transpiration, 0-1).
#' @param n_avail mineral N available for uptake today (g N m-2).
#' @param crop crop parameter list.
#' @return A list with the updated \code{state} and daily fluxes:
#'   \code{growth}, \code{n_demand}, \code{n_uptake}, \code{f_t},
#'   \code{f_w}, \code{f_n}, \code{dindex}, \code{litter_c},
#'   \code{litter_n} (g C / g N m-2 d-1).
#' @export
plant_growth_step <- function(state, rad, tavg, gdd, f_w, n_avail,
                              crop = crop_default_params()) {
  ## phenology
  dindex <- phenology_step(state$dindex, gdd, crop$add_req)
  stage <- min(3, floor(dindex) + 1)

  ## potential growth from light (zero after maturity)
  par_int <- 0.5 * pmax(rad, 0) *
    (1 - exp(-crop$kext * state$lai))
  pot <- crop$rue * par_int * (dindex < 3)

  ## temperature factor
  f_t <- f_temp_growth(tavg, crop$t_min_g, crop$t_opt_g, crop$t_max_g)

  ## nitrogen demand of potential growth, then N stress
  part <- crop$part[stage, ]
  n_demand <- pot * sum(part * crop$n_conc)
  f_n <- if (n_demand > 0) min(1, n_avail / n_demand) else 1
  n_uptake <- min(n_avail, n_demand)

  ## actual growth
  growth <- pot * min(f_t, f_w, f_n)
  dw <- growth * part
  names(dw) <- c("leaf", "stem", "root", "grain")

  ## senescence after heading -> litter (45% C, leaf N conc.)
  k_sen <- if (dindex >= 2) crop$k_sen else 0
  sen_leaf <- state$w_leaf * k_sen
  litter_c <- sen_leaf * 0.45
  litter_n <- sen_leaf * crop$n_conc[["leaf"]]

  new_state <- list(
    dindex = dindex,
    w_leaf = state$w_leaf + dw[["leaf"]] - sen_leaf,
    w_stem = state$w_stem + dw[["stem"]],
    w_root = state$w_root + dw[["root"]],
    w_grain = state$w_grain + dw[["grain"]],
    lai = (state$w_leaf + dw[["leaf"]] - sen_leaf) * crop$sla,
    root_depth_mm = min(crop$root_depth_max,
                        state$root_depth_mm +
                          crop$root_elong * gdd * (dindex < 2.5)),
    n_uptake = state$n_uptake + n_uptake
  )
  list(state = new_state, growth = growth, n_demand = n_demand,
       n_uptake = n_uptake, f_t = f_t, f_w = f_w, f_n = f_n,
       dindex = dindex, litter_c = litter_c, litter_n = litter_n)
}
