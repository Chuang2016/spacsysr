## Nitrogenous gas emissions ------------------------------------------------------

#' Nitrification-sourced NO emission
#'
#' \code{e_NO = f_NOmax * f_temp * n_nitri} (manual eq. 200), after the
#' DNDC approach (Li, 2000).
#'
#' @param n_nitri nitrification rate (g N m-2 d-1).
#' @param f_temp temperature response factor.
#' @param f_no_max maximum fraction of nitrification contributing to the
#'   NO pool (-); manual gives no default, 0.01 is a starting value.
#' @return NO emission rate (g N m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 63.
#' @export
nitrif_no_emission <- function(n_nitri, f_temp, f_no_max = 0.01) {
  f_no_max * f_temp * n_nitri
}

#' Nitrification-sourced N2O emission
#'
#' \code{e_N2O = f_N2Omax * f_temp * n_nitri} (manual eq. 201).
#'
#' @param n_nitri nitrification rate (g N m-2 d-1).
#' @param f_temp temperature response factor.
#' @param f_n2o_max maximum fraction of nitrification contributing to the
#'   N2O pool (-); manual gives no default, 0.01 is a starting value.
#' @return N2O emission rate (g N m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 63.
#' @export
nitrif_n2o_emission <- function(n_nitri, f_temp, f_n2o_max = 0.01) {
  f_n2o_max * f_temp * n_nitri
}

#' Soil gas diffusivity (Penman equation)
#'
#' \code{Dp = alpha * epsilon * f(T) * D0} (manual eq. 203), after
#' Penman (1940) and Moldrup et al. (2004). The manual does not print an
#' explicit form for the temperature factor \code{f(T)}; this
#' implementation uses the standard \code{((T + 273.15) / 293.15)^1.75}
#' scaling.
#'
#' @param air_porosity air-filled porosity (-).
#' @param temp_c soil temperature (degrees C), default 20.
#' @param alpha adjustment parameter, default 0.66 (manual).
#' @param d0 gas diffusion coefficient in free air (m2 s-1), default
#'   2.6e-5 (manual).
#' @return Soil gas diffusivity (m2 s-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 63-64.
#' @export
penman_diffusivity <- function(air_porosity, temp_c = 20, alpha = 0.66,
                               d0 = 2.6e-5) {
  f_t <- ((temp_c + 273.15) / 293.15)^1.75
  alpha * air_porosity * f_t * d0
}

#' Diffusion-driven nitrogenous gas emission
#'
#' \code{e_NOx = Dp * NOx} (manual eq. 202).
#'
#' @param diffusivity soil gas diffusivity from
#'   \code{\link{penman_diffusivity}} (m2 s-1).
#' @param conc gas concentration in soil air (consistent units).
#' @return Emission rate in consistent units.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 63.
#' @export
nox_emission <- function(diffusivity, conc) {
  diffusivity * conc
}
