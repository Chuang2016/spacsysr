\name{nitrifier_growth}
\alias{nitrifier_growth}
\title{Nitrifier biomass dynamics (microbiological method)}
\description{Gross growth, death and maintenance respiration of nitrifiers after Blagodatsky & Richter (1998); manual eq. 187-188.}
\usage{nitrifier_growth(bn_prev, gnitr, dnitr, fe, f_temp, f_water, f_ph, f_doc, f_no3)}
\arguments{\item{bn_prev}{Nitrifier biomass at previous step (g C m-2).}
\item{gnitr}{Maximum gross growth rate (d-1).}
\item{dnitr}{Maximum death rate (d-1).}
\item{fe}{Efficiency factor.}
\item{f_temp}{Temperature response factor.}
\item{f_water}{Moisture response factor.}
\item{f_ph}{pH response factor.}
\item{f_doc}{DOC substrate response.}
\item{f_no3}{NO3 substrate response.}
}
\value{A list with biomass, growth, death and respiration.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nitrifier_growth(1, 0.5, 0.05, 0.6, 1, 1, 1, 0.5, 0.5)}
