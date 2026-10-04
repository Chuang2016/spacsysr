## Base-R test suite for spacsysr (runs under R CMD check via tests/).
## Uses only stopifnot() so the package keeps zero dependencies.

library(spacsysr)

ok <- function(msg) cat("ok -", msg, "\n")

## --- response functions ------------------------------------------------
stopifnot(all.equal(f_temp_q10(20), 1))
stopifnot(all.equal(f_temp_q10(30, q10 = 2, t_base = 20), 2))
ok("f_temp_q10")

fw <- f_water_decom(c(5, 15, 25, 42, 50), theta_s = 50, theta_m = 8,
                    delta_theta1 = 10, delta_theta2 = 5)
stopifnot(fw[1] == 0, fw[3] == 1, fw[5] < 1, all(fw >= 0 & fw <= 1))
ok("f_water_decom")

stopifnot(all.equal(wfps(50, 1.325), 1))          # theta = porosity -> 1
stopifnot(wfps(25, 1.3, 2.65) > 0.4,
          wfps(25, 1.3, 2.65) < 0.6)
ok("wfps")

stopifnot(all.equal(michaelis_menten(10, 10), 0.5))
stopifnot(michaelis_menten(0, 5) == 0, michaelis_menten(1e6, 5) > 0.999)
ok("michaelis_menten")

stopifnot(f_water_nitrif(0.5) >= 0.6)
stopifnot(all.equal(f_ph_nitrif(6.6), 1))
stopifnot(f_ph_nitrif(4) < f_ph_nitrif(6.6))
ok("nitrification response functions")

stopifnot(all.equal(f_inhib_nitrif(150), 1))      # capped after 120 d
stopifnot(f_inhib_nitrif(0) < 0.1)                # strong inhibition at d=0
ok("f_inhib_nitrif")

fwd <- f_water_denitrif(c(30, 44, 45), theta_s = 45, delta_theta = 10)
stopifnot(fwd[1] == 0, fwd[3] == 1, fwd[2] > 0, fwd[2] < 1)
ok("f_water_denitrif")

ph_seq <- seq(4, 9, by = 1)
stopifnot(all(vapply(1:4, function(s) all(f_ph_denitrif(ph_seq, s) >= 0 &
                                         f_ph_denitrif(ph_seq, s) <= 1),
                     logical(1))))
stopifnot(f_ph_denitrif(6.2, 3) == 1)   # Gaussian peak at pH 6.2
fine <- seq(4, 9, by = 0.1)
stopifnot(which.max(f_ph_denitrif(fine, 3)) == which.min(abs(fine - 6.2)))
ok("f_ph_denitrif")

af <- anaerobic_fraction(c(0.5, 0.75, 0.95))
stopifnot(af[1] == 0, af[3] == 1, af[2] > 0, af[2] < 1)
ok("anaerobic_fraction")

## --- decomposition ------------------------------------------------------
d <- decomp_rate(1000, 0.01, 1, 1)
stopifnot(all.equal(d, 10))
stopifnot(all.equal(decomp_rate(1000, 0.01, 0.5, 0.5, 0.8, 0.9), 2))
ok("decomp_rate")

## --- nitrification ---------------------------------------------------------
n1 <- nitrif_simplified(nh4 = 10, no3 = 2, knitri = 0.2, f_temp = 1,
                        f_water = 1, f_ph = 1, d_since_n = 200)
stopifnot(n1 > 0)
n0 <- nitrif_simplified(nh4 = 1, no3 = 5, knitri = 0.2, f_temp = 1,
                        f_water = 1, f_ph = 1)
stopifnot(n0 == 0)                                # NH4 <= NO3 -> no nitrification
ok("nitrif_simplified")

gr <- nitrifier_growth(bn_prev = 1, gnitr = 0.5, dnitr = 0.05, fe = 0.6,
                       f_temp = 1, f_water = 1, f_ph = 1,
                       f_doc = 0.5, f_no3 = 0.5)
stopifnot(gr$biomass > 0, gr$growth > 0, gr$death > 0, gr$respiration > 0)
ok("nitrifier_growth")

nm <- nitrif_microbial(0.5, 1, 1, 1, 1, 1, 0.5)
stopifnot(all.equal(nm, 0.25))
ok("nitrif_microbial")

## --- denitrification ---------------------------------------------------------
ds <- denitrif_simplified(no3 = 5, kdeni = 0.5, f_temp = 1, f_water = 1,
                          n_half = 5)
stopifnot(all.equal(ds, 0.25))
ok("denitrif_simplified")

dm <- denitrif_microbial(
  bd_prev = 1, n_oxides = c(no3 = 10, no2 = 1, no = 0.5, n2o = 0.2),
  doc = 100,
  params = list(gd = c(0.8, 0.6, 0.5, 0.3), ni50 = 2, doc_km50 = 50,
                yc = 0.503, yc_i = rep(0.4, 4), mc = 0.02,
                mn_i = rep(0.01, 4), f_temp = 1, f_ph = rep(1, 4)))
stopifnot(dm$biomass > 0, all(dm$consumption >= 0),
          length(dm$consumption) == 4)
ok("denitrif_microbial")

## --- gaseous ------------------------------------------------------------------
stopifnot(all.equal(nitrif_n2o_emission(2, 1, 0.01), 0.02))
stopifnot(all.equal(nitrif_no_emission(2, 1, 0.01), 0.02))
dp <- penman_diffusivity(0.2, 20)
stopifnot(dp > 0, dp < 2.6e-5)
stopifnot(all.equal(nox_emission(1e-5, 3), 3e-5))
ok("gaseous emissions")

## --- volatilisation --------------------------------------------------------------
v1 <- nh3_spreading(tan = 10, lai = 2, w_w = 2000)
stopifnot(all.equal(v1, 0.02 * 10 + 200 * 10 * 2 / 2000))
v2 <- nh3_after_spreading(tan = 5, w_w = 1000, infil = 2, evap = 3,
                          precip = 0, epsilon = 0.5)
stopifnot(v2$n_vol >= 0, v2$tan_new < 5, v2$w_w_new < 1000)
ok("volatilisation")

## --- methane ----------------------------------------------------------------------
stopifnot(f_temp_ch4(20) > 0)
r1 <- ch4_oxidation_rhizo(0.01, 1, 0.8, 50, ch4_con = 2, o2_con = 5,
                          kr_ch4 = 1, ko2 = 1)
stopifnot(r1 > 0)
s1 <- ch4_oxidation_soil(1e-4, 1, 0.8, 1.3, ch4_con = 2, o2_con = 5,
                         ks_ch4 = 1, ko2 = 1)
stopifnot(s1 > 0)
p1 <- ch4_production(r_root = 2, eta_inhib = 0.01, o2_con = 5)
stopifnot(all.equal(p1, 0.3 * 2 / 1.05))
ok("methane")

## --- plant -------------------------------------------------------------------------
stopifnot(all.equal(maint_respiration(100, q10 = 2, temp_air = 20,
                                      t_base = 20), 100))
stopifnot(all.equal(maint_respiration(100, q10 = 2, temp_air = 30,
                                      t_base = 20), 200))
gr2 <- growth_respiration(10)
stopifnot(all.equal(gr2, (1 / (2.5 * 0.45 * 0.72) - 1) * 10))
ok("plant respiration")

## --- soil water ----------------------------------------------------------------------
sw <- soil_water_step(theta_vol = c(0.4, 0.4), precip_mm = 20, pet_mm = 3,
                      fc = c(0.38, 0.36), wp = c(0.18, 0.17),
                      sat = c(0.5, 0.48), depth_mm = c(100, 150))
stopifnot(all(sw$theta <= c(0.5, 0.48) + 1e-9))
stopifnot(sw$aet_mm > 0, sw$drainage_mm >= 0, sw$runoff_mm >= 0)
ok("soil_water_step")

## --- driver ----------------------------------------------------------------------------
weather <- load_example("paddy_weather")
soil <- load_example("paddy_soil")
stopifnot(nrow(weather) == 180, nrow(soil) == 4)

out_s <- spacsys_run(weather[1:30, ], soil, method = "simplified")
stopifnot(nrow(out_s) == 30, all(out_s$n2o >= 0), all(out_s$no >= 0))
stopifnot(sum(out_s$n_denitrified) > 0)

out_m <- spacsys_run(weather[1:30, ], soil, method = "microbial")
stopifnot(nrow(out_m) == 30, all(out_m$n2o >= 0))
ok("spacsys_run (simplified + microbial)")

## fertiliser event path
ev <- data.frame(date = weather$date[10], nh4_add = 5, no3_add = 2)
out_f <- spacsys_run(weather[1:30, ], soil, method = "simplified",
                     n_inputs = ev)
stopifnot(out_f$n_nitrified[10] >= out_s$n_nitrified[10])
ok("spacsys_run fertiliser events")

cat("\nAll spacsysr tests passed.\n")

## --- v0.2.0: photosynthesis ----------------------------------------------------
stopifnot(all.equal(arrhenius_25(80, 58550, 25), 80))
stopifnot(arrhenius_25(80, 58550, 35) > 80)          # warming accelerates
jm <- arrhenius_25_mod(140, 43540, 200000, 650, 25)
stopifnot(all.equal(jm, 140, tolerance = 0.05))
ok("arrhenius")

jt <- electron_transport_rate(500, 140)
stopifnot(jt > 0, jt < 140)
stopifnot(all.equal(psii_electron_flux(1000, phi2ll = 0.85), 850))
ok("electron transport")

fc3 <- farquhar_c3(vcmax = 80, j = 100, rd = 1, gamma_star = 42.75,
                   kmc = 404.9, kmo = 278400, cc = 280, ci = 280, tu = 10)
stopifnot(fc3$a > 0, fc3$ac > 0, fc3$aj > 0, fc3$ap > 0)
stopifnot(fc3$limitation %in% c("rubisco", "electron", "tpu"))
ok("farquhar_c3")

lp <- leaf_photo_c3(ca = 420, ppfd = 1200, t_leaf = 25)
stopifnot(lp$a > 0, lp$a < 40)
lp_dim <- leaf_photo_c3(ca = 420, ppfd = 100, t_leaf = 25)
stopifnot(lp_dim$a < lp$a, lp_dim$limitation == "electron")
ok("leaf_photo_c3")

c4 <- leaf_photo_c4(ci = 150, j2 = 120, vcmax = 60, jmax = 140, rd = 1,
                    gamma_star = 42.75, kmc = 404.9, kmo = 278400)
stopifnot(c4$a > 0, c4$a < 80)
ok("leaf_photo_c4")

pp <- ppfd_hourly(20, 32, 180)
stopifnot(length(pp) == 24, sum(pp > 0) > 10, max(pp) < 2000)
stopifnot(solar_sin_elev(32, 180, 12) > 0.9)
ss <- sun_shade_lai(3, 0.5)
stopifnot(abs(sum(ss) - 3) < 1e-9, ss["sun"] > 0, ss["shade"] > 0)
cn <- canopy_photo_c3(lai = 3, sr_mj = 20, lat = 32, doy = 180, t_leaf = 25)
stopifnot(cn$a_canopy > 0, cn$a_canopy < 2)
ok("canopy photosynthesis")

## --- v0.2.0: richards + heat -----------------------------------------------------
p_vg <- list(retention = "vg", theta_r = 0.05, theta_s = 0.45,
             alpha = 0.02, n = 1.5, k_sat = 0.5, k_min = 1e-6)
th <- vg_retention(c(0, 100, 10000), 0.02, 1.5, 0.05, 0.45)
stopifnot(all.equal(th[1], 0.45), th[2] < 0.45, th[3] > 0.05)
th_bc <- bc_retention(c(10, 100), psia = 20, lambda = 0.4,
                      theta_r = 0.05, theta_s = 0.45)
stopifnot(all.equal(th_bc[1], 0.45), th_bc[2] < 0.45)
stopifnot(moisture_capacity(100, p_vg) < 0)
k1 <- unsat_conductivity(10, p_vg); k2 <- unsat_conductivity(1000, p_vg)
stopifnot(k1 > k2, k1 <= 0.5)
ok("retention & conductivity")

ri <- richards_1d(psi_init = rep(200, 10), dz_m = 0.1, params = p_vg,
                  dt_day = 1, top_flux = 0.02, bottom_bc = "free")
stopifnot(all(ri$theta >= 0.05 & ri$theta <= 0.45))
stopifnot(ri$psi[1] < 200)                            # rain wets surface
th0 <- vg_retention(rep(200, 10), 0.02, 1.5, 0.05, 0.45)
dS <- sum((ri$theta - th0) * 0.1)
stopifnot(abs(dS - (0.02 - ri$drainage_m)) < 1e-6)     # mass balance closes
ok("richards_1d rain + mass balance")

ri_et <- richards_1d(psi_init = rep(100, 10), dz_m = 0.1, params = p_vg,
                     dt_day = 2, top_flux = -0.003, bottom_bc = "free")
stopifnot(ri_et$psi[1] > 100)                         # ET dries surface
ok("richards_1d evaporation")

ri_fx <- richards_1d(psi_init = rep(200, 10), dz_m = 0.1, params = p_vg,
                     dt_day = 1, bottom_bc = "fixed", psi_bottom = 100)
stopifnot(abs(ri_fx$psi[10] - 100) < 1e-6)
ok("richards_1d fixed bottom")

tc <- thermal_conductivity(0.3, "organic")
stopifnot(all.equal(tc, 0.54 + 0.023 * 30))
tb <- bottom_temp_wave(15, 10, 2, 180, 2)
stopifnot(tb > 5, tb < 25)
th2 <- heat_conduction_1d(t_init = rep(15, 10), dz_m = 0.1,
                          theta = rep(0.3, 10), t_top = 25,
                          bottom_bc = "fixed", t_bottom = 12)
stopifnot(abs(th2[1] - 25) < 1e-6, abs(th2[10] - 12) < 1e-6)
stopifnot(all(diff(th2) < 0))                          # monotonic gradient
ok("heat conduction")

cat("\nAll spacsysr v0.2.0 tests passed.\n")

## --- lite model: weather -------------------------------------------------
pet <- pet_hargreaves(28, 16, 35, 180)
stopifnot(pet > 2, pet < 10)
ok("pet_hargreaves")

stopifnot(pet_priestley_taylor(20, 25) > 2,
          pet_priestley_taylor(20, 25) < 8)
ok("pet_priestley_taylor")

dl <- daylength_hours(0, 80)
stopifnot(abs(dl - 12) < 0.5)
ok("daylength_hours")

stopifnot(all.equal(thermal_time(22, 8), 14))
stopifnot(thermal_time(5, 8) == 0, thermal_time(40, 8) == 27)
ok("thermal_time")

w0 <- data.frame(date = as.Date("2026-05-01") + 0:2, tmax = c(26, 27, 28),
                 tmin = c(15, 16, 17), precip = c(0, 5, 0))
w0c <- weather_complete(w0, 35)
stopifnot(all(c("rad", "pet", "tavg", "doy", "gdd") %in% names(w0c)),
          all(w0c$pet > 0), all(w0c$rad > 0), !any(is.na(w0c)))
ok("weather_complete")

## --- lite model: crop ----------------------------------------------------
cp <- crop_default_params("wheat")
stopifnot(cp$rue == 2.8, nrow(cp$part) == 3, ncol(cp$part) == 4,
          all(abs(rowSums(cp$part) - 1) < 1e-9))
ok("crop_default_params")

stopifnot(phenology_step(0, 60, c(120, 1000, 800)) == 0.5)
stopifnot(phenology_step(2.99, 100, c(120, 1000, 800)) == 3)
ok("phenology_step")

stopifnot(f_temp_growth(22, 0, 22, 35) == 1)
stopifnot(f_temp_growth(-5, 0, 22, 35) == 0, f_temp_growth(40, 0, 22, 35) == 0)
ok("f_temp_growth")

s0 <- plant_init()
g1 <- plant_growth_step(s0, 20, 22, 14, f_w = 1, n_avail = 5)
stopifnot(g1$growth > 0, g1$f_n == 1, g1$dindex > 0,
          g1$state$lai > s0$lai)
g2 <- plant_growth_step(s0, 20, 22, 14, f_w = 1, n_avail = 0)
stopifnot(g2$growth == 0, g2$f_n == 0)   # N stress stops growth
s3 <- s0; s3$dindex <- 3
g3 <- plant_growth_step(s3, 20, 22, 14, f_w = 1, n_avail = 5)
stopifnot(g3$growth == 0)                # no growth after maturity
ok("plant_growth_step")

## --- lite model: soil C/N ------------------------------------------------
sc <- soilcn_lite_step(list(c_litter = 100, c_humus = 2000, nh4 = 1, no3 = 3),
                       tsoil = 20, theta_pct = 25, sat_pct = 45,
                       ph = 6.5, depth_m = 0.2)
stopifnot(sc$pools$c_litter < 100, sc$co2_c > 0,
          all(c("n_mineralised", "n_nitrified", "n_denitrified",
                "n2o", "no") %in% names(sc)))
ok("soilcn_lite_step")

## --- lite model: driver --------------------------------------------------
so <- soil_init(c(200, 300, 500))
stopifnot(nrow(so) == 3, all(c("c_litter", "c_humus", "nh4", "no3") %in% names(so)))
ok("soil_init")

rw <- root_weights(c(100, 350, 750), 500)
stopifnot(abs(sum(rw) - 1) < 1e-9, rw[3] == 0, rw[1] > rw[2])
ok("root_weights")

set.seed(42)
n <- 60
wt <- data.frame(date = as.Date("2026-05-01") + 0:(n - 1),
                 tmax = 26 + rnorm(n, 0, 2), tmin = 16 + rnorm(n, 0, 1.5),
                 precip = pmax(0, rnorm(n, 3, 5)))
out <- spacsys_lite_run(wt, soil_init(c(200, 300, 500)), lat_deg = 35)
stopifnot(nrow(out) == n, !any(is.na(out)),
          all(out$lai >= 0), all(out$f_w >= 0 & out$f_w <= 1),
          all(out$f_n >= 0 & out$f_n <= 1),
          tail(out$w_grain, 1) >= 0)
## mineral-N mass balance regression test (uptake reporting bug, v0.3.0)
init_n <- sum(soil_init(c(200, 300, 500))$nh4 +
              soil_init(c(200, 300, 500))$no3)
stopifnot(sum(out$n_uptake) <= init_n + sum(out$n_mineralised) + 1e-6)
ok("spacsys_lite_run")

## --- GHG: methane transport & ebullition ----------------------------------
qt <- ch4_plant_transport(f_root = 0.5, w_leaf = 80, ch4_con = 5, z = 0.1)
stopifnot(qt > 0)
qt0 <- ch4_plant_transport(f_root = 0.5, w_leaf = 80, ch4_con = 1e-4, z = 0.1)
stopifnot(qt0 == 0)  # below atmospheric: no outward transport
ok("ch4_plant_transport")

qe0 <- ch4_ebullition(ch4_con = 5, theta = 0.4)
stopifnot(qe0 == 0)  # below solubility
qe1 <- ch4_ebullition(ch4_con = 50, theta = 0.4)
stopifnot(qe1 > qe0)
ok("ch4_ebullition")

## --- GHG: layer CH4 balance ----------------------------------------------
m_wet <- ch4_lite_step(ch4_con = 1, t_soil = 27, wfps = 0.95, theta = 0.43,
                       depth_m = 0.2, r_substrate = 2, w_root = 15,
                       w_leaf = 78, f_root = 0.4, z_mid = 0.1)
stopifnot(m_wet$emission > 0, m_wet$ch4_con >= 0,
          m_wet$production > 0)
m_dry <- ch4_lite_step(ch4_con = 0.5, t_soil = 20, wfps = 0.4, theta = 0.15,
                       depth_m = 0.2, r_substrate = 0.01, w_root = 15,
                       w_leaf = 78, f_root = 0.4, z_mid = 0.1)
stopifnot(m_dry$emission < m_wet$emission, m_dry$ch4_con >= 0)
ok("ch4_lite_step")

## --- GHG: CO2 autotrophic ------------------------------------------------
rr1 <- root_respiration(100, 20); rr2 <- root_respiration(100, 30)
stopifnot(abs(rr2 / rr1 - 2) < 0.01)  # Q10 = 2
ca <- co2_autotrophic(w_root = 50, w_shoot = 200, growth = 10,
                      t_soil = 20, t_air = 20, anoxic_frac = 0)
stopifnot(abs(ca$co2_auto - (ca$co2_root + ca$co2_shoot + ca$co2_growth)) < 1e-9,
          ca$co2_auto > 0)
ca_anox <- co2_autotrophic(w_root = 50, w_shoot = 200, growth = 10,
                           t_soil = 20, t_air = 20, anoxic_frac = 1)
stopifnot(ca_anox$co2_root == 0)  # fully anoxic: root C goes to CH4
ok("co2_autotrophic")

## --- GHG: aggregation ----------------------------------------------------
stopifnot(abs(ghg_co2eq(1, 0, 0) - 27.9) < 1e-9,
          abs(ghg_co2eq(0, 1, 0) - 273) < 1e-9,
          abs(ghg_co2eq(0, 0, 10) - 10) < 1e-9)
ok("ghg_co2eq")

set.seed(1)
n <- 30
wt <- data.frame(date = as.Date("2026-06-01") + 0:(n - 1),
                 tmax = 28 + rnorm(n, 0, 1.5), tmin = 20 + rnorm(n, 0, 1),
                 precip = pmax(0, rnorm(n, 3, 4)))
out <- spacsys_lite_run(wt, soil_init(c(200, 300, 500)), lat_deg = 35)
stopifnot(all(c("ch4", "co2_auto_c", "co2_total_c") %in% names(out)),
          !any(is.na(out$ch4)), !any(is.na(out$co2_total_c)),
          all(out$co2_total_c >= out$co2_c - 1e-9))
fp <- ghg_footprint(out)
stopifnot(abs(fp$share_co2 + fp$share_ch4 + fp$share_n2o - 1) < 1e-9,
          fp$ghg_co2eq_kg_ha > 0)
ok("ghg_footprint")

## --- weather: Angstrom-Prescott sunshine -> radiation -----------------------
rs <- rad_angstrom_prescott(n_sun = 8, n_day = 14,
                            ra = ra_extraterrestrial(35, 150))
stopifnot(rs > 0, rs < ra_extraterrestrial(35, 150))
rs0 <- rad_angstrom_prescott(n_sun = 0, n_day = 14,
                             ra = ra_extraterrestrial(35, 150))
rs1 <- rad_angstrom_prescott(n_sun = 14, n_day = 14,
                             ra = ra_extraterrestrial(35, 150))
stopifnot(rs0 < rs, rs < rs1)  # monotonic in sunshine
rs_cap <- rad_angstrom_prescott(n_sun = 20, n_day = 14,
                                ra = ra_extraterrestrial(35, 150))
stopifnot(abs(rs_cap - rs1) < 1e-9)  # n/N capped at 1
ok("rad_angstrom_prescott")

## --- weather_complete: radiation priority ----------------------------------
w0 <- data.frame(date = as.Date("2026-06-01") + 0:4,
                 tmax = c(28, 29, 30, 27, 28),
                 tmin = c(18, 19, 20, 18, 17),
                 precip = c(0, 0, 5, 0, 0))
w_base <- weather_complete(w0, 35)                       # Hargreaves only
w_sun <- weather_complete(transform(w0, sunshine = c(10, 9, 2, 8, 11)), 35)
stopifnot(!any(is.na(w_sun$rad)),
          any(abs(w_sun$rad - w_base$rad) > 0.5))         # sunshine changes rad
w_rad <- weather_complete(transform(w0, rad = 22), 35)   # measured wins
stopifnot(all(w_rad$rad == 22))
w_mix <- weather_complete(
  transform(w0, sunshine = c(10, 9, 2, 8, 11), rad = c(22, NA, NA, NA, NA)),
  35)
stopifnot(w_mix$rad[1] == 22, !is.na(w_mix$rad[2]))       # measured kept
## PET: auto prefers Priestley-Taylor when sunshine-derived rad exists
w_pt <- weather_complete(transform(w0, sunshine = c(10, 9, 2, 8, 11)), 35,
                         pet_method = "auto")
w_hg <- weather_complete(transform(w0, sunshine = c(10, 9, 2, 8, 11)), 35,
                         pet_method = "hargreaves")
stopifnot(any(abs(w_pt$pet - w_hg$pet) > 1e-6))
ok("weather_complete sunshine priority")
