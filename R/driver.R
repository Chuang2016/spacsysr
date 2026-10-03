## Daily driver coupling the modules ----------------------------------------------
## Simplified teaching/research scaffold: daily time step, layered soil,
## couples water -> decomposition -> mineralisation -> nitrification ->
## denitrification -> gaseous losses. NOT a full SPACSYS port (see README).

#' Default parameter list
#'
#' Starting values for \code{\link{spacsys_run}}, drawn from the manual
#' where given and otherwise set as clearly-marked placeholders to
#' calibrate. Units are documented per element.
#'
#' @return A named list of parameters.
#' @export
spacsys_default_params <- function() {
  list(
    ## decomposition (eq. 174-176)
    k_litter = 0.01, k_humus = 0.0005, k_doc = 0.05,   # d-1
    q10_decom = 2, tbase_decom = 20,
    theta_m = 8, delta_theta1 = 10, delta_theta2 = 5,  # %, fw-decom
    e_s = 0.2, k_w = 1,
    humif_frac = 0.3,      # fraction of decomposed litter C -> humus
    cn_litter = 25, cn_humus = 10, cn_microbe = 8,
    mic_yield = 0.4,       # microbial growth yield on decomposed C
    ## simplified nitrification / denitrification
    knitri = 0.2,          # d-1
    kdeni = 0.5,           # g N m-2 d-1
    n_half = 5,            # g N m-3
    q10_n = 2, tbase_n = 20,
    delta_theta_denit = 15,                    # %, eq. 186; starting value -
                             # highly soil-type dependent (manual)
    n2o_frac_denitrif = 0.1,  # placeholder: N2O/(N2O+N2) of simplified
                             # denitrification (manual gives no split)
    ## nitrification gas fractions (eq. 200-201)
    f_no_max = 0.005, f_n2o_max = 0.005,
    ## microbial nitrification (eq. 187-193)
    gnitr = 0.5, dnitr = 0.05, fe = 0.6, nnmax = 0.5,
    doc_km50 = 50, no3_km50 = 5, nh4_km50 = 5,  # g m-3
    ## microbial denitrification (eq. 194-198)
    gd = c(0.8, 0.6, 0.5, 0.3),  # d-1 per step
    ni50 = 2,                    # g N m-3, all steps (manual)
    yc = 0.503, yc_i = c(0.4, 0.4, 0.4, 0.4),
    mc = 0.02, mn_i = c(0.01, 0.01, 0.01, 0.01),
    ## methane (eq. 210-213)
    ch4_on = FALSE,
    vr_max = 0.01, vs_max = 1e-4, kr_ch4 = 1, ks_ch4 = 1, ko2 = 1,
    anoxic_resp = 0.5, f_ch4_co2 = 0.3, eta_inhib = 0.01,
    ## misc
    n2o_emit_frac = 0.9,   # daily fraction of N2O pool emitted
    wfps_crit = 0.9, wfps_range = 0.3
  )
}

#' Simplified daily SPACSYS-biogeochemistry driver
#'
#' Runs a daily loop over soil layers coupling the package modules:
#' soil water -> WFPS/anaerobic fraction -> organic matter decomposition
#' (+ simplified net mineralisation) -> nitrification -> denitrification ->
#' N2O/NO/NH3/CH4 losses and nitrate leaching. Fertiliser/slurry events
#' can be supplied via \code{n_inputs}.
#'
#' This is a research scaffold with first-order pool bookkeeping, not a
#' full SPACSYS simulation (no Richards water flow, no plant growth
#' feedback, simplified mineralisation).
#'
#' @param weather data.frame with \code{date} (Date), \code{tavg}
#'   (deg C), \code{precip} (mm d-1), \code{pet} (mm d-1); optional
#'   \code{tsoil} (deg C, defaults to \code{tavg}).
#' @param soil data.frame, one row per layer, with \code{depth_mm},
#'   \code{bulk_density} (g cm-3), \code{ph}, \code{fc}, \code{wp},
#'   \code{sat} (fractions), \code{theta_init} (fraction),
#'   \code{c_litter}, \code{c_humus}, \code{c_doc} (g C m-2),
#'   \code{nh4}, \code{no3} (g N m-2), \code{bn}, \code{bd}
#'   (microbial biomass, g C m-2; used with \code{method = "microbial"}).
#' @param params parameter list from \code{\link{spacsys_default_params}}.
#' @param method \code{"simplified"} or \code{"microbial"} for the
#'   nitrification/denitrification formulation.
#' @param n_inputs optional data.frame with \code{date} and any of
#'   \code{nh4_add}, \code{no3_add}, \code{tan_slurry} (g N m-2,
#'   applied to the top layer), \code{lai} (for spreading loss).
#' @return A data.frame with one row per day: \code{date}, \code{n2o},
#'   \code{no}, \code{nh3}, \code{ch4} (g N or C m-2 d-1),
#'   \code{n_leached}, \code{n_mineralised}, \code{n_nitrified},
#'   \code{n_denitrified}, \code{co2_c} (g C m-2 d-1), plus mean
#'   \code{wfps_top}.
#' @export
spacsys_run <- function(weather, soil, params = spacsys_default_params(),
                        method = c("simplified", "microbial"),
                        n_inputs = NULL) {
  method <- match.arg(method)
  n_layer <- nrow(soil)
  depth_m <- soil$depth_mm / 1000

  ## state vectors (per layer)
  theta <- soil$theta_init
  c_litter <- soil$c_litter; c_humus <- soil$c_humus; c_doc <- soil$c_doc
  nh4 <- soil$nh4; no3 <- soil$no3
  no2 <- rep(0, n_layer); no <- rep(0, n_layer); n2o_pool <- rep(0, n_layer)
  bn <- soil$bn; bd <- soil$bd
  tan_surf <- 0; w_w_surf <- 0

  if (!is.null(n_inputs)) n_inputs$date <- as.Date(n_inputs$date)
  weather$date <- as.Date(weather$date)
  if (!"tsoil" %in% names(weather)) weather$tsoil <- weather$tavg

  n_day <- nrow(weather)
  out <- data.frame(
    date = weather$date, n2o = 0, no = 0, nh3 = 0, ch4 = 0,
    n_leached = 0, n_mineralised = 0, n_nitrified = 0,
    n_denitrified = 0, co2_c = 0, wfps_top = 0
  )

  for (d in seq_len(n_day)) {
    tavg <- weather$tavg[d]; tsoil <- weather$tsoil[d]

    ## --- fertiliser / slurry events to top layer ----------------------
    if (!is.null(n_inputs)) {
      ev <- n_inputs[n_inputs$date == weather$date[d], , drop = FALSE]
      if (nrow(ev) > 0) {
        if ("nh4_add" %in% names(ev)) nh4[1] <- nh4[1] + sum(ev$nh4_add)
        if ("no3_add" %in% names(ev)) no3[1] <- no3[1] + sum(ev$no3_add)
        if ("tan_slurry" %in% names(ev) && sum(ev$tan_slurry) > 0) {
          tan_add <- sum(ev$tan_slurry)
          lai <- if ("lai" %in% names(ev)) ev$lai[1] else 2
          out$nh3[d] <- out$nh3[d] +
            nh3_spreading(tan_add, lai, w_w = tan_add * 20)
          tan_surf <- tan_surf + tan_add * 0.98
          w_w_surf <- w_w_surf + tan_add * 20
        }
      }
    }

    ## --- soil water ----------------------------------------------------
    w <- soil_water_step(theta, weather$precip[d], weather$pet[d],
                         soil$fc, soil$wp, soil$sat, soil$depth_mm)
    theta <- w$theta
    theta_pct <- theta * 100
    wfps_l <- wfps(theta_pct, soil$bulk_density)
    out$wfps_top[d] <- wfps_l[1]
    fr <- anaerobic_fraction(wfps_l, params$wfps_crit, params$wfps_range)

    f_t <- f_temp_q10(tsoil, q10 = params$q10_n, t_base = params$tbase_n)
    f_td <- f_temp_q10(tsoil, q10 = params$q10_decom,
                       t_base = params$tbase_decom)

    ## --- decomposition + net mineralisation -----------------------------
    for (i in seq_len(n_layer)) {
      fw <- f_water_decom(theta_pct[i], theta_s = soil$sat[i] * 100,
                          theta_m = params$theta_m,
                          delta_theta1 = params$delta_theta1,
                          delta_theta2 = params$delta_theta2,
                          e_s = params$e_s, k_w = params$k_w)
      d_lit <- decomp_rate(c_litter[i], params$k_litter, f_td, fw)
      d_hum <- decomp_rate(c_humus[i], params$k_humus, f_td, fw)
      d_doc <- decomp_rate(c_doc[i], params$k_doc, f_td, fw)
      d_tot <- d_lit + d_hum + d_doc
      ## C fate: humification of litter fraction, rest respired
      to_humus <- d_lit * params$humif_frac
      c_litter[i] <- c_litter[i] - d_lit
      c_humus[i] <- c_humus[i] - d_hum + to_humus
      c_doc[i] <- c_doc[i] - d_doc + d_tot * 0.1
      out$co2_c[d] <- out$co2_c[d] + d_tot - to_humus - d_tot * 0.1
      ## simplified net mineralisation from C:N stoichiometry
      n_rel <- d_lit / params$cn_litter + d_hum / params$cn_humus
      n_imm <- d_tot * params$mic_yield / params$cn_microbe
      n_net <- n_rel - n_imm
      nh4[i] <- max(nh4[i] + n_net, 0)
      out$n_mineralised[d] <- out$n_mineralised[d] + n_net
    }

    ## --- nitrification / denitrification --------------------------------
    for (i in seq_len(n_layer)) {
      conc <- function(pool) pool / depth_m[i]   # g N m-3
      if (method == "simplified") {
        fw_d <- f_water_decom(theta_pct[i], theta_s = soil$sat[i] * 100,
                              theta_m = params$theta_m,
                              delta_theta1 = params$delta_theta1,
                              delta_theta2 = params$delta_theta2)
        n_nit <- nitrif_simplified(conc(nh4[i]), conc(no3[i]),
                                   params$knitri, f_t, fw_d,
                                   f_ph_nitrif(soil$ph[i]))
        n_nit <- min(n_nit * depth_m[i], nh4[i])  # g N m-2 d-1
        nh4[i] <- nh4[i] - n_nit
        no3[i] <- no3[i] + n_nit
        out$n_nitrified[d] <- out$n_nitrified[d] + n_nit

        fw_den <- f_water_denitrif(theta_pct[i],
                                   theta_s = soil$sat[i] * 100,
                                   delta_theta = params$delta_theta_denit)
        n_den <- denitrif_simplified(conc(no3[i]), params$kdeni,
                                     f_t, fw_den, params$n_half)
        n_den <- min(n_den, no3[i])
        no3[i] <- no3[i] - n_den
        n2o_here <- n_den * params$n2o_frac_denitrif
        out$n2o[d] <- out$n2o[d] + n2o_here
        out$n_denitrified[d] <- out$n_denitrified[d] + n_den
        out$no[d] <- out$no[d] + nitrif_no_emission(n_nit, f_t,
                                                   params$f_no_max)
        out$n2o[d] <- out$n2o[d] + nitrif_n2o_emission(n_nit, f_t,
                                                      params$f_n2o_max)
      } else {
        ## microbial: nitrifier biomass + 4-step denitrification
        f_doc <- michaelis_menten(conc(c_doc[i]), params$doc_km50)
        f_no3 <- michaelis_menten(conc(no3[i]), params$no3_km50)
        gr <- nitrifier_growth(bn[i], params$gnitr, params$dnitr,
                               params$fe, f_t, f_water_nitrif(wfps_l[i]),
                               f_ph_nitrif(soil$ph[i]), f_doc, f_no3)
        bn[i] <- gr$biomass
        n_nit <- nitrif_microbial(params$nnmax, bn[i],
                                  f_inhib_nitrif(0), f_t,
                                  f_water_nitrif(wfps_l[i]),
                                  f_ph_nitrif(soil$ph[i]),
                                  michaelis_menten(conc(nh4[i]),
                                                   params$nh4_km50))
        n_nit <- min(n_nit, nh4[i])
        nh4[i] <- nh4[i] - n_nit
        no3[i] <- no3[i] + n_nit
        out$n_nitrified[d] <- out$n_nitrified[d] + n_nit
        out$no[d] <- out$no[d] + nitrif_no_emission(n_nit, f_t,
                                                   params$f_no_max)
        out$n2o[d] <- out$n2o[d] + nitrif_n2o_emission(n_nit, f_t,
                                                      params$f_n2o_max)
        ## anaerobic fraction substrates
        n_ox <- c(no3[i], no2[i], no[i], n2o_pool[i]) /
          depth_m[i] * fr[i]
        den <- denitrif_microbial(
          bd[i], n_ox, conc(c_doc[i]) * fr[i],
          list(gd = params$gd, ni50 = params$ni50,
               doc_km50 = params$doc_km50, yc = params$yc,
               yc_i = params$yc_i, mc = params$mc, mn_i = params$mn_i,
               f_temp = f_t,
               f_ph = vapply(1:4, function(s)
                 f_ph_denitrif(soil$ph[i], s), numeric(1))))
        bd[i] <- den$biomass
        flux <- den$consumption * depth_m[i] * fr[i]  # g N m-2 d-1
        no3[i] <- max(no3[i] - flux["no3"], 0)
        no2[i] <- max(no2[i] + flux["no3"] - flux["no2"], 0)
        no[i] <- max(no[i] + flux["no2"] - flux["no"], 0)
        n2o_pool[i] <- max(n2o_pool[i] + flux["no"] - flux["n2o"], 0)
        out$n_denitrified[d] <- out$n_denitrified[d] + flux["no3"]
        emit <- n2o_pool[i] * params$n2o_emit_frac
        n2o_pool[i] <- n2o_pool[i] - emit
        out$n2o[d] <- out$n2o[d] + emit
      }
    }

    ## --- nitrate leaching with deep drainage ------------------------------
    water_mm <- theta[n_layer] * soil$depth_mm[n_layer]
    if (w$drainage_mm > 0 && water_mm > 0) {
      leach_frac <- min(w$drainage_mm / water_mm, 1)
      leached <- no3[n_layer] * leach_frac
      no3[n_layer] <- no3[n_layer] - leached
      out$n_leached[d] <- leached
    }

    ## --- NH3 after spreading ------------------------------------------------
    if (tan_surf > 0 && w_w_surf > 0) {
      vh <- nh3_after_spreading(tan_surf, w_w_surf,
                                infil = 2, evap = weather$pet[d],
                                precip = weather$precip[d],
                                epsilon = 0.5)
      out$nh3[d] <- out$nh3[d] + vh$n_vol
      tan_surf <- vh$tan_new; w_w_surf <- vh$w_w_new
    }

    ## --- methane (paddy-relevant) --------------------------------------------
    if (isTRUE(params$ch4_on)) {
      ft_ch4 <- f_temp_ch4(tsoil)
      for (i in seq_len(n_layer)) {
        if (fr[i] <= 0) next
        prod <- ch4_production(params$anoxic_resp * fr[i],
                               params$f_ch4_co2,
                               params$eta_inhib, o2_con = 1)
        ox <- ch4_oxidation_soil(params$vs_max, ft_ch4, fr[i],
                                 soil$bulk_density[i],
                                 ch4_con = 1, o2_con = 1,
                                 params$ks_ch4, params$ko2)
        out$ch4[d] <- out$ch4[d] + max(prod - ox, 0)
      }
    }
  }
  out
}

#' Load bundled example data
#'
#' @param name \code{"paddy_weather"} (daily weather for a synthetic
#'   180-day rice season) or \code{"paddy_soil"} (4-layer paddy soil
#'   profile). Both are clearly-marked synthetic teaching examples, not
#'   measured data.
#' @return A data.frame.
#' @export
load_example <- function(name = c("paddy_weather", "paddy_soil")) {
  name <- match.arg(name)
  utils::read.csv(system.file("extdata", paste0(name, ".csv"),
                              package = "spacsysr"),
                   stringsAsFactors = FALSE)
}

#' spacsysr: Core SPACSYS Biogeochemistry in R
#'
#' @description
#' R implementations of the core soil biogeochemical process modules of
#' the SPACSYS model (Wu, 2022, ver. 6.00): response functions,
#' decomposition, nitrification/denitrification, N2O/NO/NH3/CH4
#' emissions, plant respiration, soil water and a daily driver.
#'
#' Start with \code{\link{spacsys_run}} and the N2O vignette.
#' @references Wu, L. (2022). SPACSYS - FARMSYS Technical Manual v6.00.
#'   Rothamsted Research, North Wyke, UK.
#' @keywords internal
"_PACKAGE"
