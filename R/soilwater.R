## Soil water (tipping-bucket stand-in) --------------------------------------------
## NOTE: the manual's full soil water/heat module solves Richards-type
## transport; this is a deliberately simple cascading bucket used so the
## biogeochemistry driver can run standalone. See README roadmap.

#' Daily tipping-bucket soil water step
#'
#' Cascades water through soil layers: precipitation enters the top
#' layer, water above field capacity drains downward (bottom-layer
#' drainage = deep percolation), and evapotranspiration is drawn
#' top-down limited by water above wilting point. Surface runoff has
#' two components: (1) infiltration-excess (Hortonian) runoff when
#' daily precipitation exceeds \code{infil_cap_mm}, and (2)
#' saturation-excess runoff when the top layer exceeds saturation.
#'
#' @param theta_vol volumetric water content per layer (fraction, length
#'   = number of layers).
#' @param precip_mm precipitation (mm d-1).
#' @param pet_mm potential evapotranspiration (mm d-1).
#' @param fc field-capacity water content per layer (fraction).
#' @param wp wilting-point water content per layer (fraction).
#' @param sat saturated water content per layer (fraction).
#' @param depth_mm layer depths (mm).
#' @param infil_cap_mm maximum daily infiltration (mm d-1);
#'   precipitation above this runs off before entering the soil.
#'   Default \code{Inf} = no Hortonian runoff (saturation-excess only).
#'   Typical: sand ~100, loam ~40, clay ~15; calibrate to soil texture.
#' @return A list with \code{theta} (updated water contents),
#'   \code{drainage_mm} (deep percolation), \code{runoff_mm} and
#'   \code{aet_mm} (actual ET).
#' @export
soil_water_step <- function(theta_vol, precip_mm, pet_mm, fc, wp, sat,
                            depth_mm, infil_cap_mm = Inf) {
  n <- length(theta_vol)

  ## (1) infiltration-excess (Hortonian) runoff: rain above the daily
  ## infiltration capacity never enters the soil
  runoff <- 0
  if (is.finite(infil_cap_mm) && precip_mm > infil_cap_mm) {
    runoff <- precip_mm - infil_cap_mm
    precip_mm <- infil_cap_mm
  }

  water <- theta_vol * depth_mm          # mm per layer
  water[1] <- water[1] + precip_mm

  ## drainage cascade, top -> bottom
  drainage <- 0
  for (i in seq_len(n)) {
    excess <- water[i] - fc[i] * depth_mm[i]
    if (excess > 0) {
      move <- excess
      water[i] <- water[i] - move
      if (i < n) water[i + 1] <- water[i + 1] + move else drainage <- drainage + move
    }
  }

  ## (2) saturation-excess runoff (only from top layer)
  excess_top <- water[1] - sat[1] * depth_mm[1]
  if (excess_top > 0) {
    runoff <- runoff + excess_top
    water[1] <- water[1] - excess_top
  }

  ## actual ET, top-down, limited by water above wilting point
  aet <- 0
  remaining <- pet_mm
  for (i in seq_len(n)) {
    avail <- max(water[i] - wp[i] * depth_mm[i], 0)
    take <- min(avail, remaining)
    water[i] <- water[i] - take
    aet <- aet + take
    remaining <- remaining - take
    if (remaining <= 0) break
  }

  list(theta = water / depth_mm, drainage_mm = drainage,
       runoff_mm = runoff, aet_mm = aet)
}
