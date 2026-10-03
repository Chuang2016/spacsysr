\name{moisture_capacity}
\alias{moisture_capacity}
\title{Specific moisture capacity d(theta)/d(psi)}
\description{Analytical derivative of the retention curve; used in the Picard-linearised Richards solver.}
\usage{moisture_capacity(psi, params)}
\arguments{\item{psi}{Soil water tension (cm, >= 0).}
\item{params}{Parameter list (see richards_1d).}
}
\value{d(theta)/d(psi) (cm-1), negative.}
\examples{moisture_capacity(100, list(retention = "vg", alpha = 0.02, n = 1.5, theta_r = 0.05, theta_s = 0.45))}
