## Response functions -------------------------------------------------------
## SPACSYS technical manual (Wu, 2022, ver. 6.00), equations as numbered.

#' Q10 temperature response factor
#'
#' Implements the Q10 temperature response used throughout SPACSYS
#' (manual eq. 39): \code{f_temp = Q10^((temp - t_base) / 10)}.
#' At \code{temp = t_base} the factor equals 1.
#'
#' @param temp temperature in degrees C (numeric vector).
#' @param q10 Q10 value, default 2.
#' @param t_base temperature at which the factor is unity, default 20.
#' @return Numeric vector of response factors.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 26.
#' @export
f_temp_q10 <- function(temp, q10 = 2, t_base = 20) {
  q10^((temp - t_base) / 10)
}

#' Soil-moisture response of decomposition
#'
#' Activity declines on either side of an optimal soil-water range
#' (manual eq. 175-176). Below \code{theta_m} the factor is 0; it rises to 1
#' at \code{theta_ol = theta_m + delta_theta1}, stays 1 up to
#' \code{theta_oh = theta_s - delta_theta2}, then declines towards
#' \code{e_s} at saturation.
#'
#' @param theta volumetric soil water content, same units as the other
#'   water contents (e.g. percent).
#' @param theta_s water content at saturation.
#' @param theta_m minimum water content for activity (manual: 85\% of
#'   wilting-point water content).
#' @param delta_theta1 range from \code{theta_m} to the optimum onset.
#' @param delta_theta2 range from optimum end to saturation.
#' @param e_s minimum factor value at saturation, default 0.2.
#' @param k_w empirical exponent, default 1.
#' @return Numeric vector of response factors in [0, 1].
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 55.
#' @export
f_water_decom <- function(theta, theta_s, theta_m, delta_theta1, delta_theta2,
                          e_s = 0.2, k_w = 1) {
  theta_ol <- theta_m + delta_theta1
  theta_oh <- theta_s - delta_theta2
  ifelse(theta < theta_m, 0,
  ifelse(theta < theta_ol, ((theta - theta_m) / (theta_ol - theta_m))^k_w,
  ifelse(theta <= theta_oh, 1,
  ifelse(theta <= theta_s,
         e_s + (1 - e_s) * ((theta_s - theta) / (theta_s - theta_oh))^k_w,
         e_s))))
}

#' Water-filled pore space
#'
#' \code{wfps = theta / (100 * (1 - bulk_density / particle_density))}
#' (manual eq. 190), with \code{theta} in percent.
#'
#' @param theta_pct volumetric water content in percent.
#' @param bulk_density soil bulk density (g cm-3).
#' @param particle_density particle density (g cm-3), default 2.65.
#' @return WFPS as a fraction (0-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 61.
#' @export
wfps <- function(theta_pct, bulk_density, particle_density = 2.65) {
  theta_pct / (100 * (1 - bulk_density / particle_density))
}

#' Michaelis-Menten substrate response
#'
#' \code{f(S) = S / (Km50 + S)} (manual eq. 192).
#'
#' @param s_con substrate concentration (g m-3).
#' @param km50 Michaelis constant (g m-3).
#' @return Response factor in [0, 1].
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 61.
#' @export
michaelis_menten <- function(s_con, km50) {
  ifelse(s_con + km50 <= 0, 0, s_con / (km50 + s_con))
}

#' Moisture response of autotrophic nitrification
#'
#' \code{f_water = max(0.6, -1.9 + 11.75*wfps - 11.25*wfps^2)}
#' (manual eq. 189).
#'
#' @param wfps water-filled pore space, fraction (see \code{\link{wfps}}).
#' @return Response factor (>= 0.6).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 61.
#' @export
f_water_nitrif <- function(wfps) {
  pmax(0.6, -1.9 + 11.75 * wfps - 11.25 * wfps^2)
}

#' pH response of autotrophic nitrification
#'
#' Exponential form adapted from the DenNit model (Reth et al., 2005):
#' \code{f(pH) = exp(-((pH - 6.6) / 2)^2)} (manual eq. 191).
#'
#' @param ph soil pH.
#' @return Response factor in (0, 1].
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 61.
#' @export
f_ph_nitrif <- function(ph) {
  exp(-((ph - 6.6) / 2)^2)
}

#' Nitrification-inhibitor effect decay
#'
#' \code{f_inhib = 0.05 + exp(-7 * (120 - d) / 120)} (manual eq. 184),
#' where \code{d} is days since the last external N application (half-life
#' ~60 days, Smith et al., 2005). Capped at 1 for \code{d >= 120} since the
#' printed form is only valid over the 120-day effect window.
#'
#' @param d days since last external N input (numeric vector).
#' @return Inhibitor effect factor (small = strong inhibition).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 58.
#' @export
f_inhib_nitrif <- function(d) {
  ifelse(d >= 120, 1, 0.05 + exp(-7 * (120 - d) / 120))
}

#' Moisture response of denitrification
#'
#' Ramps from 0 to 1 over \code{delta_theta} below saturation
#' (manual eq. 186). \code{delta_theta} is strongly soil-type dependent.
#'
#' @param theta volumetric water content, same units as \code{theta_s}.
#' @param theta_s water content at saturation.
#' @param delta_theta water-content interval over which the factor rises
#'   from 0 to 1.
#' @param k_w empirical exponent, default 1.
#' @return Response factor in [0, 1].
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 59.
#' @export
f_water_denitrif <- function(theta, theta_s, delta_theta, k_w = 1) {
  ifelse(theta >= theta_s, 1.0,
  ifelse(theta_s - theta <= delta_theta,
         ((theta - theta_s + delta_theta) / delta_theta)^k_w, 0.0))
}

#' pH responses of individual denitrifiers
#'
#' Step-specific acidity responses (manual eq. 199):
#' \itemize{
#'   \item step 1 (NO3- denitrifier):
#'     \code{1 - 1 / (1 + exp((pH - 4.25) / 0.5))}
#'   \item step 2 (NO2- denitrifier):
#'     \code{1 / (1 + exp(((pH - 4.5) / 2.5)^3.5))}. Note: for pH < 4.5 the
#'     printed form is not real-valued; it is extended continuously with
#'     its limit (0.5) below pH 4.5.
#'   \item step 3 (NO denitrifier):
#'     \code{exp(-((pH - 6.2) / 2.0)^2)}
#'   \item step 4 (N2O denitrifier):
#'     \code{exp(-((pH - 8.2) / 2.0)^2)}
#' }
#'
#' @param ph soil pH (numeric vector).
#' @param step integer 1-4 selecting the denitrification step.
#' @return Response factor.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 63.
#' @export
f_ph_denitrif <- function(ph, step = 1L) {
  if (!step %in% 1:4) stop("step must be an integer from 1 to 4")
  switch(as.character(step),
         "1" = 1 - 1 / (1 + exp((ph - 4.25) / 0.5)),
         "2" = { z <- (ph - 4.5) / 2.5
                 ## guard: printed form not real-valued for pH < 4.5;
                 ## extend continuously with the limit 0.5
                 1 / (1 + exp(pmax(z, 0)^3.5)) },
         "3" = exp(-((ph - 6.2) / 2.0)^2),
         "4" = exp(-((ph - 8.2) / 2.0)^2))
}

#' Anaerobic soil fraction
#'
#' SPACSYS allocates substrates between aerobic and anaerobic soil
#' fractions following the DNDC concept (Li et al., 2000). The manual does
#' not print an explicit equation for the anaerobic fraction, so this
#' helper implements a transparent linear ramp: 0 below
#' \code{wfps_crit} - \code{wfps_range}, 1 at and above
#' \code{wfps_crit}. Treat defaults as a placeholder to calibrate.
#'
#' @param wfps water-filled pore space, fraction.
#' @param wfps_crit WFPS at which the soil is fully anaerobic, default 0.9.
#' @param wfps_range WFPS range of the ramp, default 0.3.
#' @return Anaerobic fraction in [0, 1].
#' @export
anaerobic_fraction <- function(wfps, wfps_crit = 0.9, wfps_range = 0.3) {
  pmax(0, pmin(1, (wfps - (wfps_crit - wfps_range)) / wfps_range))
}
