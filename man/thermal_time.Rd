\name{thermal_time}
\alias{thermal_time}
\title{Daily thermal time}
\description{Growing degree days with a base temperature and an upper cutoff: GDD = max(0, min(Tavg, Tmax) - Tbase).}
\usage{thermal_time(tavg, t_base, t_max = 35)}
\arguments{\item{tavg}{Daily mean temperature (deg C).}
\item{t_base}{Base temperature (deg C).}
\item{t_max}{Upper cutoff temperature (deg C), default 35.}
}
\value{Thermal time (deg C d).}
\examples{thermal_time(22, 8)}
