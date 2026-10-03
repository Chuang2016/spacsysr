\name{nitrif_no_emission}
\alias{nitrif_no_emission}
\title{Nitrification-sourced NO emission}
\description{Manual eq. 200, after the DNDC approach (Li, 2000).}
\usage{nitrif_no_emission(n_nitri, f_temp, f_no_max = 0.01)}
\arguments{\item{n_nitri}{Nitrification rate (g N m-2 d-1).}
\item{f_temp}{Temperature response factor.}
\item{f_no_max}{Maximum fraction of nitrification contributing to the NO pool.}
}
\value{NO emission rate (g N m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nitrif_no_emission(2, 1)}
