\name{rad_angstrom_prescott}
\alias{rad_angstrom_prescott}
\title{Solar radiation from sunshine duration (Angstrom-Prescott)}
\description{
\code{Rs = (a + b * n/N) * Ra} (FAO56): incoming solar radiation from
the relative sunshine duration. More reliable than the
temperature-difference estimate (\code{\link{rad_hargreaves}}) when
sunshine hours are recorded -- the usual case at Chinese weather
stations. Coefficients default to the FAO56 recommendations
(a = 0.25, b = 0.50); calibrate locally when possible.
}
\usage{
rad_angstrom_prescott(n_sun, n_day, ra, a = 0.25, b = 0.50)
}
\arguments{
  \item{n_sun}{measured bright sunshine duration (h d-1).}
  \item{n_day}{maximum possible daylight hours, e.g. from
    \code{\link{daylength_hours}}.}
  \item{ra}{extraterrestrial radiation (MJ m-2 d-1), e.g. from
    \code{\link{ra_extraterrestrial}}.}
  \item{a, b}{Angstrom-Prescott coefficients; defaults 0.25 / 0.50.}
}
\value{Solar radiation (MJ m-2 d-1).}
\references{Allen et al. (1998). FAO Irrigation and Drainage Paper 56.}
