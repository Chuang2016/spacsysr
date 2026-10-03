\name{solar_sin_elev}
\alias{solar_sin_elev}
\title{Solar elevation angle}
\description{Standard astronomical calculation; needed for hourly PPFD.}
\usage{solar_sin_elev(lat, doy, hour)}
\arguments{\item{lat}{Latitude in degrees (north positive).}
\item{doy}{Day of year.}
\item{hour}{Local solar hour (0-24).}
}
\value{sin of the solar elevation angle (negative at night).}
\examples{solar_sin_elev(32, 180, 12)}
