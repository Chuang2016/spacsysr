\name{canopy_photo_c3}
\alias{canopy_photo_c3}
\title{Canopy-level daily photosynthesis (C3)}
\description{Hourly sun/shade integration (manual p. 25-26). Feeds growth_respiration().}
\usage{canopy_photo_c3(lai, sr_mj, lat, doy, t_leaf, ca = 420, frac_diffuse = 0.3, ...)}
\arguments{\item{lai}{Canopy green leaf area index.}
\item{sr_mj}{Daily shortwave irradiation (MJ m-2 d-1).}
\item{lat}{Latitude in degrees.}
\item{doy}{Day of year.}
\item{t_leaf}{Leaf temperature (degrees C).}
\item{ca}{Ambient CO2 (umol mol-1).}
\item{frac_diffuse}{Fraction of diffuse PPFD.}
\item{...}{Passed to leaf_photo_c3.}
}
\value{A list with a_canopy (mol CO2 m-2 d-1), a_sun, a_shade (hourly means).}
\examples{canopy_photo_c3(3, 20, 32, 180, 25)}
