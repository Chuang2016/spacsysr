\name{leaf_photo_c3}
\alias{leaf_photo_c3}
\title{C3 leaf photosynthesis with temperature responses}
\description{Temperature-dependent parameters via Arrhenius (Bernacchi et al. defaults; the manual parameter table was not in the extracted text). Ci = ci_ca*Ca, Cc = Ci, Rd = 0.1*Vcmax (manual p. 21). The manual solves the coupled A-gs system with a cubic equation; that full solution is on the roadmap.}
\usage{leaf_photo_c3(ca, ppfd, t_leaf, vcmax25 = 80, jmax25 = 140, ci_ca = 0.7, ...)}
\arguments{\item{ca}{Ambient CO2 (umol mol-1).}
\item{ppfd}{Incident PPFD (umol m-2 s-1).}
\item{t_leaf}{Leaf temperature (degrees C).}
\item{vcmax25}{Vcmax at 25 C.}
\item{jmax25}{Jmax at 25 C.}
\item{ci_ca}{Ci/Ca ratio.}
\item{...}{Further arguments to farquhar_c3 (tu defaults to vcmax/8).}
}
\value{Same as farquhar_c3 plus j and ci.}
\examples{leaf_photo_c3(420, 1200, 25)}
