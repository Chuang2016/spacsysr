\name{nitrif_simplified}
\alias{nitrif_simplified}
\title{Simplified nitrification rate}
\description{Manual eq. 182-184.}
\usage{nitrif_simplified(nh4, no3, knitri, f_temp, f_water, f_ph, d_since_n = 0, r_no3_nh4 = 1)}
\arguments{\item{nh4}{Ammonium concentration (g N m-3).}
\item{no3}{Nitrate concentration (g N m-3).}
\item{knitri}{Potential nitrification rate (d-1).}
\item{f_temp}{Temperature response factor.}
\item{f_water}{Moisture response factor.}
\item{f_ph}{pH response factor.}
\item{d_since_n}{Days since last external N input.}
\item{r_no3_nh4}{Nitrate-ammonium ratio scaling in eq. 183.}
}
\value{Nitrification rate (g N m-3 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nitrif_simplified(10, 2, 0.2, 1, 0.8, 0.9)}
