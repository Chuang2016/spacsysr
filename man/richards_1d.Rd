\name{richards_1d}
\alias{richards_1d}
\title{1-D Richards equation solver (vertical soil water movement)}
\description{Implicit psi-based finite differences with Picard iteration and Thomas tridiagonal solve for the manual eq. (299). Conventions: tension positive (cm), depth downward (m), flux downward positive.}
\usage{richards_1d(psi_init, dz_m, params, dt_day = 1, n_sub = 24, top_flux = 0, pond_ok = TRUE, bottom_bc = c("free", "fixed"), psi_bottom = 100, source = 0, t_soil = 20, picard_tol = 1e-4, max_picard = 30)}
\arguments{\item{psi_init}{Initial soil water tension per node (cm, >= 0).}
\item{dz_m}{Node spacing (m, uniform).}
\item{params}{Parameter list for unsat_conductivity.}
\item{dt_day}{Time step in days.}
\item{n_sub}{Number of sub-steps.}
\item{top_flux}{Surface water flux (m d-1, downward positive).}
\item{pond_ok}{Allow switch to ponded (psi = 0) top boundary when the surface saturates.}
\item{bottom_bc}{"free" (unit-gradient drainage) or "fixed".}
\item{psi_bottom}{Bottom tension for bottom_bc = "fixed" (cm).}
\item{source}{Sink/source per node (d-1, root uptake negative).}
\item{t_soil}{Soil temperature (degrees C).}
\item{picard_tol}{Picard tolerance.}
\item{max_picard}{Max Picard iterations.}
}
\value{A list with psi (cm), theta, drainage_m, runoff_m and n_iter.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{p <- list(retention = "vg", theta_r = 0.05, theta_s = 0.45, alpha = 0.02, n = 1.5, k_sat = 0.5)
richards_1d(rep(200, 10), 0.1, p, top_flux = 0.02)$psi}
