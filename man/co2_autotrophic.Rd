\name{co2_autotrophic}
\alias{co2_autotrophic}
\title{Autotrophic CO2 respiration (lite)}
\description{
Daily autotrophic respiration for the lite growth module:
root + shoot maintenance (Q10) plus growth respiration taken as a
fixed fraction of daily dry-matter growth -- a simplification of
manual eq. 40-41 (\code{Rg ~= 0.234 * A_canopy}; here
\code{Rg = rg_frac * growth} with default 0.25).
The anoxic fraction of root respiration is excluded: it becomes CH4
via \code{\link{ch4_lite_step}}, not CO2.
}
\usage{
co2_autotrophic(w_root, w_shoot, growth, t_soil, t_air,
                anoxic_frac = 0, rg_frac = 0.25, f_c = 0.45, ...)
}
\arguments{
  \item{w_root, w_shoot}{root and shoot dry matter (g m-2).}
  \item{growth}{daily total dry-matter growth (g m-2 d-1).}
  \item{t_soil, t_air}{soil and air temperature (degrees C).}
  \item{anoxic_frac}{anoxic fraction of the root zone (-); the same
    fraction of root respiration is diverted to methanogenesis.}
  \item{rg_frac}{growth-respiration fraction (-).}
  \item{f_c}{carbon fraction of dry matter.}
  \item{...}{further arguments passed to
    \code{\link{root_respiration}} and
    \code{\link{shoot_respiration}}.}
}
\value{
A list with \code{co2_root}, \code{co2_shoot},
\code{co2_growth} and \code{co2_auto} (total autotrophic CO2,
g C m-2 d-1).
}
