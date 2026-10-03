\name{nitrif_n2o_emission}
\alias{nitrif_n2o_emission}
\title{Nitrification-sourced N2O emission}
\description{Manual eq. 201.}
\usage{nitrif_n2o_emission(n_nitri, f_temp, f_n2o_max = 0.01)}
\arguments{\item{n_nitri}{Nitrification rate (g N m-2 d-1).}
\item{f_temp}{Temperature response factor.}
\item{f_n2o_max}{Maximum fraction of nitrification contributing to the N2O pool.}
}
\value{N2O emission rate (g N m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nitrif_n2o_emission(2, 1)}
