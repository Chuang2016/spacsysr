## Multi-scenario batch runs -------------------------------------------------------
## Run the lite model over a set of management scenarios (e.g.
## fertiliser x irrigation regimes) and return one comparison table
## with yield, stress days and the GHG / carbon-footprint metrics.

#' Batch-run management scenarios and compare carbon footprints
#'
#' Runs \code{\link{spacsys_lite_run}} once per scenario and binds a
#' one-row-per-scenario summary: grain yield, water/N stress days and
#' the seasonal GHG budget from \code{\link{ghg_footprint}}
#' (CO2/CH4/N2O per ha, CO2-equivalents and the yield-scaled carbon
#' footprint intensity). Designed for questions like "which
#' fertiliser x irrigation regime gives the best yield per
#' CO2-eq?".
#'
#' @param base_weather baseline weather data.frame (see
#'   \code{\link{spacsys_lite_run}}); each scenario modifies a copy.
#' @param soil soil data.frame from \code{\link{soil_init}}.
#' @param crop default crop parameter list
#'   (\code{\link{crop_default_params}}); individual scenarios may
#'   override it.
#' @param scenarios named list of scenario specs. Each element is a
#'   list with any of: \code{precip_scale} (default 1),
#'   \code{irrig} (\code{FALSE} default; \code{TRUE} = irrigate to
#'   replace daily ET demand; or a numeric vector, mm d-1),
#'   \code{n_inputs} (fertiliser data.frame, default \code{NULL}),
#'   \code{ponding} (default \code{FALSE}; see
#'   \code{\link{spacsys_lite_run}}), \code{crop} (override).
#'   Unnamed lists get \code{"S1"}, \code{"S2"}, ... labels.
#' @param lat_deg latitude (decimal degrees, +N).
#' @param params parameter list from
#'   \code{\link{spacsys_default_params}}.
#' @param ... further arguments passed to
#'   \code{\link{ghg_footprint}} (e.g. \code{gwp_ch4}).
#' @return A data.frame with one row per scenario: \code{scenario},
#'   \code{yield_t_ha}, \code{water_stress_days},
#'   \code{n_stress_days}, \code{ch4_kg_ha}, \code{n2o_kg_ha},
#'   \code{co2_kg_ha}, \code{ghg_co2eq_kg_ha},
#'   \code{intensity_kg_co2eq_per_t_grain}, \code{share_ch4},
#'   \code{share_n2o}.
#' @export
run_scenarios <- function(base_weather, soil,
                          crop = crop_default_params(),
                          scenarios, lat_deg = 35,
                          params = spacsys_default_params(), ...) {
  if (is.null(names(scenarios)) || any(names(scenarios) == ""))
    names(scenarios) <- paste0("S", seq_along(scenarios))
  res <- lapply(names(scenarios), function(nm) {
    sc <- scenarios[[nm]]
    cr <- if (!is.null(sc$crop)) sc$crop else crop
    w <- base_weather
    ps <- if (!is.null(sc$precip_scale)) sc$precip_scale else 1
    w$precip <- w$precip * ps
    ir <- sc$irrig
    if (isTRUE(ir)) {
      wc <- weather_complete(w, lat_deg, t_base = cr$tbase)
      w$irrig <- pmax(0, wc$pet - w$precip)
    } else if (is.numeric(ir)) {
      w$irrig <- ir
    }
    out <- spacsys_lite_run(w, soil, crop = cr, params = params,
                            n_inputs = sc$n_inputs, lat_deg = lat_deg,
                            ponding = if (!is.null(sc$ponding))
                              sc$ponding else FALSE)
    fp <- ghg_footprint(out, ...)
    data.frame(
      scenario = nm,
      yield_t_ha = fp$yield_t_ha,
      water_stress_days = sum(out$f_w < 0.9),
      n_stress_days = sum(out$f_n < 0.9),
      ch4_kg_ha = fp$ch4_kg_ha,
      n2o_kg_ha = fp$n2o_kg_ha,
      co2_kg_ha = fp$co2_kg_ha,
      ghg_co2eq_kg_ha = fp$ghg_co2eq_kg_ha,
      intensity_kg_co2eq_per_t_grain =
        fp$intensity_kg_co2eq_per_t_grain,
      share_ch4 = fp$share_ch4,
      share_n2o = fp$share_n2o,
      stringsAsFactors = FALSE)
  })
  do.call(rbind, res)
}
