\name{openmeteo_forecast}
\alias{openmeteo_forecast}
\alias{openmeteo_ensemble}
\title{Fetch real NWP forecasts from Open-Meteo}
\description{Downloads the free Open-Meteo forecast products (no API key) for direct use in the forecast chain. \code{openmeteo_forecast()} returns one deterministic forecast in the same shape as \code{\link{synthetic_nwp}} output -- a drop-in replacement for the synthetic NWP segment in operations. \code{openmeteo_ensemble()} returns one model's ensemble (default ICON seamless EPS, 40 members: control + 39 perturbed); pass the member list as the \code{nwp} argument of \code{\link{forecast_yield_ensemble}} together with one scenario tail per member for a fully NWP-driven ensemble.}
\usage{
openmeteo_forecast(lat, lon, horizon = 10, past_days = 0,
  timezone = "Asia/Shanghai")
openmeteo_ensemble(lat, lon, horizon = 7, model = "icon_seamless",
  timezone = "Asia/Shanghai")
}
\arguments{
\item{lat, lon}{Site coordinates (decimal degrees).}
\item{horizon}{Forecast horizon in days (max 16).}
\item{past_days}{\code{openmeteo_forecast()} only: prepend that many recent days (a reanalysis/obs blend) -- convenience only; prefer your own station observations for the observed segment.}
\item{model}{\code{openmeteo_ensemble()} only: single ensemble model, e.g. \code{"icon_seamless"} or \code{"gfs_seamless"}.}
\item{timezone}{Timezone for the daily aggregation, default \code{"Asia/Shanghai"}.}
}
\value{\code{openmeteo_forecast()} returns a data.frame with \code{date}, \code{tmax}, \code{tmin} (deg C), \code{precip} (mm d-1) and \code{rad} (MJ m-2 d-1). \code{openmeteo_ensemble()} returns a named list of such data.frames, one per member. Days for which the API returns no data (leading \code{past_days} with \code{null}) are dropped.}
\references{https://open-meteo.com/en/docs and https://open-meteo.com/en/docs/ensemble-api}
\examples{
\dontrun{
fc <- openmeteo_forecast(31.86, 117.28, horizon = 10)  # Hefei
head(fc)
ens <- openmeteo_ensemble(31.86, 117.28, horizon = 7)
length(ens)
}
}
