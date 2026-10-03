## Soil heat transport ---------------------------------------------------------------
## SPACSYS technical manual (Wu, 2022, ver. 6.00), ch. 6, p. 76-81.
## Core implemented: 1-D heat conduction with de Vries/Kersten-type
## thermal conductivity and the annual-wave lower boundary (eq. 251).
## The full surface energy-balance upper BC (eq. 253-273) and freeze-thaw
## bookkeeping are on the roadmap.

#' Soil thermal conductivity
#'
#' Organic layer (de Vries, 1975; manual eq. 245):
#' \code{k = 0.54 + 0.023*theta_pct} (unfrozen).
#' Mineral soil: the manual's Kersten form (eq. 248-249) needs Table 3
#' parameters that were not in the extracted text, so a simple linear
#' placeholder \code{k = 0.25 + 1.3*theta} is used and clearly marked.
#'
#' @param theta volumetric water content (fraction).
#' @param soil \code{"organic"} or \code{"mineral"}.
#' @return Thermal conductivity (W m-1 K-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 76.
#' @export
thermal_conductivity <- function(theta, soil = c("mineral", "organic")) {
  soil <- match.arg(soil)
  if (soil == "organic") {
    0.54 + 0.023 * theta * 100
  } else {
    0.25 + 1.3 * theta   # placeholder; see docs
  }
}

#' Annual-wave lower boundary temperature
#'
#' \code{Tb = Tannual + Tam*exp(-z/dd)*cos(2*pi/Lcycle*(t - tshift) - z/dd)}
#' with damping depth \code{dd = sqrt(Lcycle*D/pi)} (manual eq. 251-252).
#'
#' @param t_annual annual mean air temperature (degrees C).
#' @param t_amp temperature amplitude (degrees C).
#' @param z_m depth (m).
#' @param day_of_year day of year (1-366).
#' @param d_d damping depth (m).
#' @param t_shift phase shift (days), default 0.
#' @param l_cycle cycle length (days), default 365.
#' @return Soil temperature at depth (degrees C).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 77.
#' @export
bottom_temp_wave <- function(t_annual, t_amp, z_m, day_of_year, d_d,
                             t_shift = 0, l_cycle = 365) {
  t_annual + t_amp * exp(-z_m / d_d) *
    cos(2 * pi / l_cycle * (day_of_year - t_shift) - z_m / d_d)
}

#' 1-D soil heat conduction
#'
#' Implicit finite-difference solution of
#' \code{d(C*T)/dt = d/dz(k dT/dz)} (conductive part of manual eq. 244;
#' convective and freeze-thaw terms omitted).
#'
#' @param t_init initial soil temperature per node (degrees C).
#' @param dz_m node spacing (m, uniform).
#' @param theta volumetric water content per node (fraction).
#' @param dt_day time step in days, default 1.
#' @param n_sub number of sub-steps, default 24.
#' @param t_top surface temperature (degrees C, Dirichlet top BC).
#' @param bottom_bc \code{"wave"} (annual wave, eq. 251) or
#'   \code{"fixed"}.
#' @param t_bottom fixed bottom temperature (degrees C) for
#'   \code{bottom_bc = "fixed"}.
#' @param t_annual,t_amp,d_d,day_of_year parameters for
#'   \code{\link{bottom_temp_wave}} when \code{bottom_bc = "wave"}.
#' @param soil \code{"mineral"} or \code{"organic"} for
#'   \code{\link{thermal_conductivity}}.
#' @param c_solid volumetric heat capacity of solids (J m-3 K-1),
#'   default 2e6.
#' @param porosity total porosity (fraction), default 0.5.
#' @return Numeric vector of soil temperatures (degrees C).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 76-77.
#' @export
heat_conduction_1d <- function(t_init, dz_m, theta, dt_day = 1, n_sub = 24,
                               t_top, bottom_bc = c("wave", "fixed"),
                               t_bottom = 10, t_annual = 15, t_amp = 10,
                               d_d = 2, day_of_year = 180,
                               soil = c("mineral", "organic"),
                               c_solid = 2e6, porosity = 0.5) {
  bottom_bc <- match.arg(bottom_bc)
  soil <- match.arg(soil)
  n <- length(t_init)
  dt <- dt_day * 86400 / n_sub
  k <- thermal_conductivity(theta, soil)
  k_mid <- (k[-n] + k[-1]) / 2
  cap <- c_solid * (1 - porosity) + 4.18e6 * theta
  t <- t_init

  z_bot <- n * dz_m
  t_bot <- if (bottom_bc == "wave")
    bottom_temp_wave(t_annual, t_amp, z_bot, day_of_year, d_d) else t_bottom

  for (s in seq_len(n_sub)) {
    lo <- numeric(n); di <- numeric(n); up <- numeric(n); rhs <- numeric(n)
    r <- dt / dz_m^2
    for (i in 2:(n - 1)) {
      lo[i] <- -r * k_mid[i - 1] / cap[i]
      di[i] <- 1 + r * (k_mid[i - 1] + k_mid[i]) / cap[i]
      up[i] <- -r * k_mid[i] / cap[i]
      rhs[i] <- t[i]
    }
    di[1] <- 1; rhs[1] <- t_top
    di[n] <- 1; rhs[n] <- t_bot
    t <- thomas_solve(lo, di, up, rhs)
  }
  t
}
