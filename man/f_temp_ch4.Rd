\name{f_temp_ch4}
\alias{f_temp_ch4}
\title{Temperature response of methane oxidation}
\description{Manual eq. 212; defaults from Sabrekov et al. (2016).}
\usage{f_temp_ch4(t_soil, b0 = -3.95, b1 = 0.149, b2 = -0.0029, bmax = 0.1668)}
\arguments{\item{t_soil}{Soil temperature (degrees C).}
\item{b0}{Empirical coefficient.}
\item{b1}{Empirical coefficient.}
\item{b2}{Empirical coefficient.}
\item{bmax}{Empirical coefficient.}
}
\value{Temperature response factor (-).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_temp_ch4(seq(5, 35, by = 5))}
