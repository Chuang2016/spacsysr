## Ponded water layer & dissolved-gas emissions ----------------------------------
## Optional module for paddy / flooded conditions:
##   - pond_water_step(): daily ponded-water depth balance coupled to
##     the topsoil. Rainfall + irrigation (+ optional auto-irrigation
##     to a target depth) pond on the surface; pond water saturates
##     the topsoil, percolates slowly through the plow pan, evaporates
##     as open water, and overflows the bund.
##   - pond_gas_step(): dissolved CH4/N2O in the ponded water --
##     soil gases dissolve, CH4 is partly oxidised in the water
##     column, and both gases escape across the water-air interface.
## While ponded, the topsoil is held near saturation (plow-pan
## restricted drainage) and soil gas fluxes are routed through the
## water layer instead of directly to the atmosphere.

#' Daily ponded-water balance coupled to topsoil
#'
#' Tracks the depth of ponded surface water (mm) under paddy/flooded
#' conditions. Rainfall + irrigation (+ auto-irrigation to
#' \code{target_mm} when set, mimicking paddy water management) first
#' pond on the surface; pond water then saturates the topsoil,
#' percolates slowly through the plow pan to deep drainage, evaporates
#' as open water, and overflows the bund.
#'
#' @param pond_mm current ponded depth (mm).
#' @param precip,irrig rainfall and irrigation (mm d-1).
#' @param pet potential evapotranspiration (mm d-1).
#' @param theta_top,sat_top topsoil water content and saturation
#'   (volumetric fractions); \code{theta_top} is updated in place.
#' @param depth_top_mm topsoil layer thickness (mm).
#' @param bund_mm bund height; excess ponds overflow to runoff (mm).
#' @param k_perc slow percolation through the plow pan (mm d-1),
#'   routed to deep drainage.
#' @param k_evap open-water evaporation coefficient (-) on PET.
#' @param target_mm optional target ponded depth (mm); auto-irrigate
#'   the deficit each day.
#' @return A list with \code{pond_mm} (updated depth),
#'   \code{theta_top} (updated topsoil water content),
#'   \code{irrig_auto_mm}, \code{perc_mm} (deep drainage),
#'   \code{evap_mm} and \code{overflow_mm}.
#' @export
pond_water_step <- function(pond_mm, precip, irrig, pet,
                            theta_top, sat_top, depth_top_mm,
                            bund_mm = 80, k_perc = 2, k_evap = 1.0,
                            target_mm = NULL) {
  ## auto-irrigation to target depth (paddy water management)
  irrig_auto <- if (!is.null(target_mm))
    max(0, target_mm - pond_mm) else 0
  pond_mm <- pond_mm + precip + irrig + irrig_auto
  ## pond water saturates the topsoil
  need <- max(0, sat_top - theta_top) * depth_top_mm
  fill <- min(pond_mm, need)
  theta_top <- theta_top + fill / depth_top_mm
  pond_mm <- pond_mm - fill
  ## slow percolation through the plow pan -> deep drainage
  perc <- min(pond_mm, k_perc)
  pond_mm <- pond_mm - perc
  ## open-water evaporation
  evap <- min(pond_mm, pet * k_evap)
  pond_mm <- pond_mm - evap
  ## bund overflow
  overflow <- max(0, pond_mm - bund_mm)
  pond_mm <- pond_mm - overflow
  list(pond_mm = pond_mm, theta_top = theta_top,
       irrig_auto_mm = irrig_auto, perc_mm = perc,
       evap_mm = evap, overflow_mm = overflow)
}

#' Dissolved-gas emissions from ponded water
#'
#' When the soil is ponded, soil-emitted gases do not reach the
#' atmosphere directly. Diffusive CH4/N2O first dissolve in the
#' floodwater, where CH4 is partly oxidised by water-column
#' methanotrophs (first-order) and both gases escape across the
#' water-air interface by concentration-gradient diffusion.
#' Plant-transported CH4 (aerenchyma) and ebullition bubbles bypass
#' the water column and are passed through via \code{ebu_in}.
#' With no ponded water (< 1 mm film) the inputs go straight to the
#' atmosphere. Fluxes are capped by available mass so the scheme is
#' stable at very low ponded depths.
#'
#' @param ch4_in,n2o_in diffusive soil gas inputs (g m-2 d-1).
#' @param ebu_in bubble / plant-transport CH4 bypassing the water
#'   (g CH4 m-2 d-1).
#' @param ch4_diss,n2o_diss current dissolved concentrations
#'   (g m-3 water).
#' @param pond_m ponded depth (m).
#' @param t_water floodwater temperature (degrees C, currently unused,
#'   kept for future temperature-dependent rates).
#' @param k_oxw first-order water-column CH4 oxidation rate (d-1).
#' @param k_transfer water-air gas transfer velocity (m d-1).
#' @return A list with updated \code{ch4_diss}, \code{n2o_diss}
#'   (g m-3), water-to-air fluxes \code{ch4_flux} (g CH4 m-2 d-1),
#'   \code{n2o_flux} (g N m-2 d-1) and \code{ch4_oxidized}
#'   (g CH4 m-2 d-1).
#' @export
pond_gas_step <- function(ch4_in, n2o_in, ebu_in = 0,
                          ch4_diss = 0, n2o_diss = 0,
                          pond_m = 0.02, t_water = 25,
                          k_oxw = 0.5, k_transfer = 0.3) {
  ch4_air <- 1.4e-3  # g CH4 m-3 (~1.9 ppmv)
  if (pond_m <= 1e-3) {  # < 1 mm film: no water body, direct to air
    return(list(ch4_diss = 0, n2o_diss = 0,
                ch4_flux = ch4_in + ebu_in, n2o_flux = n2o_in,
                ch4_oxidized = 0))
  }
  ## dissolve diffusive inputs
  ch4_diss <- ch4_diss + ch4_in / pond_m
  n2o_diss <- n2o_diss + n2o_in / pond_m
  ## water-column CH4 oxidation
  ch4_ox <- min(ch4_diss * pond_m, k_oxw * ch4_diss * pond_m)
  ch4_diss <- ch4_diss - ch4_ox / pond_m
  ## diffusive water-to-air flux (concentration gradient),
  ## capped by available mass (stability at low depth)
  ch4_avail <- ch4_diss * pond_m
  ch4_flux <- min(k_transfer * max(0, ch4_diss - ch4_air), ch4_avail)
  n2o_avail <- n2o_diss * pond_m
  n2o_flux <- min(k_transfer * max(0, n2o_diss), n2o_avail)
  ch4_diss <- (ch4_avail - ch4_flux) / pond_m
  n2o_diss <- (n2o_avail - n2o_flux) / pond_m
  list(ch4_diss = ch4_diss, n2o_diss = n2o_diss,
       ch4_flux = ch4_flux + ebu_in, n2o_flux = n2o_flux,
       ch4_oxidized = ch4_ox)
}
