\name{vg_retention}
\alias{vg_retention}
\title{van Genuchten water retention curve}
\description{Manual eq. 290, p. 83.}
\usage{vg_retention(psi, alpha, n, theta_r, theta_s)}
\arguments{\item{psi}{Soil water tension (cm, >= 0).}
\item{alpha}{van Genuchten alpha (cm-1).}
\item{n}{van Genuchten n (-).}
\item{theta_r}{Residual water content (fraction).}
\item{theta_s}{Saturated water content (fraction).}
}
\value{Volumetric water content (fraction).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{vg_retention(seq(0, 1000, by = 100), 0.02, 1.5, 0.05, 0.45)}
