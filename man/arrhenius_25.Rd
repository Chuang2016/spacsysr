\name{arrhenius_25}
\alias{arrhenius_25}
\title{Arrhenius temperature response (25 C normalised)}
\description{X = X25 * exp((1/298 - 1/(273+Tl)) * E/R) (manual p. 24).}
\usage{arrhenius_25(x25, E, t_leaf)}
\arguments{\item{x25}{Parameter value at 25 C.}
\item{E}{Activation energy (J mol-1).}
\item{t_leaf}{Leaf temperature (degrees C).}
}
\value{Parameter value at leaf temperature.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{arrhenius_25(80, 58550, 25)}
