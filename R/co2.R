## Carbon dioxide: autotrophic respiration ----------------------------------------

#' Root respiration (Q10)
#'
#' Specific root respiration scaled by a Q10 temperature response:
#' \code{R_root = r_ref * W_root * Q10^((T_soil - T_ref)/10)}.
#' The anoxic fraction of this flux feeds methanogenesis
#' (\code{\link{ch4_lite_step}}); the aerobic fraction is emitted as CO2.
#'
#' @param w_root root dry matter (g m-2).
#' @param t_soil soil temperature (degrees C).
#' @param q10 Q10 value; default 2.
#' @param t_ref reference temperature (degrees C); default 20.
#' @param r_ref specific respiration rate at \code{t_ref}
#'   (g C g-1 root DM d-1); default 0.004.
#' @return Root respiration (g C m-2 d-1).
#' @export
root_respiration <- function(w_root, t_soil, q10 = 2, t_ref = 20,
                             r_ref = 0.004) {
  r_ref * w_root * q10^((t_soil - t_ref) / 10)
}

#' Shoot maintenance respiration (Q10)
#'
#' As \code{\link{root_respiration}} but for aboveground biomass, driven
#' by air temperature. Follows the manual's maintenance-respiration
#' concept (eq. 39): biomass x Q10 temperature factor.
#'
#' @param w_shoot aboveground dry matter, leaves + stems (+ grain);
#'   g m-2.
#' @param t_air air temperature (degrees C).
#' @param q10,t_ref,r_ref as in \code{\link{root_respiration}};
#'   default \code{r_ref = 0.003}.
#' @return Shoot maintenance respiration (g C m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 26.
#' @export
shoot_respiration <- function(w_shoot, t_air, q10 = 2, t_ref = 20,
                              r_ref = 0.003) {
  r_ref * w_shoot * q10^((t_air - t_ref) / 10)
}

#' Autotrophic CO2 respiration (lite)
#'
#' Daily autotrophic respiration for the lite growth module:
#' root + shoot maintenance (Q10) plus growth respiration taken as a
#' fixed fraction of daily dry-matter growth -- a simplification of
#' manual eq. 40-41 (\code{Rg ~= 0.234 * A_canopy}; here
#' \code{Rg = rg_frac * growth} with default 0.25).
#' The anoxic fraction of root respiration is excluded: it becomes CH4
#' via \code{\link{ch4_lite_step}}, not CO2.
#'
#' @param w_root,w_shoot root and shoot dry matter (g m-2).
#' @param growth daily total dry-matter growth (g m-2 d-1).
#' @param t_soil,t_air soil and air temperature (degrees C).
#' @param anoxic_frac anoxic fraction of the root zone (-); the same
#'   fraction of root respiration is diverted to methanogenesis.
#' @param rg_frac growth-respiration fraction (-); default 0.25.
#' @param f_c carbon fraction of dry matter; default 0.45.
#' @param ... further arguments passed to \code{\link{root_respiration}}
#'   and \code{\link{shoot_respiration}}.
#' @return A list with \code{co2_root}, \code{co2_shoot},
#'   \code{co2_growth} and \code{co2_auto} (total autotrophic CO2,
#'   g C m-2 d-1).
#' @export
co2_autotrophic <- function(w_root, w_shoot, growth, t_soil, t_air,
                            anoxic_frac = 0, rg_frac = 0.25,
                            f_c = 0.45, ...) {
  r_root  <- root_respiration(w_root, t_soil, ...)
  r_shoot <- shoot_respiration(w_shoot, t_air, ...)
  r_growth <- rg_frac * growth * f_c
  co2_root <- r_root * (1 - anoxic_frac)
  list(co2_root = co2_root, co2_shoot = r_shoot,
       co2_growth = r_growth,
       co2_auto = co2_root + r_shoot + r_growth)
}
