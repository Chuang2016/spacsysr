\name{soil_water_step}
\alias{soil_water_step}
\title{Daily tipping-bucket soil water step}
\description{Cascading bucket: precipitation enters the top layer, water above field capacity drains downward, ET is drawn top-down. Simplified stand-in; the manual solves Richards-type transport (roadmap).}
\usage{soil_water_step(theta_vol, precip_mm, pet_mm, fc, wp, sat, depth_mm, infil_cap_mm = Inf)}
\arguments{\item{theta_vol}{Volumetric water content per layer (fraction).}
\item{precip_mm}{Precipitation (mm d-1).}
\item{pet_mm}{Potential evapotranspiration (mm d-1).}
\item{fc}{Field-capacity water content per layer (fraction).}
\item{wp}{Wilting-point water content per layer (fraction).}
\item{sat}{Saturated water content per layer (fraction).}
\item{depth_mm}{Layer depths (mm).}
\item{infil_cap_mm}{Maximum daily infiltration (mm d-1); precipitation above this runs off before entering the soil. Default \code{Inf} = saturation-excess runoff only.}
}
\value{A list with theta, drainage_mm, runoff_mm and aet_mm.}
\examples{soil_water_step(c(0.4, 0.4), 20, 3, c(0.38, 0.36), c(0.18, 0.17), c(0.5, 0.48), c(100, 150))}
