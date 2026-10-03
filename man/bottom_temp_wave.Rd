\name{bottom_temp_wave}
\alias{bottom_temp_wave}
\title{Annual-wave lower boundary temperature}
\description{Manual eq. 251-252, p. 77.}
\usage{bottom_temp_wave(t_annual, t_amp, z_m, day_of_year, d_d, t_shift = 0, l_cycle = 365)}
\arguments{\item{t_annual}{Annual mean air temperature (degrees C).}
\item{t_amp}{Temperature amplitude (degrees C).}
\item{z_m}{Depth (m).}
\item{day_of_year}{Day of year.}
\item{d_d}{Damping depth (m).}
\item{t_shift}{Phase shift (days).}
\item{l_cycle}{Cycle length (days).}
}
\value{Soil temperature at depth (degrees C).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{bottom_temp_wave(15, 10, 2, 180, 2)}
