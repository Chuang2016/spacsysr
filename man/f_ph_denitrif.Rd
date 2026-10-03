\name{f_ph_denitrif}
\alias{f_ph_denitrif}
\title{pH responses of individual denitrifiers}
\description{Step-specific acidity responses, manual eq. 199. For step 2 and pH < 4.5 the printed form is not real-valued; it is extended continuously with its limit (0.5).}
\usage{f_ph_denitrif(ph, step = 1L)}
\arguments{\item{ph}{Soil pH.}
\item{step}{Integer 1-4 selecting the denitrification step (NO3-, NO2-, NO, N2O).}
}
\value{Response factor.}
\references{Wu, L. (2022). SPACSYS - FARMSYS: Soil-Plant-Atmosphere Continuum System Model (ver. 6.00) - Technical Manual. Rothamsted Research, North Wyke, UK.}
\examples{sapply(1:4, function(s) f_ph_denitrif(seq(4, 9, by = 1), s))}
