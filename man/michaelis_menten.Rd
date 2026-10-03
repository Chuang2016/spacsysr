\name{michaelis_menten}
\alias{michaelis_menten}
\title{Michaelis-Menten substrate response}
\description{Manual eq. 192.}
\usage{michaelis_menten(s_con, km50)}
\arguments{\item{s_con}{Substrate concentration (g m-3).}
\item{km50}{Michaelis constant (g m-3).}
}
\value{Response factor in [0, 1].}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{michaelis_menten(10, 10)}
