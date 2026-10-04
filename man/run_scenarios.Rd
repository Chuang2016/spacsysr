\name{run_scenarios}
\alias{run_scenarios}
\title{Batch-run management scenarios and compare carbon footprints}
\description{Runs \code{\link{spacsys_lite_run}} once per scenario and binds a one-row-per-scenario summary: grain yield, water/N stress days and the seasonal GHG budget from \code{\link{ghg_footprint}}.}
\usage{run_scenarios(base_weather, soil, crop = crop_default_params(), scenarios, lat_deg = 35, params = spacsys_default_params(), ...)}
\arguments{
  \item{base_weather}{baseline weather data.frame; each scenario modifies a copy.}
  \item{soil}{soil data.frame from \code{\link{soil_init}}.}
  \item{crop}{default crop parameter list; scenarios may override.}
  \item{scenarios}{named list of scenario specs: \code{precip_scale}, \code{irrig} (\code{FALSE}/\code{TRUE}/numeric), \code{n_inputs}, \code{ponding}, \code{crop}.}
  \item{lat_deg}{latitude (decimal degrees, +N).}
  \item{params}{parameter list from \code{\link{spacsys_default_params}}.}
  \item{...}{passed to \code{\link{ghg_footprint}}.}
}
\value{A data.frame, one row per scenario.}
\examples{
\dontrun{
run_scenarios(w, soil, crop_default_params("rice"),
  list("paddy" = list(ponding = list(target_mm = 30)),
       "AWD"   = list(irrig = TRUE)), lat_deg = 30)
}
}
