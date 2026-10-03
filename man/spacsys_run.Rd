\name{spacsys_run}
\alias{spacsys_run}
\title{Simplified daily SPACSYS-biogeochemistry driver}
\description{Daily loop coupling the package modules across soil layers. A research scaffold with first-order pool bookkeeping, not a full SPACSYS simulation (no Richards water flow, no plant growth feedback, simplified mineralisation).}
\usage{spacsys_run(weather, soil, params = spacsys_default_params(), method = c("simplified", "microbial"), n_inputs = NULL)}
\arguments{\item{weather}{data.frame with date, tavg, precip, pet (optional tsoil).}
\item{soil}{data.frame, one row per layer: depth_mm, bulk_density, ph, fc, wp, sat, theta_init, c_litter, c_humus, c_doc, nh4, no3, bn, bd.}
\item{params}{Parameter list from spacsys_default_params().}
\item{method}{"simplified" or "microbial" nitrification/denitrification formulation.}
\item{n_inputs}{Optional fertiliser/slurry events: data.frame with date, nh4_add, no3_add, tan_slurry, lai.}
}
\value{A data.frame with one row per day: date, n2o, no, nh3, ch4, n_leached, n_mineralised, n_nitrified, n_denitrified, co2_c, wfps_top.}
\examples{weather <- load_example("paddy_weather")
soil <- load_example("paddy_soil")
out <- spacsys_run(weather[1:30, ], soil, method = "simplified")
plot(out$date, out$n2o, type = "l")}
