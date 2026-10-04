\name{ch4_plant_transport}
\alias{ch4_plant_transport}
\title{Plant-mediated methane transport}
\description{
\code{Q_plant(z) = a_m * f_root(z) * D_a / tau^2 * W_leaf *
  (CH4Con - CH4air) / z} (manual eq. 214), after Susiluoto et al. (2018).
Transport through aerenchyma bypasses the oxidised rhizosphere and is the
dominant emission pathway in flooded rice.
}
\usage{
ch4_plant_transport(a_m = 0.081e-3, f_root, d_a = 2e-6, tau = 1.5,
                    w_leaf, ch4_con, ch4_air = 1.4e-3, z)
}
\arguments{
  \item{a_m}{cross-sectional area of root endings per root dry biomass
    (m2 g-1, manual default 0.081e-3).}
  \item{f_root}{fraction of root biomass in the soil layer (-).}
  \item{d_a}{effective diffusion coefficient of CH4 through root
    aerenchyma (m2 s-1); default 2e-6. Molecular diffusion in water is
    ~1.5e-9, but gas-phase transport through aerenchyma is orders of
    magnitude faster; 2e-6 is an effective literature-typical value
    (Susiluoto et al. 2018) -- calibrate to site.}
  \item{tau}{root tortuosity (-, manual default 1.5).}
  \item{w_leaf}{leaf dry matter (g m-2).}
  \item{ch4_con, ch4_air}{CH4 concentration in the soil layer and in the
    atmosphere (g CH4 m-3); atmospheric default 1.4e-3 (~1.9 ppmv).}
  \item{z}{mid-depth of the soil layer (m).}
}
\value{CH4 transport rate (g CH4 m-2 d-1).}
\references{
Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 66;
Susiluoto et al. (2018).
}
