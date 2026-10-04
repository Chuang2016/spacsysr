\name{weather_complete}
\alias{weather_complete}
\title{Complete a weather table with minimal inputs}
\description{Fills in missing rad (via rad_hargreaves) and pet (via pet_hargreaves or pet_priestley_taylor when rad is present), plus tavg, doy and gdd columns. The input only needs date, tmax, tmin and precip.}
\usage{weather_complete(weather, lat_deg, t_base = 8, pet_method = c("auto", "hargreaves", "priestley_taylor"))}
\arguments{\item{weather}{data.frame with date (Date), tmax, tmin (deg C), precip (mm d-1); optional rad (MJ m-2 d-1) and pet (mm d-1).}
\item{lat_deg}{Latitude (decimal degrees, +N).}
\item{t_base}{Base temperature for thermal time (deg C).}
\item{pet_method}{"auto" (default), "hargreaves" or "priestley_taylor".}
}
\value{The completed weather data.frame.}
\examples{
w <- data.frame(date = as.Date("2026-05-01") + 0:2, tmax = c(26,27,28),
  tmin = c(15,16,17), precip = c(0,5,0))
weather_complete(w, 35)
}
