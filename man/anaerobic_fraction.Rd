\name{anaerobic_fraction}
\alias{anaerobic_fraction}
\title{Anaerobic soil fraction}
\description{SPACSYS allocates substrates between aerobic/anaerobic fractions following the DNDC concept (Li et al., 2000). The manual prints no explicit equation, so this helper implements a transparent linear ramp; treat defaults as placeholders to calibrate.}
\usage{anaerobic_fraction(wfps, wfps_crit = 0.9, wfps_range = 0.3)}
\arguments{\item{wfps}{Water-filled pore space, fraction.}
\item{wfps_crit}{WFPS at which the soil is fully anaerobic.}
\item{wfps_range}{WFPS range of the linear ramp.}
}
\value{Anaerobic fraction in [0, 1].}
\examples{anaerobic_fraction(seq(0.5, 1, by = 0.1))}
