\name{pet_priestley_taylor}
\alias{pet_priestley_taylor}
\title{Priestley-Taylor evapotranspiration}
\description{ET0 = alpha * Delta/(Delta + gamma) * Rn/lambda, with net radiation approximated as Rn = 0.75 * Rs (simplified; no longwave balance) and lambda = 2.45 MJ kg-1. Use when solar radiation was measured.}
\usage{pet_priestley_taylor(rad_mj, tavg, alpha = 1.26)}
\arguments{\item{rad_mj}{Incoming solar radiation (MJ m-2 d-1).}
\item{tavg}{Daily mean temperature (deg C).}
\item{alpha}{Priestley-Taylor coefficient, default 1.26.}
}
\value{Evapotranspiration (mm d-1).}
\examples{pet_priestley_taylor(20, 25)}
