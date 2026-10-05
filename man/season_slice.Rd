\name{season_slice}
\alias{season_slice}
\alias{available_pyears}
\title{Slice crop seasons out of a multi-year weather table}
\description{Extract one crop season (or list the planting years with complete seasons) from a multi-year daily weather table. Season bounds are "MM-DD" strings; when \code{end_md < start_md} (e.g. winter wheat sown in October, harvested in June) the season ends in \code{pyear + 1}.}
\usage{
season_slice(hist, pyear, start_md, end_md)
available_pyears(hist, start_md, end_md)
}
\arguments{
\item{hist}{data.frame with \code{date} (Date), \code{tmax}, \code{tmin} (deg C), \code{precip} (mm d-1), covering several years.}
\item{pyear}{Planting year (the year the season starts).}
\item{start_md, end_md}{Season bounds as \code{"MM-DD"} strings.}
}
\value{\code{season_slice} returns the season's weather rows sorted by date (an error is raised when days are missing). \code{available_pyears} returns the sorted integer vector of planting years fully covered by \code{hist}.}
\examples{
\dontrun{
rice2021 <- season_slice(hist, 2021, "06-10", "10-20")
wheat2021 <- season_slice(hist, 2021, "10-15", "06-15")
available_pyears(hist, "06-10", "10-20")
}
}
