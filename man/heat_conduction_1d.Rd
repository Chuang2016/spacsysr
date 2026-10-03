\name{heat_conduction_1d}
\alias{heat_conduction_1d}
\title{1-D soil heat conduction}
\description{Implicit finite differences for d(C*T)/dt = d/dz(k dT/dz) (conductive part of manual eq. 244; convective and freeze-thaw terms omitted).}
\usage{heat_conduction_1d(t_init, dz_m, theta, dt_day = 1, n_sub = 24, t_top, bottom_bc = c("wave", "fixed"), t_bottom = 10, t_annual = 15, t_amp = 10, d_d = 2, day_of_year = 180, soil = c("mineral", "organic"), c_solid = 2e6, porosity = 0.5)}
\arguments{\item{t_init}{Initial soil temperature per node (degrees C).}
\item{dz_m}{Node spacing (m, uniform).}
\item{theta}{Water content per node (fraction).}
\item{dt_day}{Time step in days.}
\item{n_sub}{Number of sub-steps.}
\item{t_top}{Surface temperature (degrees C, Dirichlet top BC).}
\item{bottom_bc}{"wave" (annual wave, eq. 251) or "fixed".}
\item{t_bottom}{Fixed bottom temperature.}
\item{t_annual}{Annual mean air temperature.}
\item{t_amp}{Temperature amplitude.}
\item{d_d}{Damping depth (m).}
\item{day_of_year}{Day of year.}
\item{soil}{"mineral" or "organic".}
\item{c_solid}{Volumetric heat capacity of solids (J m-3 K-1).}
\item{porosity}{Total porosity (fraction).}
}
\value{Numeric vector of soil temperatures (degrees C).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{heat_conduction_1d(rep(15, 10), 0.1, rep(0.3, 10), t_top = 25, t_bottom = 12)}
