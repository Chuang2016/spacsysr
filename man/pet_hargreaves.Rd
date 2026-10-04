\name{pet_hargreaves}
\alias{pet_hargreaves}
\title{Hargreaves reference evapotranspiration}
\description{ET0 = 0.0023 * Ra * sqrt(Tmax - Tmin) * (Tavg + 17.8) (Hargreaves & Samani, 1985). Needs only temperature plus latitude/day of year; recommended when measured radiation is unavailable.}
\usage{pet_hargreaves(tmax, tmin, lat_deg, doy)}
\arguments{\item{tmax}{Daily maximum temperature (deg C).}
\item{tmin}{Daily minimum temperature (deg C).}
\item{lat_deg}{Latitude (decimal degrees, +N).}
\item{doy}{Day of year (1-366).}
}
\value{Reference evapotranspiration ET0 (mm d-1).}
\references{Hargreaves, G.H. & Samani, Z.A. (1985). Reference crop evapotranspiration from temperature. Appl. Eng. Agric. 1, 96-99.}
\examples{pet_hargreaves(28, 16, 35, 180)}
