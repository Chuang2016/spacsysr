\name{denitrif_simplified}
\alias{denitrif_simplified}
\title{Simplified denitrification rate}
\description{Manual eq. 185-186.}
\usage{denitrif_simplified(no3, kdeni, f_temp, f_water, n_half)}
\arguments{\item{no3}{Nitrate concentration (g N m-3).}
\item{kdeni}{Potential denitrification rate (g N m-2 d-1).}
\item{f_temp}{Temperature response factor.}
\item{f_water}{Moisture response factor.}
\item{n_half}{Nitrate concentration at half saturation (g N m-3).}
}
\value{Denitrification rate (g N m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{denitrif_simplified(8, 0.5, 1, 0.7, 5)}
