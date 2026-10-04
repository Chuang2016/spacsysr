\name{ghg_footprint}
\alias{ghg_footprint}
\title{Carbon / GHG footprint of a lite-model run}
\description{
Seasonal greenhouse-gas budget from a \code{\link{spacsys_lite_run}}
output data frame: sums CO2 (heterotrophic + autotrophic), CH4 and
N2O over the season, converts to CO2-equivalents with
\code{\link{ghg_co2eq}}, and -- when grain yield is available --
reports the yield-scaled footprint intensity
(kg CO2-eq per tonne of grain), the standard carbon-footprint metric.

Unit conversions applied: \code{co2_*_c} (g C) -> CO2 x 44/12;
\code{n2o} (g N) -> N2O x 44/28; \code{ch4} is already g CH4.
}
\usage{
ghg_footprint(out, grain_col = "w_grain", ...)
}
\arguments{
  \item{out}{output data frame from \code{\link{spacsys_lite_run}}.}
  \item{grain_col}{name of the grain-biomass column (g m-2); set to
    \code{NULL} to skip the yield-scaled intensity.}
  \item{...}{arguments passed to \code{\link{ghg_co2eq}}.}
}
\value{
A data frame with one row: seasonal \code{co2_kg_ha},
\code{ch4_kg_ha}, \code{n2o_kg_ha}, \code{ghg_co2eq_kg_ha},
per-gas shares (\code{share_co2}, \code{share_ch4},
\code{share_n2o}) and, when available,
\code{intensity_kg_co2eq_per_t_grain} and \code{yield_t_ha}.
}
