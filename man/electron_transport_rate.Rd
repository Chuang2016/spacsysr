\name{electron_transport_rate}
\alias{electron_transport_rate}
\title{Potential electron transport rate}
\description{Non-rectangular hyperbola (Evans & Farquhar, 1991; manual p. 21).}
\usage{electron_transport_rate(i2, jmax, theta = 0.7)}
\arguments{\item{i2}{Electron-transport photon flux (umol m-2 s-1).}
\item{jmax}{Maximum electron transport rate (umol m-2 s-1).}
\item{theta}{Curvature parameter.}
}
\value{J (umol m-2 s-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{electron_transport_rate(500, 140)}
