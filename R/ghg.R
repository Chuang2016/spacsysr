## Greenhouse-gas aggregation -----------------------------------------------------

#' Convert GHG fluxes to CO2-equivalents
#'
#' \code{CO2eq = CO2 + GWP_CH4 * CH4 + GWP_N2O * N2O} on a per-mass-of-gas
#' basis. Default GWP100 values are from IPCC AR6
#' (CH4 = 27.9, N2O = 273); pass AR5 values (28, 265) or any horizon
#' via the arguments.
#'
#' @param ch4,n2o,co2 fluxes in mass of gas (any consistent units,
#'   e.g. kg ha-1).
#' @param gwp_ch4,gwp_n2o 100-year global warming potentials.
#' @return CO2-equivalent flux in the same mass units.
#' @references IPCC (2021). AR6 WG1, Chapter 7.
#' @export
ghg_co2eq <- function(ch4, n2o, co2 = 0, gwp_ch4 = 27.9, gwp_n2o = 273) {
  co2 + gwp_ch4 * ch4 + gwp_n2o * n2o
}

#' Carbon / GHG footprint of a lite-model run
#'
#' Seasonal greenhouse-gas budget from a \code{\link{spacsys_lite_run}}
#' output data frame: sums CO2 (heterotrophic + autotrophic), CH4 and
#' N2O over the season, converts to CO2-equivalents with
#' \code{\link{ghg_co2eq}}, and -- when grain yield is available --
#' reports the yield-scaled footprint intensity
#' (kg CO2-eq per tonne of grain), the standard carbon-footprint metric.
#'
#' Unit conversions applied: \code{co2_*_c} (g C) -> CO2 x 44/12;
#' \code{n2o} (g N) -> N2O x 44/28; \code{ch4} is already g CH4.
#'
#' @param out output data frame from \code{\link{spacsys_lite_run}}.
#' @param grain_col name of the grain-biomass column (g m-2); set to
#'   \code{NULL} to skip the yield-scaled intensity.
#' @param ... arguments passed to \code{\link{ghg_co2eq}}.
#' @return A data frame with one row: seasonal \code{co2_kg_ha},
#'   \code{ch4_kg_ha}, \code{n2o_kg_ha}, \code{ghg_co2eq_kg_ha},
#'   per-gas shares (\code{share_co2}, \code{share_ch4},
#'   \code{share_n2o}) and, when available,
#'   \code{intensity_kg_co2eq_per_t_grain} and \code{yield_t_ha}.
#' @export
ghg_footprint <- function(out, grain_col = "w_grain", ...) {
  req <- c("co2_total_c", "ch4", "n2o")
  miss <- setdiff(req, names(out))
  if (length(miss))
    stop("ghg_footprint needs columns: ", paste(miss, collapse = ", "))
  co2 <- sum(out$co2_total_c, na.rm = TRUE) * 44 / 12      # g CO2 m-2
  ch4 <- sum(out$ch4, na.rm = TRUE)                        # g CH4 m-2
  n2o <- sum(out$n2o, na.rm = TRUE) * 44 / 28              # g N2O m-2
  to_ha <- 10  # g m-2 -> kg ha-1
  co2_ha <- co2 * to_ha; ch4_ha <- ch4 * to_ha; n2o_ha <- n2o * to_ha
  total <- ghg_co2eq(ch4_ha, n2o_ha, co2_ha, ...)
  res <- data.frame(
    co2_kg_ha = co2_ha, ch4_kg_ha = ch4_ha, n2o_kg_ha = n2o_ha,
    ghg_co2eq_kg_ha = total,
    share_co2 = co2_ha / total, share_ch4 = ghg_co2eq(ch4_ha, 0, 0, ...) / total,
    share_n2o = ghg_co2eq(0, n2o_ha, 0, ...) / total
  )
  if (!is.null(grain_col) && grain_col %in% names(out)) {
    yld <- utils::tail(out[[grain_col]], 1) / 100  # g m-2 -> t ha-1
    res$yield_t_ha <- yld
    res$intensity_kg_co2eq_per_t_grain <- if (yld > 0) total / yld else NA_real_
  }
  res
}
