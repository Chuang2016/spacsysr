\name{maint_respiration}
\alias{maint_respiration}
\title{Plant maintenance respiration}
\description{Manual eq. 39.}
\usage{maint_respiration(w_biomass, q10, temp_air, t_base)}
\arguments{\item{w_biomass}{Biomass of the plant component (g m-2).}
\item{q10}{Q10 value.}
\item{temp_air}{Air temperature (degrees C).}
\item{t_base}{Temperature at which the Q10 factor is unity.}
}
\value{Maintenance respiration (same mass units per day).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{maint_respiration(100, 2, 25, 20)}
