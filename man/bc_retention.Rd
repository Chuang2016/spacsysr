\name{bc_retention}
\alias{bc_retention}
\title{Brooks-Corey water retention curve}
\description{Manual eq. 291, p. 83.}
\usage{bc_retention(psi, psia, lambda, theta_r, theta_s)}
\arguments{\item{psi}{Soil water tension (cm, >= 0).}
\item{psia}{Air-entry tension (cm).}
\item{lambda}{Pore-size distribution index (-).}
\item{theta_r}{Residual water content.}
\item{theta_s}{Saturated water content.}
}
\value{Volumetric water content (fraction).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{bc_retention(seq(0, 1000, by = 100), 20, 0.4, 0.05, 0.45)}
