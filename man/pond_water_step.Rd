\name{pond_water_step}
\alias{pond_water_step}
\title{Daily ponded-water balance coupled to topsoil}
\description{Tracks ponded surface water (mm) under paddy/flooded conditions. Rainfall + irrigation (+ auto-irrigation to \code{target_mm} when set) pond on the surface; pond water saturates the topsoil, percolates slowly through the plow pan, evaporates as open water, and overflows the bund.}
\usage{pond_water_step(pond_mm, precip, irrig, pet, theta_top, sat_top, depth_top_mm, bund_mm = 80, k_perc = 2, k_evap = 1.0, target_mm = NULL)}
\arguments{
  \item{pond_mm}{current ponded depth (mm).}
  \item{precip, irrig}{rainfall and irrigation (mm d-1).}
  \item{pet}{potential evapotranspiration (mm d-1).}
  \item{theta_top, sat_top}{topsoil water content and saturation (volumetric fractions).}
  \item{depth_top_mm}{topsoil layer thickness (mm).}
  \item{bund_mm}{bund height; excess ponds overflow to runoff (mm).}
  \item{k_perc}{slow percolation through the plow pan (mm d-1).}
  \item{k_evap}{open-water evaporation coefficient (-) on PET.}
  \item{target_mm}{optional target ponded depth (mm); auto-irrigate the deficit daily.}
}
\value{A list with \code{pond_mm}, \code{theta_top}, \code{irrig_auto_mm}, \code{perc_mm}, \code{evap_mm}, \code{overflow_mm}.}
