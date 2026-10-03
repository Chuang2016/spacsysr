## Soil organic matter decomposition ------------------------------------------

#' Decomposition rate of soil organic carbon
#'
#' \code{D_decom = k_pot * f_temp * f_water * min(f_cn, f_cp) * C_pool}
#' (manual eq. 174), applied per organic matter pool (root litter, fresh
#' litter, dissolved, humus, manure, mycorrhizal).
#'
#' @param c_pool size of the organic carbon pool (g C m-2).
#' @param k_pot specific decomposition rate for the pool (d-1).
#' @param f_temp temperature response factor (see \code{\link{f_temp_q10}}).
#' @param f_water moisture response factor (see
#'   \code{\link{f_water_decom}}).
#' @param f_cn response to the pool C:N ratio, default 1 (no limitation).
#' @param f_cp response to the pool C:P ratio, default 1 (no limitation).
#' @return Decomposition rate (g C m-2 d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 55.
#' @export
decomp_rate <- function(c_pool, k_pot, f_temp, f_water, f_cn = 1, f_cp = 1) {
  k_pot * f_temp * f_water * pmin(f_cn, f_cp) * c_pool
}
