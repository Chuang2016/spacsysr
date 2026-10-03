\name{nitrif_microbial}
\alias{nitrif_microbial}
\title{Microbiological nitrification rate}
\description{Manual eq. 193.}
\usage{nitrif_microbial(nnmax, biomass, f_inhib, f_temp, f_water, f_ph, f_nh4)}
\arguments{\item{nnmax}{Maximum nitrification rate (d-1).}
\item{biomass}{Nitrifier biomass (g C m-2).}
\item{f_inhib}{Inhibitor effect factor.}
\item{f_temp}{Temperature response factor.}
\item{f_water}{Moisture response factor.}
\item{f_ph}{pH response factor.}
\item{f_nh4}{Ammonium substrate response.}
}
\value{Nitrification rate (g N m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nitrif_microbial(0.5, 1, 1, 1, 1, 1, 0.5)}
