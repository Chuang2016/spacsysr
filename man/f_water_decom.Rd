\name{f_water_decom}
\alias{f_water_decom}
\title{Soil-moisture response of decomposition}
\description{Activity declines on either side of an optimal soil-water range (manual eq. 175-176).}
\usage{f_water_decom(theta, theta_s, theta_m, delta_theta1, delta_theta2, e_s = 0.2, k_w = 1)}
\arguments{\item{theta}{Volumetric soil water content.}
\item{theta_s}{Water content at saturation.}
\item{theta_m}{Minimum water content for activity.}
\item{delta_theta1}{Range from theta_m to optimum onset.}
\item{delta_theta2}{Range from optimum end to saturation.}
\item{e_s}{Minimum factor at saturation.}
\item{k_w}{Empirical exponent.}
}
\value{Numeric vector of response factors in [0, 1].}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_water_decom(seq(5, 50, by = 5), 50, 8, 10, 5)}
