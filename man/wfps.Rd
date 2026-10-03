\name{wfps}
\alias{wfps}
\title{Water-filled pore space}
\description{Manual eq. 190.}
\usage{wfps(theta_pct, bulk_density, particle_density = 2.65)}
\arguments{\item{theta_pct}{Volumetric water content in percent.}
\item{bulk_density}{Soil bulk density (g cm-3).}
\item{particle_density}{Particle density (g cm-3).}
}
\value{WFPS as a fraction (0-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{wfps(30, 1.3)}
