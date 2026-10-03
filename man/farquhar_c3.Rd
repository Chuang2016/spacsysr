\name{farquhar_c3}
\alias{farquhar_c3}
\title{C3 leaf photosynthesis (Farquhar biochemical model)}
\description{Rubisco-, electron-transport- and TPU-limited rates (Farquhar et al., 1980; Sharkey, 1985; manual p. 21). The outer (1 - Gs/Ci) factor is as printed in the manual.}
\usage{farquhar_c3(vcmax, j, rd, gamma_star, kmc, kmo, cc, ci, oi = 210000, tu, f_cyc = 0.2, f_psdeudo = 0)}
\arguments{\item{vcmax}{Maximum Rubisco carboxylation rate (umol m-2 s-1).}
\item{j}{Electron transport rate (umol m-2 s-1).}
\item{rd}{Day respiration (umol m-2 s-1).}
\item{gamma_star}{CO2 compensation point without dark respiration (umol mol-1).}
\item{kmc}{Rubisco Michaelis constant for CO2 (umol mol-1).}
\item{kmo}{Rubisco Michaelis constant for O2 (umol mol-1).}
\item{cc}{CO2 partial pressure at carboxylation site (umol mol-1).}
\item{ci}{Intercellular CO2 (umol mol-1).}
\item{oi}{Intercellular O2 (umol mol-1).}
\item{tu}{Triose-phosphate utilisation rate (umol m-2 s-1).}
\item{f_cyc}{Fraction of PSI electron flow in cyclic transport.}
\item{f_psdeudo}{Fraction in pseudocyclic transport.}
}
\value{A list with ac, aj, ap, a and limitation ("rubisco", "electron" or "tpu").}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{farquhar_c3(80, 100, 1, 42.75, 404.9, 278400, 280, 280, tu = 10)}
