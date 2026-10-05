\name{forecast_yield_ensemble}
\alias{forecast_yield_ensemble}
\title{Ensemble yield forecast from a weather chain}
\description{Runs \code{\link{spacsys_lite_run}} once per scenario tail over the stitched full-season weather and summarises the ensemble: above-ground biomass (leaf + stem + grain) trajectories as P10/P50/P90 bands and the final grain-yield distribution.}
\usage{
forecast_yield_ensemble(obs, nwp, tails, soil, crop = crop_default_params(),
  params = spacsys_default_params(), n_inputs = NULL, lat_deg = 35,
  ponding = FALSE)
}
\arguments{
\item{obs, nwp, tails}{As in \code{\link{stitch_weather}} / \code{\link{tail_scenarios}} (\code{tails} is a list).}
\item{soil, crop, params, n_inputs, lat_deg, ponding}{As in \code{\link{spacsys_lite_run}}.}
}
\value{A list with \code{runs} (one lite-model output per member), \code{agb} (data.frame: \code{date}, \code{p10}, \code{p50}, \code{p90}, \code{mean}, \code{sd} of above-ground biomass, g DM m-2), \code{yield} (list with \code{values}, \code{mean}, \code{sd}, \code{p10}, \code{p50}, \code{p90} in g m-2 and \code{mean_t_ha}), \code{n_ens} and \code{issue_date}.}
\examples{
\dontrun{
ens <- forecast_yield_ensemble(obs, nwp, tails, soil,
  crop = crop_default_params("rice"), n_inputs = fert,
  lat_deg = 32, ponding = list(target_mm = 40))
ens$yield$mean_t_ha
}
}
