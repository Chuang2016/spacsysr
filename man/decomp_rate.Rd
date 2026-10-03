\name{decomp_rate}
\alias{decomp_rate}
\title{Decomposition rate of soil organic carbon}
\description{Manual eq. 174.}
\usage{decomp_rate(c_pool, k_pot, f_temp, f_water, f_cn = 1, f_cp = 1)}
\arguments{\item{c_pool}{Size of the organic carbon pool (g C m-2).}
\item{k_pot}{Specific decomposition rate (d-1).}
\item{f_temp}{Temperature response factor.}
\item{f_water}{Moisture response factor.}
\item{f_cn}{Response to pool C:N ratio.}
\item{f_cp}{Response to pool C:P ratio.}
}
\value{Decomposition rate (g C m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{decomp_rate(1000, 0.01, 1, 0.8)}
