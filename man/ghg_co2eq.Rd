\name{ghg_co2eq}
\alias{ghg_co2eq}
\title{Convert GHG fluxes to CO2-equivalents}
\description{
\code{CO2eq = CO2 + GWP_CH4 * CH4 + GWP_N2O * N2O} on a per-mass-of-gas
basis. Default GWP100 values are from IPCC AR6
(CH4 = 27.9, N2O = 273); pass AR5 values (28, 265) or any horizon
via the arguments.
}
\usage{
ghg_co2eq(ch4, n2o, co2 = 0, gwp_ch4 = 27.9, gwp_n2o = 273)
}
\arguments{
  \item{ch4, n2o, co2}{fluxes in mass of gas (any consistent units,
    e.g. kg ha-1).}
  \item{gwp_ch4, gwp_n2o}{100-year global warming potentials.}
}
\value{CO2-equivalent flux in the same mass units.}
\references{IPCC (2021). AR6 WG1, Chapter 7.}
