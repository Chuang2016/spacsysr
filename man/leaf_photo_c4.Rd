\name{leaf_photo_c4}
\alias{leaf_photo_c4}
\title{C4 leaf photosynthesis (Yin & Struik)}
\description{Yin & Struik (2009) C4 model (manual p. 23-24). Four limitation combinations (Rubisco/e-transport x PEP-limited/e-limited Vp) are each solved by fixed-point iteration since Cc depends on A; the minimum is taken.}
\usage{leaf_photo_c4(ci, j2, vcmax, jmax, rd, gamma_star, kmc, kmo, oi = 210000, ep = 0.6, gbs = 0.01, f_cyc = 0.3, x = 0.4, phi = 2, f_Q = 1, h = 4, tol = 1e-6, max_iter = 100)}
\arguments{\item{ci}{Intercellular CO2 (umol mol-1).}
\item{j2}{Electron transport rate (umol m-2 s-1).}
\item{vcmax}{Maximum Rubisco carboxylation rate.}
\item{jmax}{Maximum electron transport rate.}
\item{rd}{Day respiration.}
\item{gamma_star}{CO2 compensation point.}
\item{kmc}{Michaelis constant for CO2.}
\item{kmo}{Michaelis constant for O2.}
\item{oi}{Intercellular O2.}
\item{ep}{PEP carboxylation efficiency.}
\item{gbs}{Bundle-sheath conductance (mol m-2 s-1).}
\item{f_cyc}{Cyclic electron flow fraction (higher in C4).}
\item{x}{ATP fraction for Vp reactions (manual: 0.4).}
\item{phi}{Extra ATP per CO2 for the CCM (manual: 2).}
\item{f_Q}{Q-cycle electron fraction (manual: 1).}
\item{h}{H+:ATP ratio (manual: 4).}
\item{tol}{Fixed-point tolerance.}
\item{max_iter}{Max iterations.}
}
\value{A list with a (umol m-2 s-1), vp and limitation (winning combination).}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{leaf_photo_c4(150, 120, 60, 140, 1, 42.75, 404.9, 278400)}
