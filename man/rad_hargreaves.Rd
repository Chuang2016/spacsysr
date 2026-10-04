\name{rad_hargreaves}
\alias{rad_hargreaves}
\title{Estimate solar radiation from temperature range}
\description{Hargreaves-Samani radiation estimate Rs = k_Rs * sqrt(Tmax - Tmin) * Ra with k_Rs = 0.16 (interior) or 0.19 (coastal).}
\usage{rad_hargreaves(tmax, tmin, lat_deg, doy, k_rs = 0.16)}
\arguments{\item{tmax}{Daily maximum temperature (deg C).}
\item{tmin}{Daily minimum temperature (deg C).}
\item{lat_deg}{Latitude (decimal degrees, +N).}
\item{doy}{Day of year (1-366).}
\item{k_rs}{Empirical coefficient, default 0.16.}
}
\value{Solar radiation (MJ m-2 d-1).}
\examples{rad_hargreaves(28, 16, 35, 180)}
