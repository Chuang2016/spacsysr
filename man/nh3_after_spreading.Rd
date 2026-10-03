\name{nh3_after_spreading}
\alias{nh3_after_spreading}
\title{NH3 volatilisation after spreading}
\description{Integrates the TAN mass balance after surface application (manual eq. 207-209; Hutchings et al., 1996). The closed form in eq. 205 is ambiguously typeset in the manual, so the ODE is integrated numerically.}
\usage{nh3_after_spreading(tan, w_w, infil, evap, precip, epsilon, dt = 1, n_sub = 24)}
\arguments{\item{tan}{TAN remaining on the soil surface (g N m-2).}
\item{w_w}{Wet weight of surface slurry (g m-2).}
\item{infil}{Infiltration rate (g m-2 d-1).}
\item{evap}{Evaporation rate (g m-2 d-1).}
\item{precip}{Precipitation (g m-2 d-1).}
\item{epsilon}{Volatilisation transfer coefficient (d-1).}
\item{dt}{Integration window in days.}
\item{n_sub}{Number of sub-steps.}
}
\value{A list with n_vol, tan_new and w_w_new.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nh3_after_spreading(5, 1000, 2, 3, 0, 0.5)}
