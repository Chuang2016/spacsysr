## Simplified ("lite") soil carbon & nitrogen step --------------------------------
## Two-pool (litter + humus) first-order decomposition with C:N
## stoichiometric mineralisation/immobilisation, coupled to the package's
## simplified nitrification / denitrification formulations. A
## small-parameter alternative to the full SPACSYS CNP cycling
## (manual ch. 4).

#' Daily lite soil C/N step for one layer
#'
#' Decomposition (\code{\link{decomp_rate}}) of litter and humus pools
#' with temperature (\code{\link{f_temp_q10}}) and moisture
#' (\code{\link{f_water_decom}}) responses; a fraction of decomposed
#' litter C is humified. Net N mineralisation follows C:N
#' stoichiometry: N released from decomposed C minus N required for
#' humus formed (negative values immobilise mineral N). Mineral pools
#' are then updated by plant uptake, simplified nitrification
#' (\code{\link{nitrif_simplified}}) and simplified denitrification
#' (\code{\link{denitrif_simplified}}).
#'
#' @param pools named list with \code{c_litter}, \code{c_humus} (g C m-2),
#'   \code{nh4}, \code{no3} (g N m-2).
#' @param tsoil soil temperature (deg C).
#' @param theta_pct volumetric water content (%).
#' @param sat_pct saturated water content (%).
#' @param ph soil pH.
#' @param depth_m layer thickness (m).
#' @param up_nh4,up_no3 plant uptake from this layer (g N m-2 d-1).
#' @param params parameter list from
#'   \code{\link{spacsys_default_params}}.
#' @return A list with updated \code{pools} and fluxes
#'   (\code{co2_c}, \code{n_mineralised}, \code{n_nitrified},
#'   \code{n_denitrified}, \code{n2o}, \code{no}; g m-2 d-1).
#' @export
soilcn_lite_step <- function(pools, tsoil, theta_pct, sat_pct, ph,
                             depth_m, up_nh4 = 0, up_no3 = 0,
                             params = spacsys_default_params()) {
  f_td <- f_temp_q10(tsoil, q10 = params$q10_decom,
                     t_base = params$tbase_decom)
  fw <- f_water_decom(theta_pct, theta_s = sat_pct,
                      theta_m = params$theta_m,
                      delta_theta1 = params$delta_theta1,
                      delta_theta2 = params$delta_theta2,
                      e_s = params$e_s, k_w = params$k_w)

  ## decomposition + humification
  d_lit <- decomp_rate(pools$c_litter, params$k_litter, f_td, fw)
  d_hum <- decomp_rate(pools$c_humus, params$k_humus, f_td, fw)
  to_humus <- d_lit * params$humif_frac
  c_litter <- pools$c_litter - d_lit
  c_humus <- pools$c_humus - d_hum + to_humus
  co2_c <- (d_lit - to_humus) + d_hum

  ## net mineralisation from C:N stoichiometry (may be negative)
  n_rel <- d_lit / params$cn_litter + d_hum / params$cn_humus
  n_imm <- to_humus / params$cn_humus +
    (d_lit + d_hum) * params$mic_yield / params$cn_microbe
  n_net <- n_rel - n_imm
  nh4 <- max(pools$nh4 + n_net - up_nh4, 0)
  no3 <- max(pools$no3 - up_no3, 0)

  ## nitrification (simplified)
  f_t <- f_temp_q10(tsoil, q10 = params$q10_n, t_base = params$tbase_n)
  conc <- function(x) x / depth_m
  n_nit <- nitrif_simplified(conc(nh4), conc(no3), params$knitri,
                             f_t, fw, f_ph_nitrif(ph))
  n_nit <- min(n_nit * depth_m, nh4)
  nh4 <- nh4 - n_nit
  no3 <- no3 + n_nit
  no_flux <- nitrif_no_emission(n_nit, f_t, params$f_no_max)
  n2o_nit <- nitrif_n2o_emission(n_nit, f_t, params$f_n2o_max)

  ## denitrification (simplified)
  fw_den <- f_water_denitrif(theta_pct, theta_s = sat_pct,
                             delta_theta = params$delta_theta_denit)
  n_den <- denitrif_simplified(conc(no3), params$kdeni,
                               f_t, fw_den, params$n_half)
  n_den <- min(n_den, no3)
  no3 <- no3 - n_den
  n2o_den <- n_den * params$n2o_frac_denitrif

  list(pools = list(c_litter = c_litter, c_humus = c_humus,
                    nh4 = nh4, no3 = no3),
       co2_c = co2_c, n_mineralised = n_net, n_nitrified = n_nit,
       n_denitrified = n_den, n2o = n2o_nit + n2o_den, no = no_flux)
}
