\name{ch4_oxidation_soil}
\alias{ch4_oxidation_soil}
\title{CH4 oxidation by soil methanotrophs}
\description{Manual eq. 211.}
\usage{ch4_oxidation_soil(vs_max, f_temp, r_moist, bulk_density, ch4_con, o2_con, ks_ch4, ko2)}
\arguments{\item{vs_max}{Maximum uptake rate (g CH4 g-1 dry soil d-1).}
\item{f_temp}{Temperature factor.}
\item{r_moist}{Ratio of layer moisture to saturated water content.}
\item{bulk_density}{Soil bulk density.}
\item{ch4_con}{CH4 concentration (g m-3).}
\item{o2_con}{O2 concentration (g m-3).}
\item{ks_ch4}{Michaelis constant for CH4 (g CH4 m-3).}
\item{ko2}{Michaelis constant for O2 (g m-3).}
}
\value{CH4 uptake rate in the caller area units.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{ch4_oxidation_soil(1e-4, 1, 0.8, 1.3, 2, 5, 1, 1)}
