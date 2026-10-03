## Denitrification --------------------------------------------------------------

#' Simplified denitrification rate
#'
#' \code{n_deni = k_deni * f_temp * f_water * NO3 / (NO3 + N_half)}
#' (manual eq. 185), with the moisture response of eq. 186
#' (see \code{\link{f_water_denitrif}}).
#'
#' @param no3 nitrate concentration (g N m-3).
#' @param kdeni potential denitrification rate (g N m-2 d-1).
#' @param f_temp temperature response factor.
#' @param f_water moisture response factor.
#' @param n_half nitrate concentration at half saturation (g N m-3).
#' @return Denitrification rate (g N m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 59.
#' @export
denitrif_simplified <- function(no3, kdeni, f_temp, f_water, n_half) {
  kdeni * f_temp * f_water * no3 / (no3 + n_half)
}

#' Microbiological denitrification (4-step sequential reduction)
#'
#' Denitrifier growth/death and the sequential reduction
#' NO3- -> NO2- -> NO -> N2O -> N2 with competitive Michaelis-Menten
#' kinetics (manual eq. 194-198):
#' \itemize{
#'   \item relative growth per step:
#'     \code{dg_i = gd_i * f(DOC) * Ni / (Ni + Ni50)} (eq. 195-196)
#'   \item \code{dg = sum(dg_i) * Bd}; \code{dd = Mc * Yc * Bd};
#'     \code{rc = (dg / Yc + Mc) * Bd} (eq. 194)
#'   \item \code{Bd_new = Bd + dg - dd} (eq. 197)
#'   \item consumption per step:
#'     \code{dc_i = (dg_i / Yc_i + MN_i * Ni / N_total) * f_temp *
#'       f_pH_i * Bd} (eq. 198)
#' }
#' The returned \code{consumption} vector holds the reduction rates of
#' NO3-, NO2-, NO and N2O in the anaerobic fraction; N2O consumption is
#' the reduction of N2O to N2, so net N2O production is
#' \code{consumption[3] - consumption[4]} plus nitrification sources.
#'
#' @param bd_prev denitrifier biomass at previous step (g C m-2).
#' @param n_oxides named numeric vector of N-oxide concentrations in the
#'   anaerobic fraction (g N m-3), in order
#'   \code{c(no3, no2, no, n2o)}.
#' @param doc dissolved organic C concentration (g C m-3).
#' @param params list with:
#'   \itemize{
#'     \item \code{gd}: max gross growth rates per step (d-1, length 4)
#'     \item \code{ni50}: half-saturation N-oxide concentration
#'       (g N m-3, same for all steps per manual)
#'     \item \code{doc_km50}: Michaelis constant for DOC (g C m-3)
#'     \item \code{yc}: max growth yield on DOC, default 0.503
#'       (van Verseveld et al., 1977)
#'     \item \code{yc_i}: max growth yields per N oxide (g C g-1 N,
#'       length 4)
#'     \item \code{mc}: maintenance coefficient on C (d-1)
#'     \item \code{mn_i}: maintenance coefficients on N oxides
#'       (length 4)
#'     \item \code{f_temp}: temperature response factor
#'     \item \code{f_ph}: pH response factors per step (length 4,
#'       see \code{\link{f_ph_denitrif}})
#'   }
#' @return A list with \code{biomass}, \code{growth}, \code{death},
#'   \code{c_consumption} and \code{consumption} (named numeric vector
#'   of the four reduction rates).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 62-63.
#' @export
denitrif_microbial <- function(bd_prev, n_oxides, doc, params) {
  n_oxides <- as.numeric(n_oxides)
  if (length(n_oxides) != 4L)
    stop("n_oxides must have length 4: c(no3, no2, no, n2o)")
  yc <- if (!is.null(params$yc)) params$yc else 0.503

  f_doc <- michaelis_menten(doc, params$doc_km50)
  fd_n <- n_oxides / (n_oxides + params$ni50)          # eq. 196
  dg_i <- params$gd * f_doc * fd_n                    # eq. 195

  dg <- sum(dg_i) * bd_prev
  dd <- params$mc * yc * bd_prev                       # eq. 194
  rc <- (dg / yc + params$mc) * bd_prev                # eq. 194
  bd_new <- max(bd_prev + dg - dd, 0)                  # eq. 197

  n_total <- sum(n_oxides)
  share <- if (n_total > 0) n_oxides / n_total else rep(0, 4)
  dc_i <- (dg_i / params$yc_i + params$mn_i * share) *
    params$f_temp * params$f_ph * bd_prev             # eq. 198
  names(dc_i) <- c("no3", "no2", "no", "n2o")

  list(biomass = bd_new, growth = dg, death = dd,
       c_consumption = rc, consumption = dc_i)
}
