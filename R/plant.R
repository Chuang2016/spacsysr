## Plant respiration ---------------------------------------------------------------

#' Plant maintenance respiration
#'
#' \code{Rm = W_biomass * Q10^((Ta - Tbase) / 10)} (manual eq. 39),
#' applied per plant component (leaves, stems, seeds).
#'
#' @param w_biomass biomass of the plant component (g m-2).
#' @param q10 Q10 value.
#' @param temp_air air temperature (degrees C).
#' @param t_base temperature at which the Q10 factor is unity.
#' @return Maintenance respiration (same mass units per day).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 26.
#' @export
maint_respiration <- function(w_biomass, q10, temp_air, t_base) {
  w_biomass * f_temp_q10(temp_air, q10 = q10, t_base = t_base)
}

#' Plant growth respiration
#'
#' From van Iersel & Seymour (2000), manual eq. 40-41:
#' \code{Rg = (1 / (2.5 * Fc * Yg) - 1) * A_canopy}.
#' With defaults (Yg = 0.72, Fc = 0.45), Rg ~= 0.234 * A_canopy.
#' Growth respiration is deducted from gross photosynthesis directly.
#'
#' @param a_canopy canopy gross photosynthesis (g C m-2 d-1).
#' @param y_g conversion efficiency, default 0.72.
#' @param f_c carbon fraction in plant biomass, default 0.45.
#' @return Growth respiration (g C m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 26;
#'   van Iersel & Seymour (2000).
#' @export
growth_respiration <- function(a_canopy, y_g = 0.72, f_c = 0.45) {
  (1 / (2.5 * f_c * y_g) - 1) * a_canopy
}
