\name{hindcast_experiment}
\alias{hindcast_experiment}
\alias{hindcast_skill}
\title{Rolling hindcast: does the yield forecast converge through the season?}
\description{Leave-one-year-out hindcast protocol. For each planting year, the "true" yield is the lite-model run on the full observed season (perfect-model setup: this validates the \emph{forecast-chain design}, not the crop model itself -- real validation needs measured yields). Then, at each issue date, the chain is built from observed weather so far + a synthetic NWP forecast (\code{\link{synthetic_nwp}}) + analogue-year tails (\code{\link{tail_scenarios}}, donor years exclude the hindcast year), and the ensemble-mean yield is compared with the true yield. Use \code{\link{hindcast_skill}} to aggregate into the RMSE-vs-issue-date convergence curve.}
\usage{
hindcast_experiment(hist, start_md, end_md, issue_mds, n_ens = 20,
  horizon = 10, soil, crop = crop_default_params(),
  params = spacsys_default_params(), n_inputs = NULL, lat_deg = 35,
  ponding = FALSE, nwp_args = list(), seed = NULL)
hindcast_skill(hind)
}
\arguments{
\item{hist}{Multi-year weather table (see \code{\link{season_slice}}).}
\item{start_md, end_md}{Season bounds (\code{"MM-DD"}).}
\item{issue_mds}{Character vector of issue dates (\code{"MM-DD"}), in chronological season order.}
\item{n_ens}{Number of ensemble members per forecast.}
\item{horizon}{NWP horizon in days.}
\item{soil, crop, params, lat_deg, ponding}{As in \code{\link{spacsys_lite_run}}.}
\item{n_inputs}{Fertiliser data.frame (absolute dates) or a function \code{function(pyear)} returning one (so dates shift with the hindcast year).}
\item{nwp_args}{Extra arguments passed to \code{\link{synthetic_nwp}}.}
\item{hind}{data.frame from \code{hindcast_experiment}.}
\item{seed}{Optional seed for reproducibility.}
}
\value{\code{hindcast_experiment} returns a data.frame with one row per (year, issue date): \code{pyear}, \code{issue_md}, \code{issue_order}, \code{issue_date}, \code{y_true}, \code{y_mean}, \code{y_sd}, \code{y_p10}, \code{y_p50}, \code{y_p90}, \code{err} (ensemble mean minus true, g m-2), \code{clim} (leave-one-out climatological yield forecast, g m-2). \code{hindcast_skill} aggregates to one row per issue date: \code{issue_md}, \code{issue_order}, \code{n_years}, \code{rmse}, \code{bias}, \code{mae} (t ha-1), \code{mean_spread} (t ha-1), \code{rmse_clim} and \code{skill} = 1 - rmse/rmse_clim.}
\examples{
\dontrun{
hind <- hindcast_experiment(hist, "06-10", "10-20",
  issue_mds = c("07-01", "08-01", "09-01"),
  n_ens = 30, soil = soil, crop = crop_default_params("rice"),
  n_inputs = function(py) fert_for_year(py),
  lat_deg = 32, ponding = list(target_mm = 40), seed = 1)
sk <- hindcast_skill(hind)
plot(rmse ~ issue_order, data = sk, type = "b")
}
}
