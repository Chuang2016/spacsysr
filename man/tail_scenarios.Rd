\name{tail_scenarios}
\alias{tail_scenarios}
\title{Draw scenario tails from historical analogue years}
\description{For the part of the season beyond the NWP horizon, each ensemble member borrows the corresponding calendar window from one historical year (analogue-year resampling, which preserves the real temporal structure of weather). Dates are re-based onto the current season so the chain stays contiguous.}
\usage{
tail_scenarios(hist, pyear, start_md, end_md, tail_start, n_ens = 30,
  exclude = NULL, seed = NULL)
}
\arguments{
\item{hist}{Multi-year weather table (see \code{\link{season_slice}}).}
\item{pyear}{Current planting year.}
\item{start_md, end_md}{Season bounds (\code{"MM-DD"}).}
\item{tail_start}{First Date needing a scenario (the day after the NWP window ends).}
\item{n_ens}{Number of ensemble members.}
\item{exclude}{Planting years to exclude from the draw (the hindcast year itself is excluded automatically via \code{pyear}).}
\item{seed}{Optional seed for the year draw (the global RNG state is restored afterwards).}
}
\value{A list of \code{n_ens} data.frames with \code{date}, \code{tmax}, \code{tmin}, \code{precip}.}
\examples{
\dontrun{
tails <- tail_scenarios(hist, 2021, "06-10", "10-20",
  tail_start = as.Date("2021-08-26"), n_ens = 30)
}
}
