\name{plant_init}
\alias{plant_init}
\title{Initialise the lite crop state}
\description{Create the initial crop state list for the lite growth module.}
\usage{plant_init(crop = crop_default_params())}
\arguments{\item{crop}{Crop parameter list from crop_default_params.}
}
\value{A state list with dindex (0-3), organ dry weights w_leaf, w_stem, w_root, w_grain (g m-2), lai, root_depth_mm and cumulative n_uptake (g N m-2).}
\examples{plant_init()}
