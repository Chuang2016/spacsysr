\name{ch4_production}
\alias{ch4_production}
\title{Methane production}
\description{Manual eq. 213, after Raivonen et al. (2017).}
\usage{ch4_production(r_root, f_ch4_co2 = 0.3, eta_inhib, o2_con)}
\arguments{\item{r_root}{Anoxic respiration rate at layer mid-depth.}
\item{f_ch4_co2}{Fraction of anaerobic respiration becoming CH4.}
\item{eta_inhib}{Sensitivity of methanogenesis to O2 inhibition (m3 g-1).}
\item{o2_con}{O2 concentration (g m-3).}
}
\value{CH4 production rate.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{ch4_production(2, eta_inhib = 0.01, o2_con = 5)}
