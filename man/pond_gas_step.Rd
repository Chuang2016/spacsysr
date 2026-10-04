\name{pond_gas_step}
\alias{pond_gas_step}
\title{Dissolved-gas emissions from ponded water}
\description{When soil is ponded, diffusive soil CH4/N2O dissolve in the floodwater, where CH4 is partly oxidised by water-column methanotrophs and both gases escape across the water-air interface. Plant-transported CH4 and ebullition bubbles bypass via \code{ebu_in}. Below 1 mm the inputs go straight to air. Fluxes are capped by available mass.}
\usage{pond_gas_step(ch4_in, n2o_in, ebu_in = 0, ch4_diss = 0, n2o_diss = 0, pond_m = 0.02, t_water = 25, k_oxw = 0.5, k_transfer = 0.3)}
\arguments{
  \item{ch4_in, n2o_in}{diffusive soil gas inputs (g m-2 d-1).}
  \item{ebu_in}{bubble / plant-transport CH4 bypassing the water (g CH4 m-2 d-1).}
  \item{ch4_diss, n2o_diss}{dissolved concentrations (g m-3 water).}
  \item{pond_m}{ponded depth (m).}
  \item{t_water}{floodwater temperature (deg C; reserved).}
  \item{k_oxw}{water-column CH4 oxidation rate (d-1).}
  \item{k_transfer}{water-air gas transfer velocity (m d-1).}
}
\value{A list with \code{ch4_diss}, \code{n2o_diss}, \code{ch4_flux}, \code{n2o_flux}, \code{ch4_oxidized}.}
