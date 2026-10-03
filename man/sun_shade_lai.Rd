\name{sun_shade_lai}
\alias{sun_shade_lai}
\title{Sunlit and shaded leaf area}
\description{L_sun = exp(-k*Lca/cos(theta))*cos(theta)/k_ext (manual p. 25-26; Norman, 1980).}
\usage{sun_shade_lai(lai, theta, chi = 1, k = 0.5)}
\arguments{\item{lai}{Green leaf area index of the canopy layer.}
\item{theta}{Solar zenith angle in radians.}
\item{chi}{Leaf-angle parameter.}
\item{k}{Extinction-related coefficient.}
}
\value{Named vector c(sun, shade).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{sun_shade_lai(3, 0.5)}
