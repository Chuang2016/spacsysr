\name{stitch_weather}
\alias{stitch_weather}
\title{Stitch the three-segment weather chain}
\description{Concatenates observed weather (up to the issue date), the NWP forecast and one scenario tail into a single full-season weather table ready for \code{\link{spacsys_lite_run}}. Warns (rather than fails) when segment boundaries are not exactly contiguous, so that slightly ragged real-world inputs still run.}
\usage{stitch_weather(obs, nwp, tail)}
\arguments{
\item{obs}{Observed weather, \code{date <= issue_date}.}
\item{nwp}{Forecast weather for the days after the issue date (e.g. from \code{\link{synthetic_nwp}} or a real NWP product).}
\item{tail}{One scenario realisation of the remaining season (may be a 0-row data.frame when the issue date is at the very end of the season).}
}
\value{A single weather data.frame with \code{date}, \code{tmax}, \code{tmin}, \code{precip} (plus any of \code{rad}, \code{sunshine}, \code{pet}, \code{irrig} present in all three inputs).}
\examples{
\dontrun{
full_weather <- stitch_weather(obs, nwp, tails[[1]])
}
}
