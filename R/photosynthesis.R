## Photosynthesis ------------------------------------------------------------------
## Farquhar-type leaf photosynthesis (C3) and Yin & Struik C4 model,
## after SPACSYS technical manual (Wu, 2022, ver. 6.00), ch. 2.2, p. 21-26.
## NOTE on scope: the manual solves the coupled A-gs system with a cubic
## equation (Yin & Struik 2009, via Press et al. 2007); here Ci is obtained
## from a Ci/Ca ratio (standard, robust simplification) and Cc = Ci
## (infinite mesophyll conductance). The cubic solution is on the roadmap.

R_GAS <- 8.314  # J mol-1 K-1

#' Arrhenius temperature response (25 C normalised)
#'
#' \code{X = X25 * exp((1/298 - 1/(273 + Tl)) * E / R)} (manual p. 24).
#' Used for \code{Rd}, \code{GammaStar}, \code{Vcmax}, \code{Kmc},
#' \code{Kmo}, \code{u_oc}.
#'
#' @param x25 parameter value at 25 C.
#' @param E activation energy (J mol-1).
#' @param t_leaf leaf temperature (degrees C).
#' @return Parameter value at leaf temperature.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 24.
#' @export
arrhenius_25 <- function(x25, E, t_leaf) {
  x25 * exp((1 / 298 - 1 / (273 + t_leaf)) * E / R_GAS)
}

#' Modified Arrhenius temperature response
#'
#' Adds high-temperature deactivation (manual p. 25). Used for
#' \code{Jmax}, \code{epsilon_p}, \code{gm}, \code{gbs}.
#'
#' @param x25 parameter value at 25 C.
#' @param E activation energy (J mol-1).
#' @param D deactivation energy (J mol-1).
#' @param S entropy term (J mol-1 K-1).
#' @param t_leaf leaf temperature (degrees C).
#' @return Parameter value at leaf temperature.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 25.
#' @export
arrhenius_25_mod <- function(x25, E, D, S, t_leaf) {
  tk <- 273 + t_leaf
  x25 * exp((1 / 298 - 1 / tk) * E / R_GAS) *
    (1 + exp(S - D / (298 * R_GAS))) / (1 + exp(S - D / (tk * R_GAS)))
}

#' Potential electron transport rate
#'
#' Non-rectangular hyperbola (Evans & Farquhar, 1991; manual p. 21):
#' \code{J = (I2 + Jmax - sqrt((I2 + Jmax)^2 - 4*theta*I2*Jmax)) / (2*theta)}.
#'
#' @param i2 electron-transport photon flux (umol m-2 s-1).
#' @param jmax maximum electron transport rate (umol m-2 s-1).
#' @param theta curvature parameter, default 0.7.
#' @return J (umol m-2 s-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 21.
#' @export
electron_transport_rate <- function(i2, jmax, theta = 0.7) {
  (i2 + jmax - sqrt((i2 + jmax)^2 - 4 * theta * i2 * jmax)) / (2 * theta)
}

#' PSII electron flux from absorbed PPFD
#'
#' \code{I2 = I0 * Phi2LL * (1 - Sp) / (1 - Sp + r2_1)} (manual p. 21).
#' The manual's printed denominator was garbled; restored from context.
#'
#' @param i0 photon flux density absorbed by leaf pigments
#'   (umol photon m-2 s-1).
#' @param phi2ll quantum efficiency of PSII electron transport at low
#'   light, default 0.85 (mol mol-1).
#' @param sp spectral imbalance parameter, default 0.
#' @param r2_1 leaf reflectance coefficient, default 0.
#' @return I2 (umol m-2 s-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 21.
#' @export
psii_electron_flux <- function(i0, phi2ll = 0.85, sp = 0, r2_1 = 0) {
  i0 * phi2ll * (1 - sp) / (1 - sp + r2_1)
}

#' C3 leaf photosynthesis (Farquhar biochemical model)
#'
#' Rubisco-limited (\code{Ac}), electron-transport-limited (\code{Aj})
#' and triose-phosphate-limited (\code{Ap}) rates (Farquhar et al., 1980;
#' Sharkey, 1985; manual p. 21):
#' \itemize{
#'   \item \code{Ac = Vcmax*(Cc - Gs)/(Cc + Kmc*(1 + Oi/Kmo))}
#'   \item \code{Aj = (1 - f_psdeudo)/(4*(1 - f_cyc)) * J * (Cc - Gs)/(Cc + 2*Gs)}
#'   \item \code{Ap = 3*Tu/(1 - Gs/Ci)}
#'   \item \code{A = (1 - Gs/Ci) * min(Ac, Aj, Ap) - Rd}
#' }
#' (\code{Gs} = \code{gamma_star}). The outer \code{(1 - Gs/Ci)} factor is
#' as printed in the manual (non-standard vs. textbook Farquhar).
#'
#' @param vcmax maximum Rubisco carboxylation rate (umol m-2 s-1).
#' @param j electron transport rate from
#'   \code{\link{electron_transport_rate}} (umol m-2 s-1).
#' @param rd day respiration (umol m-2 s-1).
#' @param gamma_star CO2 compensation point without dark respiration
#'   (umol mol-1).
#' @param kmc Rubisco Michaelis constant for CO2 (umol mol-1).
#' @param kmo Rubisco Michaelis constant for O2 (umol mol-1).
#' @param cc CO2 partial pressure at carboxylation site (umol mol-1).
#' @param ci intercellular CO2 (umol mol-1).
#' @param oi intercellular O2 (umol mol-1), default 210000.
#' @param tu triose-phosphate utilisation rate (umol m-2 s-1).
#' @param f_cyc fraction of PSI electron flow in cyclic transport,
#'   default 0.2.
#' @param f_psdeudo fraction in pseudocyclic transport, default 0.
#' @return A list with \code{ac}, \code{aj}, \code{ap}, \code{a} and
#'   \code{limitation} ("rubisco", "electron" or "tpu").
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 21;
#'   Farquhar et al. (1980).
#' @export
farquhar_c3 <- function(vcmax, j, rd, gamma_star, kmc, kmo, cc, ci,
                        oi = 210000, tu, f_cyc = 0.2, f_psdeudo = 0) {
  ac <- vcmax * (cc - gamma_star) / (cc + kmc * (1 + oi / kmo))
  aj <- (1 - f_psdeudo) / (4 * (1 - f_cyc)) * j *
    (cc - gamma_star) / (cc + 2 * gamma_star)
  ap <- 3 * tu / (1 - gamma_star / ci)
  rates <- c(rubisco = ac, electron = aj, tpu = ap)
  lim <- names(which.min(rates))
  a <- (1 - gamma_star / ci) * min(rates) - rd
  list(ac = ac, aj = aj, ap = ap, a = max(a, 0), limitation = lim)
}

#' C3 leaf photosynthesis with temperature responses
#'
#' Convenience wrapper: temperature-dependent parameters from
#' \code{\link{arrhenius_25}} / \code{\link{arrhenius_25_mod}} (Bernacchi
#' et al. defaults for activation energies, used because the manual's
#' parameter table was not in the extracted text), \code{Ci = ci_ca * Ca},
#' \code{Cc = Ci}, \code{Rd = 0.1 * Vcmax} (manual p. 21).
#'
#' @param ca ambient CO2 (umol mol-1).
#' @param ppfd incident photosynthetic photon flux density
#'   (umol m-2 s-1).
#' @param t_leaf leaf temperature (degrees C).
#' @param vcmax25,Jmax25 values at 25 C (umol m-2 s-1).
#' @param ci_ca Ci/Ca ratio, default 0.7.
#' @param ... further arguments to \code{\link{farquhar_c3}}
#'   (\code{tu} defaults to \code{vcmax/8}).
#' @return Same as \code{\link{farquhar_c3}} plus \code{j} and \code{ci}.
#' @export
leaf_photo_c3 <- function(ca, ppfd, t_leaf, vcmax25 = 80, jmax25 = 140,
                          ci_ca = 0.7, ...) {
  vcmax <- arrhenius_25(vcmax25, 58550, t_leaf)
  jmax <- arrhenius_25_mod(jmax25, 43540, 200000, 650, t_leaf)
  rd <- 0.1 * vcmax
  gs <- arrhenius_25(42.75, 37830, t_leaf)
  kmc <- arrhenius_25(404.9, 79430, t_leaf)
  kmo <- arrhenius_25(278400, 36380, t_leaf)  # 278.4 mmol/mol -> umol/mol
  i2 <- psii_electron_flux(ppfd * 0.85)   # ~85% absorbed
  j <- electron_transport_rate(i2, jmax)
  ci <- ci_ca * ca
  dots <- list(...)
  if (is.null(dots$tu)) dots$tu <- vcmax / 8
  res <- do.call(farquhar_c3,
                 c(list(vcmax = vcmax, j = j, rd = rd, gamma_star = gs,
                        kmc = kmc, kmo = kmo, cc = ci, ci = ci), dots))
  res$j <- j; res$ci <- ci
  res
}

#' C4 leaf photosynthesis (Yin & Struik)
#'
#' SPACSYS uses the Yin & Struik (2009) C4 model (manual p. 23-24).
#' PEP carboxylation: \code{Vp = min(ep*Ci, x*J2*z/phi)};
#' ATP factor \code{z = (2 + f_Q - f_cyc)/(h*(1 - f_cyc))};
#' Rubisco/e-transport rates \code{Ac}, \code{Aj} as printed (p. 24).
#' Because enzyme- and electron-transport limitation can each combine
#' with either Vp limitation, four combinations are possible and the
#' minimum is taken; each is solved by fixed-point iteration since
#' \code{Cc} depends on \code{A}:
#' \itemize{
#'   \item PEP-limited: \code{Cc = (1 + ep/gbs)*Ci - (A + Rm)/gbs}
#'   \item e-limited: \code{Cc = Ci + (x*J2*z/phi - A - Rm)/gbs}
#' }
#'
#' @param ci intercellular CO2 (umol mol-1).
#' @param j2 electron transport rate (umol m-2 s-1).
#' @param vcmax,jmax,rd,gamma_star,kmc,kmo C3-like parameters
#'   (temperature-adjusted).
#' @param oi intercellular O2 (umol mol-1), default 210000.
#' @param ep PEP carboxylation efficiency, default 0.6.
#' @param gbs bundle-sheath conductance (mol m-2 s-1), default 0.01.
#' @param f_cyc cyclic electron flow fraction (higher in C4),
#'   default 0.3.
#' @param x ATP fraction for Vp reactions, default 0.4 (manual).
#' @param phi extra ATP per CO2 for the CCM, default 2 (manual).
#' @param f_Q Q-cycle electron fraction, default 1 (manual).
#' @param h H+:ATP ratio, default 4 (manual).
#' @param tol,max_iter fixed-point convergence control.
#' @return A list with \code{a} (umol m-2 s-1), \code{vp}, and
#'   \code{limitation} describing the winning combination.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 23-24;
#'   Yin & Struik (2009).
#' @export
leaf_photo_c4 <- function(ci, j2, vcmax, jmax, rd, gamma_star, kmc, kmo,
                          oi = 210000, ep = 0.6, gbs = 0.01, f_cyc = 0.3,
                          x = 0.4, phi = 2, f_Q = 1, h = 4,
                          tol = 1e-6, max_iter = 100) {
  z <- (2 + f_Q - f_cyc) / (h * (1 - f_cyc))
  vp_cap <- x * j2 * z / phi
  rm <- rd / 2
  solve_combo <- function(rate_fun, cc_fun) {
    a <- 1
    for (k in seq_len(max_iter)) {
      cc <- cc_fun(a)
      a_new <- max(rate_fun(cc) - rd, 0)
      if (abs(a_new - a) < tol) break
      a <- a_new
    }
    a_new
  }
  ac_fun <- function(cc)
    vcmax * (cc - gamma_star) / (cc + kmc * oi / kmo + kmc)
  aj_fun <- function(cc)
    jmax / 4 * (cc - gamma_star) / (cc + 2 * gamma_star)
  cc_pep <- function(a) (1 + ep / gbs) * ci - (a + rm) / gbs
  cc_e <- function(a) ci + (vp_cap - a - rm) / gbs
  combos <- c(
    pep_rubisco = solve_combo(ac_fun, cc_pep),
    pep_et = solve_combo(aj_fun, cc_pep),
    e_rubisco = solve_combo(ac_fun, cc_e),
    e_et = solve_combo(aj_fun, cc_e)
  )
  vp <- min(ep * ci, vp_cap)
  i <- which.min(combos)
  list(a = combos[i], vp = vp, limitation = names(combos)[i])
}

#' Solar elevation angle
#'
#' Standard astronomical calculation (needed for hourly PPFD).
#'
#' @param lat latitude in degrees (north positive).
#' @param doy day of year (1-366).
#' @param hour local solar hour (0-24).
#' @return sin of the solar elevation angle (negative at night).
#' @export
solar_sin_elev <- function(lat, doy, hour) {
  decl <- -23.44 * cos(2 * pi * (doy + 10) / 365) * pi / 180
  lat_r <- lat * pi / 180
  ha <- (hour - 12) * 15 * pi / 180
  sin(lat_r) * sin(decl) + cos(lat_r) * cos(decl) * cos(ha)
}

#' Hourly photosynthetic photon flux density
#'
#' \code{PPFD_i = 2.07e6 * SR * sin(h_i)/sum(sin(h_i))} (manual p. 25),
#' with \code{PAR = 0.486 * SR} (MJ m-2 d-1).
#'
#' @param sr_mj daily shortwave solar irradiation (MJ m-2 d-1).
#' @param lat latitude in degrees.
#' @param doy day of year.
#' @return Named numeric vector of hourly PPFD (umol m-2 s-1),
#'   hours 0-23.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 25.
#' @export
ppfd_hourly <- function(sr_mj, lat, doy) {
  hours <- 0:23
  s <- vapply(hours, function(hh) solar_sin_elev(lat, doy, hh + 0.5),
              numeric(1))
  s[s < 0] <- 0
  ppfd <- 2.07e6 * sr_mj * s / sum(s) / 3600
  names(ppfd) <- paste0("h", hours)
  ppfd
}

#' Canopy extinction coefficient
#'
#' \code{k_ext = sqrt(chi^2 + tan^2(theta))*cos(theta) /
#'   (chi + 1.744*(chi + 1.183)^-0.733)} (manual p. 26; Norman, 1980).
#'
#' @param theta solar zenith angle in radians.
#' @param chi ellipsoid leaf-angle parameter (1 = spherical).
#' @return Extinction coefficient.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 26.
#' @export
canopy_kext <- function(theta, chi = 1) {
  sqrt(chi^2 + tan(theta)^2) * cos(theta) /
    (chi + 1.744 * (chi + 1.183)^-0.733)
}

#' Sunlit and shaded leaf area
#'
#' \code{L_sun = exp(-k*Lca/cos(theta))*cos(theta)/k_ext},
#' \code{L_shade = Lca - L_sun} (manual p. 25-26; Norman, 1980;
#' Forseth & Norman, 1993).
#'
#' @param lai green leaf area index of the canopy layer.
#' @param theta solar zenith angle in radians.
#' @param chi leaf-angle parameter, default 1.
#' @param k extinction-related coefficient, default 0.5.
#' @return Named vector \code{c(sun, shade)}.
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 25-26.
#' @export
sun_shade_lai <- function(lai, theta, chi = 1, k = 0.5) {
  kext <- canopy_kext(theta, chi)
  l_sun <- exp(-k * lai / cos(theta)) * cos(theta) / kext
  l_sun <- min(l_sun, lai)
  c(sun = l_sun, shade = lai - l_sun)
}

#' Canopy-level daily photosynthesis (C3)
#'
#' Hourly sun/shade integration over the day: for each daylight hour,
#' sunlit leaves receive direct + diffuse PPFD and shaded leaves receive
#' diffuse PPFD (manual p. 26:
#' \code{I_sun = I_dir*k/cos(theta) + I_shade},
#' \code{I_shade = I_diff*exp(-0.5*Lca^0.7) + I_scat}).
#' Leaf rates from \code{\link{leaf_photo_c3}}.
#'
#' @param lai canopy green leaf area index.
#' @param sr_mj daily shortwave irradiation (MJ m-2 d-1).
#' @param lat latitude in degrees.
#' @param doy day of year.
#' @param t_leaf leaf temperature (degrees C, daily mean).
#' @param ca ambient CO2 (umol mol-1), default 420.
#' @param frac_diffuse fraction of diffuse PPFD, default 0.3.
#' @param ... passed to \code{\link{leaf_photo_c3}}.
#' @return A list with \code{a_canopy} (mol CO2 m-2 d-1),
#'   \code{a_sun}, \code{a_shade} (hourly means, umol m-2 s-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 25-26.
#' @export
canopy_photo_c3 <- function(lai, sr_mj, lat, doy, t_leaf, ca = 420,
                            frac_diffuse = 0.3, ...) {
  ppfd <- ppfd_hourly(sr_mj, lat, doy)
  a_sun_h <- a_shade_h <- numeric(24)
  for (hh in 0:23) {
    if (ppfd[hh + 1] <= 0) next
    theta <- acos(max(solar_sin_elev(lat, doy, hh + 0.5), 0))
    ss <- sun_shade_lai(lai, theta)
    i_dir <- ppfd[hh + 1] * (1 - frac_diffuse)
    i_diff <- ppfd[hh + 1] * frac_diffuse
    i_scat <- 0.1 * i_diff
    i_shade <- i_diff * exp(-0.5 * lai^0.7) + i_scat
    i_sun <- i_dir * 0.5 / cos(theta) + i_shade
    a_sun_h[hh + 1] <- leaf_photo_c3(ca, i_sun, t_leaf, ...)$a
    a_shade_h[hh + 1] <- leaf_photo_c3(ca, i_shade, t_leaf, ...)$a
  }
  ss_day <- sun_shade_lai(lai, acos(max(solar_sin_elev(lat, doy, 12), 0.05)))
  a_canopy <- (mean(a_sun_h) * ss_day["sun"] +
               mean(a_shade_h) * ss_day["shade"]) * 3600 * 24 / 1e6
  list(a_canopy = unname(a_canopy),
       a_sun = mean(a_sun_h), a_shade = mean(a_shade_h))
}
