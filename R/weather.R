## Weather helpers: PET, thermal time, daylength ---------------------------------
## Minimal-input weather processing for the simplified ("lite") model.
## Only daily Tmax/Tmin/precipitation are strictly required; radiation is
## estimated from temperature range when missing (Hargreaves-Samani).

#' Extraterrestrial radiation
#'
#' Daily extraterrestrial radiation \eqn{R_a} (MJ m-2 d-1) after Allen et
#' al. (1998, FAO-56, eq. 21).
#'
#' @param lat_deg latitude (decimal degrees, +N).
#' @param doy day of year (1-366).
#' @return \eqn{R_a} (MJ m-2 d-1).
#' @references Allen, R.G. et al. (1998). FAO Irrigation and Drainage
#'   Paper 56.
#' @export
ra_extraterrestrial <- function(lat_deg, doy) {
  lat <- lat_deg * pi / 180
  dr <- 1 + 0.033 * cos(2 * pi / 365 * doy)
  delta <- 0.409 * sin(2 * pi / 365 * doy - 1.39)
  ws <- acos(pmax(pmin(-tan(lat) * tan(delta), 1), -1))
  24 * 60 / pi * 0.0820 * dr *
    (ws * sin(lat) * sin(delta) + cos(lat) * cos(delta) * sin(ws))
}

#' Daylength
#'
#' Astronomical daylength (hours) from latitude and day of year
#' (Allen et al., 1998, FAO-56).
#'
#' @param lat_deg latitude (decimal degrees, +N).
#' @param doy day of year (1-366).
#' @return Daylength (h).
#' @export
daylength_hours <- function(lat_deg, doy) {
  lat <- lat_deg * pi / 180
  delta <- 0.409 * sin(2 * pi / 365 * doy - 1.39)
  ws <- acos(pmax(pmin(-tan(lat) * tan(delta), 1), -1))
  24 / pi * ws
}

#' Hargreaves reference evapotranspiration
#'
#' \eqn{ET_0 = 0.0023 \, R_a \, \sqrt{T_{max} - T_{min}} \, (T_{avg} + 17.8)}
#' (Hargreaves & Samani, 1985). Needs only temperature plus latitude/day
#' of year; recommended when measured radiation is unavailable.
#'
#' @param tmax daily maximum temperature (deg C).
#' @param tmin daily minimum temperature (deg C).
#' @param lat_deg latitude (decimal degrees, +N).
#' @param doy day of year (1-366).
#' @return Reference evapotranspiration \eqn{ET_0} (mm d-1).
#' @references Hargreaves, G.H. & Samani, Z.A. (1985). Reference crop
#'   evapotranspiration from temperature. \emph{Appl. Eng. Agric.} 1, 96-99.
#' @export
pet_hargreaves <- function(tmax, tmin, lat_deg, doy) {
  tavg <- (tmax + tmin) / 2
  ra_mm <- ra_extraterrestrial(lat_deg, doy) / 2.45  # MJ -> mm water
  0.0023 * ra_mm * sqrt(pmax(tmax - tmin, 0.1)) * (tavg + 17.8)
}

#' Priestley-Taylor evapotranspiration
#'
#' \eqn{ET_0 = \alpha \, \frac{\Delta}{\Delta + \gamma} \,
#'   \frac{R_n}{\lambda}}, with net radiation approximated as
#' \eqn{R_n = 0.75 \, R_s} (simplified; no longwave balance) and
#' \eqn{\lambda = 2.45} MJ kg-1. Use when solar radiation was measured.
#'
#' @param rad_mj incoming solar radiation (MJ m-2 d-1).
#' @param tavg daily mean temperature (deg C).
#' @param alpha Priestley-Taylor coefficient, default 1.26.
#' @return Evapotranspiration (mm d-1).
#' @export
pet_priestley_taylor <- function(rad_mj, tavg, alpha = 1.26) {
  es <- 0.6108 * exp(17.27 * tavg / (tavg + 237.3))       # kPa
  delta <- 4098 * es / (tavg + 237.3)^2                    # kPa degC-1
  gamma <- 0.066                                          # kPa degC-1
  rn <- 0.75 * pmax(rad_mj, 0)
  alpha * delta / (delta + gamma) * rn / 2.45
}

#' Estimate solar radiation from temperature range
#'
#' Hargreaves-Samani radiation estimate
#' \eqn{R_s = k_{Rs} \sqrt{T_{max}-T_{min}} \, R_a} with
#' \eqn{k_{Rs} = 0.16} (interior) or 0.19 (coastal).
#'
#' @param tmax daily maximum temperature (deg C).
#' @param tmin daily minimum temperature (deg C).
#' @param lat_deg latitude (decimal degrees, +N).
#' @param doy day of year (1-366).
#' @param k_rs empirical coefficient, default 0.16.
#' @return Solar radiation (MJ m-2 d-1).
#' @export
rad_hargreaves <- function(tmax, tmin, lat_deg, doy, k_rs = 0.16) {
  k_rs * sqrt(pmax(tmax - tmin, 0.1)) *
    ra_extraterrestrial(lat_deg, doy)
}

#' Daily thermal time
#'
#' Growing degree days with a base temperature and an upper cutoff:
#' \eqn{GDD = \max(0, \min(T_{avg}, T_{max}) - T_{base})}.
#'
#' @param tavg daily mean temperature (deg C).
#' @param t_base base temperature (deg C).
#' @param t_max upper cutoff temperature (deg C), default 35.
#' @return Thermal time (deg C d).
#' @export
thermal_time <- function(tavg, t_base, t_max = 35) {
  pmax(0, pmin(tavg, t_max) - t_base)
}

#' Complete a weather table with minimal inputs
#'
#' Fills in missing \code{rad} (via \code{\link{rad_hargreaves}}) and
#' \code{pet} (via \code{\link{pet_hargreaves}} or
#' \code{\link{pet_priestley_taylor}} when \code{rad} is present), plus
#' \code{tavg}, \code{doy} and \code{gdd} columns. The input only needs
#' \code{date}, \code{tmax}, \code{tmin} and \code{precip}.
#'
#' @param weather data.frame with \code{date} (Date), \code{tmax},
#'   \code{tmin} (deg C), \code{precip} (mm d-1); optional \code{rad}
#'   (MJ m-2 d-1) and \code{pet} (mm d-1).
#' @param lat_deg latitude (decimal degrees, +N).
#' @param t_base base temperature for thermal time (deg C).
#' @param pet_method \code{"auto"} (default), \code{"hargreaves"} or
#'   \code{"priestley_taylor"}.
#' @return The completed weather data.frame.
#' @export
weather_complete <- function(weather, lat_deg, t_base = 8,
                             pet_method = c("auto", "hargreaves",
                                            "priestley_taylor")) {
  pet_method <- match.arg(pet_method)
  weather$date <- as.Date(weather$date)
  weather$tavg <- (weather$tmax + weather$tmin) / 2
  weather$doy <- as.integer(format(weather$date, "%j"))
  rad_given <- "rad" %in% names(weather) && any(!is.na(weather$rad))
  if (!"rad" %in% names(weather)) weather$rad <- NA_real_
  miss_rad <- is.na(weather$rad)
  if (any(miss_rad))
    weather$rad[miss_rad] <- rad_hargreaves(weather$tmax[miss_rad],
                                            weather$tmin[miss_rad],
                                            lat_deg, weather$doy[miss_rad])
  if (!"pet" %in% names(weather)) weather$pet <- NA_real_
  miss_pet <- is.na(weather$pet)
  if (any(miss_pet)) {
    use_pt <- (pet_method == "priestley_taylor") ||
      (pet_method == "auto" && rad_given)
    weather$pet[miss_pet] <- if (use_pt)
      pet_priestley_taylor(weather$rad[miss_pet], weather$tavg[miss_pet])
    else
      pet_hargreaves(weather$tmax[miss_pet], weather$tmin[miss_pet],
                     lat_deg, weather$doy[miss_pet])
  }
  weather$gdd <- thermal_time(weather$tavg, t_base)
  weather
}
