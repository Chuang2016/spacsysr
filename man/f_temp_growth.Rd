\name{f_temp_growth}
\alias{f_temp_growth}
\title{Temperature response of growth (beta function)}
\description{0 below t_min / above t_max, 1 at t_opt, smooth in between.}
\usage{f_temp_growth(tavg, t_min, t_opt, t_max)}
\arguments{\item{tavg}{Daily mean temperature (deg C).}
\item{t_min}{Minimum temperature (deg C).}
\item{t_opt}{Optimum temperature (deg C).}
\item{t_max}{Maximum temperature (deg C).}
}
\value{Growth temperature factor (0-1).}
\examples{f_temp_growth(22, 0, 22, 35)}
