\name{denitrif_microbial}
\alias{denitrif_microbial}
\title{Microbiological denitrification (4-step)}
\description{Sequential reduction NO3- -> NO2- -> NO -> N2O -> N2 with competitive Michaelis-Menten kinetics; manual eq. 194-198. Net N2O production is consumption["no"] - consumption["n2o"].}
\usage{denitrif_microbial(bd_prev, n_oxides, doc, params)}
\arguments{\item{bd_prev}{Denitrifier biomass at previous step (g C m-2).}
\item{n_oxides}{Named numeric vector of N-oxide concentrations in the anaerobic fraction (g N m-3): c(no3, no2, no, n2o).}
\item{doc}{Dissolved organic C concentration (g C m-3).}
\item{params}{List with gd, ni50, doc_km50, yc, yc_i, mc, mn_i, f_temp, f_ph (see function source).}
}
\value{A list with biomass, growth, death, c_consumption and consumption (named vector of the four reduction rates).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{denitrif_microbial(1, c(no3=10, no2=1, no=0.5, n2o=0.2), 100,
  list(gd=c(0.8,0.6,0.5,0.3), ni50=2, doc_km50=50, yc=0.503,
       yc_i=rep(0.4,4), mc=0.02, mn_i=rep(0.01,4), f_temp=1, f_ph=rep(1,4)))}
