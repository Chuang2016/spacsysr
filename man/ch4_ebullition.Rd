\name{ch4_ebullition}
\alias{ch4_ebullition}
\title{Methane ebullition (simplified)}
\description{
Manual eq. 215 (Susiluoto et al. 2018) releases CH4 when the summed
partial pressures of soil gases exceed the total pressure at depth,
which requires tracking CH4, CO2, O2 and N2 partial pressures.
This lite version keeps the manual's rate constant
(\code{r_ebu = ln(2)/1800} s-1) but triggers ebullition on CH4 alone:
dissolved CH4 above Henry's-law solubility is released as bubbles.
}
\usage{
ch4_ebullition(ch4_con, theta, ch4_sol = 22, r_ebu = log(2)/1800)
}
\arguments{
  \item{ch4_con}{CH4 concentration in the soil layer (g CH4 m-3 soil).}
  \item{theta}{volumetric water content (m3 m-3).}
  \item{ch4_sol}{solubility of CH4 in soil water (g CH4 m-3 water);
    default 22 (~20 C, Henry's law).}
  \item{r_ebu}{ebullition rate constant (s-1, manual default ln(2)/1800).}
}
\value{Ebullition flux (g CH4 m-3 soil d-1).}
\references{
Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66-67;
Susiluoto et al. (2018).
}
