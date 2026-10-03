## Methane dynamics ---------------------------------------------------------------

#' Temperature response of methane oxidation
#'
#' \code{f_temp = exp(b0 + b1 * Ts + b2 * Ts^2) / b_max} (manual eq. 212),
#' with defaults from Sabrekov et al. (2016):
#' b0 = -3.95, b1 = 0.149, b2 = -0.0029, b_max = 0.1668.
#'
#' @param t_soil soil temperature (degrees C).
#' @param b0,b1,b2,bmax empirical coefficients.
#' @return Temperature response factor (-).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66;
#'   Sabrekov et al. (2016).
#' @export
f_temp_ch4 <- function(t_soil, b0 = -3.95, b1 = 0.149, b2 = -0.0029,
                       bmax = 0.1668) {
  exp(b0 + b1 * t_soil + b2 * t_soil^2) / bmax
}

#' CH4 oxidation by rhizospheric methanotrophs
#'
#' Michaelis-Menten kinetics in both CH4 and O2 (manual eq. 210):
#' \code{CH4_r = Vr_max * f_temp * r_moist * W_root *
#'   CH4/(Kr_CH4 + CH4) * O2/(KO2 + O2)}.
#'
#' @param vr_max maximum uptake rate (g CH4 g-1 root DM d-1).
#' @param f_temp temperature factor (see \code{\link{f_temp_ch4}}).
#' @param r_moist ratio of layer moisture to saturated water content (-).
#' @param w_root root dry matter in the layer (g m-2).
#' @param ch4_con,o2_con CH4 and O2 concentrations (g m-3).
#' @param kr_ch4 Michaelis constant for CH4 (g CH4 m-3).
#' @param ko2 Michaelis constant for O2 (g m-3).
#' @return CH4 uptake rate (g CH4 m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66.
#' @export
ch4_oxidation_rhizo <- function(vr_max, f_temp, r_moist, w_root,
                                ch4_con, o2_con, kr_ch4, ko2) {
  vr_max * f_temp * r_moist * w_root *
    ch4_con / (kr_ch4 + ch4_con) * o2_con / (ko2 + o2_con)
}

#' CH4 oxidation by soil methanotrophs
#'
#' As above but for non-rhizosphere soil methanotrophs (manual eq. 211):
#' \code{CH4_s = Vs_max * f_temp * r_moist * rho_s *
#'   CH4/(Ks_CH4 + CH4) * O2/(KO2 + O2)}.
#'
#' @param vs_max maximum uptake rate (g CH4 g-1 dry soil d-1).
#' @param f_temp temperature factor (see \code{\link{f_temp_ch4}}).
#' @param r_moist ratio of layer moisture to saturated water content (-).
#' @param bulk_density soil bulk density; used here as dry soil mass per
#'   unit volume consistent with the layer depth handled by the caller.
#' @param ch4_con,o2_con CH4 and O2 concentrations (g m-3).
#' @param ks_ch4 Michaelis constant for CH4 (g CH4 m-3).
#' @param ko2 Michaelis constant for O2 (g m-3).
#' @return CH4 uptake rate in the caller's area units.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66.
#' @export
ch4_oxidation_soil <- function(vs_max, f_temp, r_moist, bulk_density,
                               ch4_con, o2_con, ks_ch4, ko2) {
  vs_max * f_temp * r_moist * bulk_density *
    ch4_con / (ks_ch4 + ch4_con) * o2_con / (ko2 + o2_con)
}

#' Methane production
#'
#' \code{R_CH4(z) = f_CH4 * R_root(z) / (1 + eta_inhib * O2)}
#' (manual eq. 213), after Raivonen et al. (2017).
#'
#' @param r_root anoxic respiration rate at layer mid-depth
#'   (g CO2 m-2 d-1 or consistent C units).
#' @param f_ch4_co2 fraction of anaerobic respiration becoming CH4,
#'   default 0.3 (manual).
#' @param eta_inhib sensitivity of methanogenesis to O2 inhibition
#'   (m3 g-1).
#' @param o2_con O2 concentration (g m-3).
#' @return CH4 production rate.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66;
#'   Raivonen et al. (2017).
#' @export
ch4_production <- function(r_root, f_ch4_co2 = 0.3, eta_inhib, o2_con) {
  f_ch4_co2 * r_root / (1 + eta_inhib * o2_con)
}
