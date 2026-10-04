\name{soilcn_lite_step}
\alias{soilcn_lite_step}
\title{Daily lite soil C/N step for one layer}
\description{Decomposition (decomp_rate) of litter and humus pools with temperature (f_temp_q10) and moisture (f_water_decom) responses; a fraction of decomposed litter C is humified. Net N mineralisation follows C:N stoichiometry: N released from decomposed C minus N required for humus formed (negative values immobilise mineral N). Mineral pools are then updated by plant uptake, simplified nitrification (nitrif_simplified) and simplified denitrification (denitrif_simplified).}
\usage{soilcn_lite_step(pools, tsoil, theta_pct, sat_pct, ph, depth_m, up_nh4 = 0, up_no3 = 0, params = spacsys_default_params())}
\arguments{\item{pools}{Named list with c_litter, c_humus (g C m-2), nh4, no3 (g N m-2).}
\item{tsoil}{Soil temperature (deg C).}
\item{theta_pct}{Volumetric water content (\%).}
\item{sat_pct}{Saturated water content (\%).}
\item{ph}{Soil pH.}
\item{depth_m}{Layer thickness (m).}
\item{up_nh4, up_no3}{Plant uptake from this layer (g N m-2 d-1).}
\item{params}{Parameter list from spacsys_default_params.}
}
\value{A list with updated pools and fluxes (co2_c, n_mineralised, n_nitrified, n_denitrified, n2o, no; g m-2 d-1).}
\examples{
soilcn_lite_step(list(c_litter=100, c_humus=2000, nh4=1, no3=3), 20, 25, 45, 6.5, 0.2)
}
