\name{nh3_spreading}
\alias{nh3_spreading}
\title{NH3 loss during slurry spreading}
\description{One-off loss on the application day; manual eq. 204.}
\usage{nh3_spreading(tan, lai, w_w, omega = 0.02, eta = 200)}
\arguments{\item{tan}{Ammoniacal N in applied slurry (g N m-2).}
\item{lai}{Leaf area index.}
\item{w_w}{Wet weight of slurry applied (g m-2).}
\item{omega}{Proportion of TAN lost during application.}
\item{eta}{Slurry intercepted per unit leaf area (g m-2).}
}
\value{NH3 volatilised during spreading (g N m-2 d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{nh3_spreading(10, 2, 2000)}
