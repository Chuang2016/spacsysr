\name{unsat_conductivity}
\alias{unsat_conductivity}
\title{Unsaturated hydraulic conductivity}
\description{Brooks-Corey (manual eq. 300) and van Genuchten-Mualem with temperature correction (eq. 302). NOTE: the manual printed VG-Mualem form (eq. 301) differs from the standard Mualem expression and is flagged "check against code"; the standard form is implemented.}
\usage{unsat_conductivity(psi, params, t_soil = 20)}
\arguments{\item{psi}{Soil water tension (cm, >= 0).}
\item{params}{Parameter list: retention ("vg"/"bc"), theta_r, theta_s, alpha, n, psia, lambda, tau, k_sat (m d-1), k_min (m d-1).}
\item{t_soil}{Soil temperature (degrees C).}
}
\value{Hydraulic conductivity (m d-1).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{unsat_conductivity(seq(10, 1000, by = 100), list(retention = "vg", alpha = 0.02, n = 1.5, theta_r = 0.05, theta_s = 0.45, k_sat = 0.5))}
