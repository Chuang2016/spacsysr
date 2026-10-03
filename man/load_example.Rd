\name{load_example}
\alias{load_example}
\title{Load bundled example data}
\description{Bundled teaching examples (synthetic 180-day rice-season weather and a 4-layer paddy profile), not measured data.}
\usage{load_example(name = c("paddy_weather", "paddy_soil"))}
\arguments{\item{name}{"paddy_weather" or "paddy_soil".}
}
\value{A data.frame.}
\examples{head(load_example("paddy_weather"))}
