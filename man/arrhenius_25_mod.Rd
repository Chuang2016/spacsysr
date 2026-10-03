\name{arrhenius_25_mod}
\alias{arrhenius_25_mod}
\title{Modified Arrhenius temperature response}
\description{Adds high-temperature deactivation (manual p. 25); used for Jmax, epsilon_p, gm, gbs.}
\usage{arrhenius_25_mod(x25, E, D, S, t_leaf)}
\arguments{\item{x25}{Parameter value at 25 C.}
\item{E}{Activation energy (J mol-1).}
\item{D}{Deactivation energy (J mol-1).}
\item{S}{Entropy term (J mol-1 K-1).}
\item{t_leaf}{Leaf temperature (degrees C).}
}
\value{Parameter value at leaf temperature.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{arrhenius_25_mod(140, 43540, 200000, 650, 25)}
