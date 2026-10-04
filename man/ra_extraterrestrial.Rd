\name{ra_extraterrestrial}
\alias{ra_extraterrestrial}
\title{Extraterrestrial radiation}
\description{Daily extraterrestrial radiation Ra (MJ m-2 d-1) after Allen et al. (1998, FAO-56, eq. 21).}
\usage{ra_extraterrestrial(lat_deg, doy)}
\arguments{\item{lat_deg}{Latitude (decimal degrees, +N).}
\item{doy}{Day of year (1-366).}
}
\value{Ra (MJ m-2 d-1).}
\references{Allen, R.G. et al. (1998). FAO Irrigation and Drainage Paper 56.}
\examples{ra_extraterrestrial(35, 180)}
