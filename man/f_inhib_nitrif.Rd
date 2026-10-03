\name{f_inhib_nitrif}
\alias{f_inhib_nitrif}
\title{Nitrification-inhibitor effect decay}
\description{Manual eq. 184 (Smith et al., 2005); capped at 1 for d >= 120 since the printed form is only valid over the 120-day effect window.}
\usage{f_inhib_nitrif(d)}
\arguments{\item{d}{Days since last external N input.}
}
\value{Inhibitor effect factor (small = strong inhibition).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{f_inhib_nitrif(c(0, 30, 60, 120, 200))}
