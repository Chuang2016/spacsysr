\name{plant_growth_step}
\alias{plant_growth_step}
\title{Daily lite crop growth step}
\description{Potential growth follows intercepted PAR and radiation use efficiency; actual growth is co-limited by temperature, water (transpiration ratio) and nitrogen (supply/demand). New biomass is partitioned to organs by development stage; senesced leaf becomes litter; roots elongate with thermal time.}
\usage{plant_growth_step(state, rad, tavg, gdd, f_w, n_avail, crop = crop_default_params())}
\arguments{\item{state}{Crop state list from plant_init.}
\item{rad}{Incoming solar radiation (MJ m-2 d-1).}
\item{tavg}{Daily mean temperature (deg C).}
\item{gdd}{Daily thermal time (deg C d).}
\item{f_w}{Water stress factor (actual/potential transpiration, 0-1).}
\item{n_avail}{Mineral N available for uptake today (g N m-2).}
\item{crop}{Crop parameter list.}
}
\value{A list with the updated state and daily fluxes: growth, n_demand, n_uptake, f_t, f_w, f_n, dindex, litter_c, litter_n (g C / g N m-2 d-1).}
\examples{
s <- plant_init(); g <- plant_growth_step(s, 20, 22, 14, 1, 5); g$growth
}
