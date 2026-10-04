\name{ch4_lite_step}
\alias{ch4_lite_step}
\title{Daily layer methane balance (lite)}
\description{
Simplified daily CH4 budget for one soil layer, combining manual
eq. 210-215 with a single CH4 concentration pool
(\code{ch4_con}, g CH4 m-3 soil):
\enumerate{
  \item production from anoxic respiration (eq. 213 via
    \code{\link{ch4_production}}),
  \item rhizospheric + soil methanotrophic oxidation (eq. 210-211),
  \item plant aerenchyma transport (eq. 214),
  \item ebullition of super-saturated CH4 (simplified eq. 215),
  \item slow diffusion toward the atmospheric concentration
    (upland soils can thus show net CH4 uptake).
}
Sinks are capped at the available pool so mass is conserved.
O2 is not tracked as a state: \code{o2_con = o2_air * (1 - wfps)}
with \code{o2_air = 300} g m-3.

The methanogenic substrate (\code{r_substrate}) is the anoxic
respiration rate at the layer (manual's \eqn{R_{root}(z)}): the caller
supplies anoxic root + heterotrophic respiration (g CO2 m-2 d-1).

Oxidation kinetic parameters (\code{vr_max}, \code{vs_max},
\code{kr_ch4}, \code{ks_ch4}, \code{ko2}, \code{eta_inhib}) have no
manual defaults; the defaults are illustrative literature-typical
values -- calibrate to site before quantitative use.
}
\usage{
ch4_lite_step(ch4_con, t_soil, wfps, theta, depth_m, r_substrate,
              w_root, w_leaf, f_root, z_mid, bulk_density = 1.35,
              vr_max = 0.005, vs_max = 5e-6, kr_ch4 = 10, ks_ch4 = 10,
              ko2 = 5, eta_inhib = 0.1, k_diff = 0.05,
              o2_rol_rate = 0.3, ...)
}
\arguments{
  \item{ch4_con}{current layer CH4 concentration (g CH4 m-3 soil).}
  \item{t_soil}{soil temperature (degrees C).}
  \item{wfps}{water-filled pore space (-).}
  \item{theta}{volumetric water content (m3 m-3).}
  \item{depth_m}{layer thickness (m).}
  \item{r_substrate}{anoxic respiration driving methanogenesis
    (g CO2 m-2 d-1).}
  \item{w_root}{root dry matter in the layer (g m-2).}
  \item{w_leaf}{leaf dry matter (g m-2).}
  \item{f_root}{fraction of total root biomass in this layer (-).}
  \item{z_mid}{mid-depth of the layer (m).}
  \item{bulk_density}{soil bulk density (g cm-3).}
  \item{vr_max, vs_max, kr_ch4, ks_ch4, ko2, eta_inhib}{oxidation /
    production kinetic parameters (see details).}
  \item{o2_rol_rate}{radial oxygen loss (g O2 m-3 per g root m-2); default 0.3.}
\item{k_diff}{first-order soil-atmosphere CH4 exchange rate (d-1).}
  \item{...}{further arguments passed to
    \code{\link{ch4_plant_transport}} (e.g. \code{d_a}).}
}
\value{
A list with \code{ch4_con} (updated pool), \code{production},
\code{oxidation}, \code{plant_transport}, \code{ebullition},
\code{diffusion} and \code{emission} (net soil-to-atmosphere flux,
g CH4 m-2 d-1; negative = net uptake).
}
\references{Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 65-67.}
