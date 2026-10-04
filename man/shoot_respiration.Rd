\name{shoot_respiration}
\alias{shoot_respiration}
\title{Shoot maintenance respiration (Q10)}
\description{
As \code{\link{root_respiration}} but for aboveground biomass, driven
by air temperature. Follows the manual's maintenance-respiration
concept (eq. 39): biomass x Q10 temperature factor.
}
\usage{
shoot_respiration(w_shoot, t_air, q10 = 2, t_ref = 20, r_ref = 0.003)
}
\arguments{
  \item{w_shoot}{aboveground dry matter, leaves + stems (+ grain);
    g m-2.}
  \item{t_air}{air temperature (degrees C).}
  \item{q10, t_ref, r_ref}{as in \code{\link{root_respiration}}.}
}
\value{Shoot maintenance respiration (g C m-2 d-1).}
\references{Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 26.}
