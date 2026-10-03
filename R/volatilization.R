## Ammonia volatilisation ---------------------------------------------------------

#' NH3 loss during slurry spreading
#'
#' One-off loss on the application day (manual eq. 204):
#' \code{N_vol = Omega * TAN + eta * TAN * LAI / Ww},
#' combining direct loss during application and canopy interception.
#'
#' @param tan ammoniacal N in applied slurry (g N m-2).
#' @param lai leaf area index of the canopy (-).
#' @param w_w wet weight of slurry applied (g m-2).
#' @param omega proportion of TAN lost during application, default 0.02.
#' @param eta slurry intercepted per unit leaf area (g m-2), default 200.
#' @return NH3 volatilised during spreading (g N m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 64.
#' @export
nh3_spreading <- function(tan, lai, w_w, omega = 0.02, eta = 200) {
  omega * tan + eta * tan * lai / w_w
}

#' NH3 volatilisation after spreading
#'
#' Integrates the TAN mass balance after surface application
#' (manual eq. 207-209):
#' \itemize{
#'   \item \code{Ww(t) = Ww0 - (I + E - p) * t} (eq. 207)
#'   \item \code{dTAN/dt = -epsilon * TAN / Ww - I * TAN / Ww}
#'     (eq. 208-209)
#' }
#' where \code{epsilon = Qt * gamma / r} (equilibrium coefficient times
#' slurry specific weight over aerodynamic resistance). The closed form
#' in eq. 205 is ambiguously typeset in the manual, so this function
#' integrates the ODE numerically over the day (24 sub-steps) instead;
#' volatilisation is the cumulative \code{epsilon * TAN / Ww} flux and
#' infiltration removes \code{I * TAN / Ww}.
#'
#' @param tan TAN remaining on the soil surface (g N m-2).
#' @param w_w wet weight of surface slurry (g m-2).
#' @param infil infiltration rate (g m-2 d-1).
#' @param evap evaporation rate (g m-2 d-1).
#' @param precip precipitation (g m-2 d-1).
#' @param epsilon volatilisation transfer coefficient (d-1), i.e.
#'   \code{Qt * gamma / r} in the manual's notation.
#' @param dt length of the integration window in days, default 1.
#' @param n_sub number of sub-steps, default 24.
#' @return A list with \code{n_vol} (NH3 volatilised, g N m-2),
#'   \code{tan_new} and \code{w_w_new}.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 64-65;
#'   Hutchings et al. (1996).
#' @export
nh3_after_spreading <- function(tan, w_w, infil, evap, precip, epsilon,
                                dt = 1, n_sub = 24) {
  h <- dt / n_sub
  n_vol <- 0
  for (k in seq_len(n_sub)) {
    if (w_w <= 0 || tan <= 0) break
    vol_rate <- epsilon * tan / w_w
    inf_rate <- infil * tan / w_w
    tan <- tan - (vol_rate + inf_rate) * h
    w_w <- w_w - (infil + evap - precip) * h
    n_vol <- n_vol + vol_rate * h
    tan <- max(tan, 0); w_w <- max(w_w, 0)
  }
  list(n_vol = n_vol, tan_new = tan, w_w_new = w_w)
}
