\name{crop_default_params}
\alias{crop_default_params}
\title{Default crop parameters (lite model)}
\description{Small parameter set for the simplified crop growth module. Three built-in parameterisations are provided; any element can be overridden after the call.}
\usage{crop_default_params(crop = c("wheat", "rice", "maize", "generic"))}
\arguments{\item{crop}{One of "wheat", "rice", "maize" or "generic".}
}
\value{A named list: tbase (deg C); add_req (thermal time per stage 1-3, deg C d); rue (g DM MJ-1 PAR); kext; sla (m2 g-1); part (3x4 partitioning matrix, rows = stages, cols = leaf/stem/root/grain); n_conc (optimal N concentration of new growth, g N g-1 DM); root_depth_max (mm); root_elong (mm per deg C d); t_min_g, t_opt_g, t_max_g (deg C); k_sen (d-1); w0 (initial organ weights, g m-2).}
\examples{crop_default_params("wheat")$rue}
