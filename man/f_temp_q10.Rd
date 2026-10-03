\name{f_temp_q10}
\alias{f_temp_q10}
\title{Q10 temperature response factor}
\description{Implements the Q10 temperature response used throughout SPACSYS (manual eq. 39).}
\usage{f_temp_q10(temp, q10 = 2, t_base = 20)}
\arguments{\item{temp}{Temperature in degrees C.}
\item{q10}{Q10 value.}
\item{t_base}{Temperature at which the factor is unity.}
}
\value{Numeric vector of response factors.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_temp_q10(c(10, 20, 30))}
