\name{synthetic_nwp}
\alias{synthetic_nwp}
\title{Degrade true future weather into a synthetic NWP forecast}
\description{Hindcast-lab stand-in for a real 7-10 day numerical weather forecast: adds lead-time-dependent error to the actual future weather. Temperature error is AR(1) in lead time with growing innovation variance (the same perturbation shifts \code{tmax} and \code{tmin}, mimicking correlated NWP temperature error); precipitation occurrence is flipped with a lead-time-growing probability and wet-day amounts are multiplied by log-normal noise. In operations, replace the output of this function with a real forecast (e.g. CMA / ECMWF / Open-Meteo daily \code{temperature_2m_max}, \code{temperature_2m_min}, \code{precipitation_sum}).}
\usage{
synthetic_nwp(actual, horizon = 10, temp_sd0 = 0.5, temp_sd_day = 0.25,
  temp_ar1 = 0.6, pflip_day = 0.02, amt_sd0 = 0.1, amt_sd_day = 0.08)
}
\arguments{
\item{actual}{data.frame with \code{date}, \code{tmax}, \code{tmin}, \code{precip}, starting the day after the issue date.}
\item{horizon}{Forecast horizon in days (default 10).}
\item{temp_sd0, temp_sd_day}{Base and per-day growth of the temperature error SD (deg C).}
\item{temp_ar1}{AR(1) coefficient of the temperature error across lead time.}
\item{pflip_day}{Per-day growth of the wet/dry flip probability (capped at 0.3).}
\item{amt_sd0, amt_sd_day}{Base and per-day growth of the log-amount noise SD.}
}
\value{A data.frame with \code{date}, \code{tmax}, \code{tmin}, \code{precip} and \code{min(horizon, nrow(actual))} rows.}
\examples{
\dontrun{
fut <- season[season$date > issue_date, ]
nwp <- synthetic_nwp(fut, horizon = 10)
}
}
