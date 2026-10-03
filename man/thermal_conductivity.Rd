\name{thermal_conductivity}
\alias{thermal_conductivity}
\title{Soil thermal conductivity}
\description{Organic: de Vries (1975), k = 0.54 + 0.023*theta_pct (manual eq. 245). Mineral: the manual Kersten form (eq. 248-249) needs Table 3 parameters absent from the extracted text, so a simple linear placeholder is used (clearly marked).}
\usage{thermal_conductivity(theta, soil = c("mineral", "organic"))}
\arguments{\item{theta}{Volumetric water content (fraction).}
\item{soil}{"organic" or "mineral".}
}
\value{Thermal conductivity (W m-1 K-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{thermal_conductivity(seq(0.1, 0.5, by = 0.1), "organic")}
