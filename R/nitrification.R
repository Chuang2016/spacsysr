## Nitrification ----------------------------------------------------------------

#' Simplified nitrification rate
#'
#' \code{n_nitri = k_nitri * f_inhib * f_temp * f_water * f_pH * f_NH4-NO3}
#' (manual eq. 182), with
#' \code{f_NH4-NO3 = (NH4 - NO3) / r_no3_nh4} when \code{NH4 > NO3},
#' else 0 (eq. 183), and the inhibitor decay \code{f_inhib}
#' (eq. 184, see \code{\link{f_inhib_nitrif}}).
#'
#' @param nh4 ammonium concentration (g N m-3).
#' @param no3 nitrate concentration (g N m-3).
#' @param knitri potential nitrification rate (d-1).
#' @param f_temp temperature response factor (see
#'   \code{\link{f_temp_q10}}).
#' @param f_water moisture response factor; the manual reuses the
#'   decomposition moisture response (eq. 175).
#' @param f_ph pH response factor (see \code{\link{f_ph_nitrif}}).
#' @param d_since_n days since last external N input, default 0 (no
#'   inhibition).
#' @param r_no3_nh4 nitrate-ammonium ratio scaling in eq. 183; the manual
#'   is terse here, default 1.
#' @return Nitrification rate in concentration per day (g N m-3 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 58.
#' @export
nitrif_simplified <- function(nh4, no3, knitri, f_temp, f_water, f_ph,
                              d_since_n = 0, r_no3_nh4 = 1) {
  f_inhib <- f_inhib_nitrif(d_since_n)
  f_nh4_no3 <- ifelse(nh4 > no3, (nh4 - no3) / r_no3_nh4, 0)
  knitri * f_inhib * f_temp * f_water * f_ph * f_nh4_no3
}

#' Nitrifier biomass dynamics (microbiological method)
#'
#' Gross growth, death and maintenance respiration of nitrifiers after
#' Blagodatsky & Richter (1998), manual eq. 187-188:
#' \itemize{
#'   \item \code{ng = g_nitr * f_temp * f_water * f_pH * f(DOC) * f(NO3) * B}
#'   \item \code{nd = d_nitr * f_temp * f_water * f_pH * f(DOC) * B^2}
#'   \item \code{rr = (1/fe - 1) * B}
#'   \item \code{B_new = B + ng - nd - rr}
#' }
#'
#' @param bn_prev nitrifier biomass at previous step (g C m-2).
#' @param gnitr maximum nitrifier gross growth rate (d-1).
#' @param dnitr maximum nitrifier death rate (d-1).
#' @param fe efficiency factor (-).
#' @param f_temp,f_water,f_ph response factors.
#' @param f_doc,f_no3 substrate response factors for DOC and NO3
#'   (see \code{\link{michaelis_menten}}).
#' @return A list with \code{biomass}, \code{growth}, \code{death} and
#'   \code{respiration}.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 61.
#' @export
nitrifier_growth <- function(bn_prev, gnitr, dnitr, fe, f_temp, f_water,
                             f_ph, f_doc, f_no3) {
  ng <- gnitr * f_temp * f_water * f_ph * f_doc * f_no3 * bn_prev
  nd <- dnitr * f_temp * f_water * f_ph * f_doc * bn_prev^2
  rr <- (1 / fe - 1) * bn_prev
  bn_new <- bn_prev + ng - nd - rr
  list(biomass = max(bn_new, 0), growth = ng, death = nd,
       respiration = rr)
}

#' Microbiological nitrification rate
#'
#' \code{nn = nn_max * f_inhib * B * f_temp * f_water * f_pH * f(NH4)}
#' (manual eq. 193).
#'
#' @param nnmax maximum nitrification rate (d-1).
#' @param biomass nitrifier biomass (g C m-2).
#' @param f_inhib inhibitor effect factor (see
#'   \code{\link{f_inhib_nitrif}}).
#' @param f_temp,f_water,f_ph response factors.
#' @param f_nh4 ammonium substrate response (see
#'   \code{\link{michaelis_menten}}).
#' @return Nitrification rate (g N m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 62.
#' @export
nitrif_microbial <- function(nnmax, biomass, f_inhib, f_temp, f_water,
                             f_ph, f_nh4) {
  nnmax * f_inhib * biomass * f_temp * f_water * f_ph * f_nh4
}
