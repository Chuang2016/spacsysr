\name{ch4_oxidation_rhizo}
\alias{ch4_oxidation_rhizo}
\title{CH4 oxidation by rhizospheric methanotrophs}
\description{Michaelis-Menten kinetics in both CH4 and O2; manual eq. 210.}
\usage{ch4_oxidation_rhizo(vr_max, f_temp, r_moist, w_root, ch4_con, o2_con, kr_ch4, ko2)}
\arguments{\item{vr_max}{Maximum uptake rate (g CH4 g-1 root DM d-1).}
\item{f_temp}{Temperature factor.}
\item{r_moist}{Ratio of layer moisture to saturated water content.}
\item{w_root}{Root dry matter in the layer (g m-2).}
\item{ch4_con}{CH4 concentration (g m-3).}
\item{o2_con}{O2 concentration (g m-3).}
\item{kr_ch4}{Michaelis constant for CH4 (g CH4 m-3).}
\item{ko2}{Michaelis constant for O2 (g m-3).}
}
\value{CH4 uptake rate (g CH4 m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{ch4_oxidation_rhizo(0.01, 1, 0.8, 50, 2, 5, 1, 1)}
