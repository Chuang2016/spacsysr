\name{soil_init}
\alias{soil_init}
\title{Build a layered soil table from minimal inputs}
\description{Helper that assembles the soil data.frame required by spacsys_lite_run from per-layer (or scalar) properties. Soil organic carbon is split into litter and humus pools via litter_frac.}
\usage{soil_init(depth_mm, fc = 0.30, wp = 0.12, sat = 0.45, bulk_density = 1.35, ph = 6.5, soc = 3000, litter_frac = 0.05, nh4_init = 1, no3_init = 3, theta_init = NULL, ch4_init = 0)}
\arguments{\item{depth_mm}{Layer thicknesses (mm).}
\item{fc, wp, sat}{Field capacity, wilting point, saturation (volumetric fractions); scalars are recycled to all layers.}
\item{bulk_density}{Bulk density (g cm-3); scalar or per layer.}
\item{ph}{Soil pH; scalar or per layer.}
\item{soc}{Soil organic carbon (g C m-2); scalar or per layer.}
\item{litter_frac}{Fraction of SOC initialised as litter (default 0.05).}
\item{nh4_init, no3_init}{Initial mineral N (g N m-2); scalar or per layer.}
\item{theta_init}{Initial water content (fraction); defaults to the midpoint of wilting point and field capacity.}
\item{ch4_init}{Initial soil CH4 concentration (g CH4 m-3 soil).}
}
\value{A soil data.frame with one row per layer.}
\examples{soil_init(c(200, 300, 500))}
