\name{root_respiration}
\alias{root_respiration}
\title{Root respiration (Q10)}
\description{
Specific root respiration scaled by a Q10 temperature response:
\code{R_root = r_ref * W_root * Q10^((T_soil - T_ref)/10)}.
The anoxic fraction of this flux feeds methanogenesis
(\code{\link{ch4_lite_step}}); the aerobic fraction is emitted as CO2.
}
\usage{
root_respiration(w_root, t_soil, q10 = 2, t_ref = 20, r_ref = 0.004)
}
\arguments{
  \item{w_root}{root dry matter (g m-2).}
  \item{t_soil}{soil temperature (degrees C).}
  \item{q10}{Q10 value.}
  \item{t_ref}{reference temperature (degrees C).}
  \item{r_ref}{specific respiration rate at \code{t_ref}
    (g C g-1 root DM d-1).}
}
\value{Root respiration (g C m-2 d-1).}
