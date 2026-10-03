\name{growth_respiration}
\alias{growth_respiration}
\title{Plant growth respiration}
\description{From van Iersel & Seymour (2000); manual eq. 40-41. With defaults, Rg ~= 0.234 * A_canopy.}
\usage{growth_respiration(a_canopy, y_g = 0.72, f_c = 0.45)}
\arguments{\item{a_canopy}{Canopy gross photosynthesis (g C m-2 d-1).}
\item{y_g}{Conversion efficiency.}
\item{f_c}{Carbon fraction in plant biomass.}
}
\value{Growth respiration (g C m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{growth_respiration(10)}
