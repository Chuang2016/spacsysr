\name{spacsys_lite_run}
\alias{spacsys_lite_run}
\title{Simplified daily SPACSYS-lite driver}
\description{Couples, at a daily step over layered soil: Hargreaves/Priestley-Taylor PET (see weather_complete), tipping-bucket soil water (soil_water_step), two-pool decomposition with C:N stoichiometric mineralisation, simplified nitrification and denitrification (soilcn_lite_step), demand-driven plant N uptake, and RUE-based crop growth limited by temperature, water and nitrogen (plant_growth_step). Senesced leaf returns to the top-layer litter pool. This is a deliberately simplified research/teaching scaffold with few parameters -- not a full SPACSYS port.}
\usage{spacsys_lite_run(weather, soil, crop = crop_default_params(), params = spacsys_default_params(), n_inputs = NULL, lat_deg = 35)}
\arguments{\item{weather}{data.frame with date (Date), tmax, tmin (deg C), precip (mm d-1); optional rad (MJ m-2 d-1), pet (mm d-1), irrig (mm d-1, added to precipitation).}
\item{soil}{data.frame, one row per layer (see soil_init), with depth_mm, fc, wp, sat, bulk_density, ph, theta_init, c_litter, c_humus (g C m-2), nh4, no3 (g N m-2).}
\item{crop}{Crop parameter list from crop_default_params.}
\item{params}{Parameter list from spacsys_default_params.}
\item{n_inputs}{Optional data.frame with date and any of nh4_add, no3_add (g N m-2, applied to the top layer).}
\item{lat_deg}{Latitude (decimal degrees, +N), used for PET and thermal time when weather is incomplete.}
}
\value{A data.frame with one row per day: date, dindex, lai, w_leaf, w_stem, w_root, w_grain (g DM m-2), growth (g m-2 d-1), n_uptake (g N m-2 d-1), stress factors f_t, f_w, f_n, pet, aet (mm d-1), swc_root (root-zone mean water fraction), drainage, runoff (mm d-1), n2o, no (g N m-2 d-1), n_leached, n_mineralised, n_nitrified, n_denitrified (g N m-2 d-1), co2_c (g C m-2 d-1).}
\examples{
w <- data.frame(date = as.Date("2026-05-01") + 0:59,
  tmax = 26 + rnorm(60), tmin = 15 + rnorm(60), precip = pmax(0, rnorm(60, 2, 4)))
\donttest{out <- spacsys_lite_run(w, soil_init(c(200, 300, 500)), lat_deg = 35)}
}
