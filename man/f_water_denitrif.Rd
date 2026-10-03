\name{f_water_denitrif}
\alias{f_water_denitrif}
\title{Moisture response of denitrification}
\description{Manual eq. 186; delta_theta is strongly soil-type dependent.}
\usage{f_water_denitrif(theta, theta_s, delta_theta, k_w = 1)}
\arguments{\item{theta}{Volumetric water content.}
\item{theta_s}{Water content at saturation.}
\item{delta_theta}{Water-content interval over which the factor rises from 0 to 1.}
\item{k_w}{Empirical exponent.}
}
\value{Response factor in [0, 1].}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_water_denitrif(seq(30, 45, by = 1), 45, 10)}
