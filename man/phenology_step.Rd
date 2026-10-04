\name{phenology_step}
\alias{phenology_step}
\title{Advance thermal-time phenology}
\description{Development index Dindex (0-3) advances by GDD / ADD_req,stage within the current stage (manual p. 18, simplified: no photoperiod/vernalisation terms).}
\usage{phenology_step(dindex, gdd, add_req)}
\arguments{\item{dindex}{Current development index (0-3).}
\item{gdd}{Daily thermal time (deg C d).}
\item{add_req}{Thermal-time requirement per stage (deg C d).}
}
\value{Updated development index.}
\examples{phenology_step(0.5, 12, c(120, 1000, 800))}
