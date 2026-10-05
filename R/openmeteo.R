## Real NWP forecasts via the free Open-Meteo API (no key needed) -------------------
## Drop-in replacements for synthetic_nwp() output:
##   openmeteo_forecast() -> one deterministic forecast data.frame
##   openmeteo_ensemble() -> named list of per-member data.frames
## Both return date/tmax/tmin/precip (+rad) ready for stitch_weather().
## Pure base R: the small daily-array JSON subset is parsed by hand so the
## package keeps zero dependencies.

.om_fetch <- function(url) {
  tryCatch({
    con <- url(url)
    on.exit(close(con))
    txt <- paste(readLines(con, warn = FALSE), collapse = "")
    if (!nzchar(txt)) stop("empty response")
    txt
  }, error = function(e)
    stop("openmeteo download failed: ", conditionMessage(e),
         "\nURL: ", url, call. = FALSE))
}

## Parse the "daily" flat arrays out of an Open-Meteo JSON response.
## Only handles "key":[...] with numbers, ISO dates or nulls -- the
## subset this module needs.
.om_daily_arrays <- function(txt) {
  pat <- '"([A-Za-z0-9_]+)":\\[([^\\]]*)\\]'
  m <- gregexpr(pat, txt, perl = TRUE)
  hits <- regmatches(txt, m)[[1]]
  if (!length(hits))
    stop("openmeteo: no daily arrays found in response", call. = FALSE)
  keys <- sub(pat, "\\1", hits, perl = TRUE)
  vals <- lapply(hits, function(h) {
    inner <- sub('^"[^"]+":\\[', "", h)
    inner <- sub("\\]$", "", inner)
    if (!nzchar(inner)) return(numeric(0))
    parts <- trimws(strsplit(inner, ",", fixed = TRUE)[[1]])
    parts <- gsub('^"|"$', "", parts)  # unquote ISO dates
    parts[parts == "null"] <- NA_character_
    if (all(is.na(parts) |
            grepl("^-?[0-9.]+([eE][-+]?[0-9]+)?$", parts)))
      suppressWarnings(as.numeric(parts))
    else
      parts
  })
  names(vals) <- keys
  vals[!duplicated(names(vals))]
}

.om_num <- function(x, n, what) {
  v <- suppressWarnings(as.numeric(x))
  if (length(v) != n)
    stop("openmeteo: ragged '", what, "' array in response",
         call. = FALSE)
  v
}

.om_url <- function(base, lat, lon, daily, timezone, forecast_days,
                    extra = "") {
  sprintf(paste0("%s?latitude=%s&longitude=%s&daily=%s&timezone=%s",
                 "&forecast_days=%d%s"),
          base, lat, lon, paste(daily, collapse = ","),
          utils::URLencode(timezone, reserved = TRUE),
          forecast_days, extra)
}

.om_frame <- function(d, with_rad = TRUE) {
  need <- c("time", "temperature_2m_max", "temperature_2m_min",
            "precipitation_sum")
  if (!all(need %in% names(d)))
    stop("openmeteo: missing variables in response", call. = FALSE)
  n <- length(d$time)
  df <- data.frame(
    date = as.Date(d$time),
    tmax = .om_num(d$temperature_2m_max, n, "temperature_2m_max"),
    tmin = .om_num(d$temperature_2m_min, n, "temperature_2m_min"),
    precip = pmax(.om_num(d$precipitation_sum, n,
                          "precipitation_sum"), 0))
  if (with_rad && "shortwave_radiation_sum" %in% names(d))
    df$rad <- .om_num(d$shortwave_radiation_sum, n,
                      "shortwave_radiation_sum")
  ## the API returns null for past days without data -- drop them
  ## (rad may stay NA: weather_complete() estimates it from temperature)
  df <- df[!is.na(df$tmax) & !is.na(df$tmin) & !is.na(df$precip), ,
           drop = FALSE]
  rownames(df) <- NULL
  df
}

#' Fetch a deterministic short-term forecast from Open-Meteo
#'
#' Downloads the free Open-Meteo deterministic forecast (no API key)
#' and returns it in the same shape as
#' \code{\link{synthetic_nwp}} output, so it plugs straight into
#' \code{\link{stitch_weather}}: replace the synthetic NWP segment
#' with this in operations.
#'
#' @param lat,lon site coordinates (decimal degrees).
#' @param horizon forecast horizon in days (max 16).
#' @param past_days prepend that many recent days (a reanalysis/obs
#'   blend) -- convenience only; prefer your own station observations
#'   for the observed segment.
#' @param timezone timezone for the daily aggregation, default
#'   \code{"Asia/Shanghai"}.
#' @return A data.frame with \code{date}, \code{tmax}, \code{tmin}
#'   (deg C), \code{precip} (mm d-1) and \code{rad} (MJ m-2 d-1).
#' @references https://open-meteo.com/en/docs
#' @export
openmeteo_forecast <- function(lat, lon, horizon = 10, past_days = 0,
                               timezone = "Asia/Shanghai") {
  daily <- c("temperature_2m_max", "temperature_2m_min",
             "precipitation_sum", "shortwave_radiation_sum")
  url <- .om_url("https://api.open-meteo.com/v1/forecast",
                 lat, lon, daily, timezone, horizon,
                 sprintf("&past_days=%d", past_days))
  .om_frame(.om_daily_arrays(.om_fetch(url)))
}

#' Fetch an NWP ensemble from Open-Meteo
#'
#' Downloads one model's ensemble (default ICON seamless EPS, 40
#' members: control + 39 perturbed) from the free Open-Meteo
#' ensemble API. Each member is a drop-in NWP segment; pass the list
#' (or a subset) as the \code{nwp} argument of
#' \code{\link{forecast_yield_ensemble}} together with one scenario
#' tail per member for a fully NWP-driven ensemble.
#'
#' @param lat,lon site coordinates (decimal degrees).
#' @param horizon forecast horizon in days (max 16).
#' @param model single ensemble model, e.g. \code{"icon_seamless"}
#'   or \code{"gfs_seamless"}.
#' @param timezone timezone for the daily aggregation, default
#'   \code{"Asia/Shanghai"}.
#' @return A named list of data.frames (\code{date}, \code{tmax},
#'   \code{tmin}, \code{precip}, \code{rad}), one per member.
#' @references https://open-meteo.com/en/docs/ensemble-api
#' @export
openmeteo_ensemble <- function(lat, lon, horizon = 7,
                               model = "icon_seamless",
                               timezone = "Asia/Shanghai") {
  daily <- c("temperature_2m_max", "temperature_2m_min",
             "precipitation_sum", "shortwave_radiation_sum")
  url <- .om_url("https://ensemble-api.open-meteo.com/v1/ensemble",
                 lat, lon, daily, timezone, horizon,
                 sprintf("&models=%s", model))
  d <- .om_daily_arrays(.om_fetch(url))
  n <- length(d$time)
  suffixes <- unique(sub("^temperature_2m_max", "",
                         names(d)[grepl("^temperature_2m_max",
                                        names(d))]))
  members <- lapply(suffixes, function(sfx) {
    getv <- function(v) {
      k <- paste0(v, sfx)
      if (!k %in% names(d))
        stop("openmeteo: incomplete member '", sfx, "' in response",
             call. = FALSE)
      .om_num(d[[k]], n, k)
    }
    data.frame(date = as.Date(d$time),
               tmax = getv("temperature_2m_max"),
               tmin = getv("temperature_2m_min"),
               precip = pmax(getv("precipitation_sum"), 0),
               rad = getv("shortwave_radiation_sum"))
  })
  names(members) <- paste0(model,
                           ifelse(suffixes == "", "_control", suffixes))
  members
}
