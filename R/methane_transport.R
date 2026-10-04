
## Methane transport and ebullition (manual eq. 214-215) --------------------------

#' Plant-mediated methane transport
#'
#' \code{Q_plant(z) = a_m * f_root(z) * D_a / tau^2 * W_leaf *
#'   (CH4Con - CH4air) / z} (manual eq. 214), after Susiluoto et al. (2018).
#' Transport through aerenchyma bypasses the oxidised rhizosphere and is the
#' dominant emission pathway in flooded rice.
#'
#' @param a_m cross-sectional area of root endings per root dry biomass
#'   (m2 g-1, manual default 0.081e-3).
#' @param f_root fraction of root biomass in the soil layer (-).
#' @param d_a effective diffusion coefficient of CH4 through root
#'   aerenchyma (m2 s-1); default 2e-6. Molecular diffusion in water is
#'   ~1.5e-9, but gas-phase transport through aerenchyma is orders of
#'   magnitude faster; 2e-6 is an effective literature-typical value
#'   (Susiluoto et al. 2018) -- calibrate to site.
#' @param tau root tortuosity (-, manual default 1.5).
#' @param w_leaf leaf dry matter (g m-2).
#' @param ch4_con,ch4_air CH4 concentration in the soil layer and in the
#'   atmosphere (g CH4 m-3); atmospheric default 1.4e-3 (~1.9 ppmv).
#' @param z mid-depth of the soil layer (m).
#' @return CH4 transport rate (g CH4 m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66;
#'   Susiluoto et al. (2018).
#' @export
ch4_plant_transport <- function(a_m = 0.081e-3, f_root, d_a = 2e-6,
                                tau = 1.5, w_leaf, ch4_con,
                                ch4_air = 1.4e-3, z) {
  q_s <- a_m * f_root * d_a / tau^2 * w_leaf * (ch4_con - ch4_air) / z
  pmax(0, q_s) * 86400  # m2 s-1 -> per day
}

#' Methane ebullition (simplified)
#'
#' Manual eq. 215 (Susiluoto et al. 2018) releases CH4 when the summed
#' partial pressures of soil gases exceed the total pressure at depth,
#' which requires tracking CH4, CO2, O2 and N2 partial pressures.
#' This lite version keeps the manual's rate constant
#' (\code{r_ebu = ln(2)/1800} s-1) but triggers ebullition on CH4 alone:
#' dissolved CH4 above Henry's-law solubility is released as bubbles.
#'
#' @param ch4_con CH4 concentration in the soil layer (g CH4 m-3 soil).
#' @param theta volumetric water content (m3 m-3).
#' @param ch4_sol solubility of CH4 in soil water (g CH4 m-3 water);
#'   default 22 (~20 C, Henry's law).
#' @param r_ebu ebullition rate constant (s-1, manual default ln(2)/1800).
#' @return Ebullition flux (g CH4 m-3 soil d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66-67;
#'   Susiluoto et al. (2018).
#' @export
ch4_ebullition <- function(ch4_con, theta, ch4_sol = 22,
                           r_ebu = log(2) / 1800) {
  excess <- pmax(0, ch4_con - ch4_sol) * theta
  excess * (1 - exp(-r_ebu * 86400))  # per day; ~= full excess release
}

#' Daily layer methane balance (lite)
#'
#' Simplified daily CH4 budget for one soil layer, combining manual
#' eq. 210-215 with a single CH4 concentration pool
#' (\code{ch4_con}, g CH4 m-3 soil):
#' \enumerate{
#'   \item production from the anoxic fraction of root respiration
#'     (eq. 213 via \code{\link{ch4_production}}),
#'   \item rhizospheric + soil methanotrophic oxidation
#'     (eq. 210-211),
#'   \item plant aerenchyma transport (eq. 214),
#'   \item ebullition of super-saturated CH4 (simplified eq. 215),
#'   \item slow diffusion toward the atmospheric concentration
#'     (upland soils can thus show net CH4 uptake).
#' }
#' Sinks are capped at the available pool so mass is conserved.
#' O2 is not tracked as a state: \code{o2_con = o2_air * (1 - wfps)}
#' with \code{o2_air = 300} g m-3.
#'
#' The methanogenic substrate (\code{r_substrate}) is the anoxic
#' respiration rate at the layer (manual's \eqn{R_{root}(z)}): the caller
#' supplies anoxic root + heterotrophic respiration (g CO2 m-2 d-1).
#'
#' Oxidation kinetic parameters (\code{vr_max}, \code{vs_max},
#' \code{kr_ch4}, \code{ks_ch4}, \code{ko2}, \code{eta_inhib}) have no
#' manual defaults; the defaults are illustrative literature-typical
#' values -- calibrate to site before quantitative use.
#'
#' @param ch4_con current layer CH4 concentration (g CH4 m-3 soil).
#' @param t_soil soil temperature (degrees C).
#' @param wfps water-filled pore space (-).
#' @param theta volumetric water content (m3 m-3).
#' @param depth_m layer thickness (m).
#' @param r_substrate anoxic respiration driving methanogenesis
#'   (g CO2 m-2 d-1); typically (root + heterotrophic respiration) x
#'   anoxic fraction.
#' @param w_root root dry matter in the layer (g m-2).
#' @param w_leaf leaf dry matter (g m-2).
#' @param f_root fraction of total root biomass in this layer (-).
#' @param z_mid mid-depth of the layer (m).
#' @param bulk_density soil bulk density (g cm-3).
#' @param vr_max,vs_max,kr_ch4,ks_ch4,ko2,eta_inhib oxidation/production
#'   kinetic parameters (see details).
#' @param k_diff first-order soil-atmosphere CH4 exchange rate (d-1);
#'   default 0.05.
#' @param ... further arguments passed to \code{\link{ch4_plant_transport}}
#'   (e.g. \code{d_a}, \code{a_m}, \code{tau}).
#' @return A list with \code{ch4_con} (updated pool), \code{production},
#'   \code{oxidation}, \code{plant_transport}, \code{ebullition},
#'   \code{diffusion} and \code{emission} (net soil-to-atmosphere flux,
#'   g CH4 m-2 d-1; negative = net uptake).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 65-67.
#' @export
ch4_lite_step <- function(ch4_con, t_soil, wfps, theta, depth_m,
                          r_substrate, w_root, w_leaf, f_root, z_mid,
                          bulk_density = 1.35,
                          vr_max = 0.005, vs_max = 5e-6,
                          kr_ch4 = 10, ks_ch4 = 10, ko2 = 5,
                          eta_inhib = 0.1, k_diff = 0.05, ...) {
  ch4_air <- 1.4e-3
  o2_con  <- 300 * pmax(0, 1 - wfps)

  ## production from anoxic respiration (eq. 213)
  prod <- ch4_production(r_substrate, f_ch4_co2 = 0.3,
                        eta_inhib = eta_inhib, o2_con = o2_con)

  ## sinks evaluated at the current pool concentration
  ft      <- f_temp_ch4(t_soil)
  r_moist <- min(1, wfps)
  ox_rhizo <- ch4_oxidation_rhizo(vr_max, ft, r_moist, w_root,
                                 ch4_con, o2_con, kr_ch4, ko2)
  ## soil methanotrophs: g dry soil m-2 = bulk_density * depth
  ox_soil  <- ch4_oxidation_soil(vs_max, ft, r_moist,
                                bulk_density * 1e6 * depth_m,
                                ch4_con, o2_con, ks_ch4, ko2)
  q_plant  <- ch4_plant_transport(f_root = f_root, w_leaf = w_leaf,
                                 ch4_con = ch4_con, z = z_mid, ...)
  q_ebu    <- ch4_ebullition(ch4_con, theta) * depth_m  # -> m-2 d-1
  q_diff   <- k_diff * (ch4_con - ch4_air) * depth_m    # -> m-2 d-1

  ## mass-conserving update: sinks cannot exceed pool + production
  avail   <- ch4_con * depth_m + prod
  sinks   <- ox_rhizo + ox_soil + q_plant + q_ebu + pmax(0, q_diff)
  if (sinks > avail && sinks > 0) {
    f <- avail / sinks
    ox_rhizo <- ox_rhizo * f; ox_soil <- ox_soil * f
    q_plant <- q_plant * f; q_ebu <- q_ebu * f
    q_diff <- if (q_diff > 0) q_diff * f else q_diff
  }
  ch4_con_new <- max(0, (avail - (ox_rhizo + ox_soil + q_plant +
                                   q_ebu + pmax(0, q_diff)) +
                         pmin(0, q_diff)) / depth_m)

  list(ch4_con = ch4_con_new,
       production = prod,
       oxidation = ox_rhizo + ox_soil,
       plant_transport = q_plant,
       ebullition = q_ebu,
       diffusion = q_diff,
       emission = q_plant + q_ebu + q_diff)
}
