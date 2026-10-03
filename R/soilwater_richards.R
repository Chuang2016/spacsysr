## Soil water: retention, conductivity, Richards equation ---------------------------
## SPACSYS technical manual (Wu, 2022, ver. 6.00), ch. 7, p. 83-89.
## Conventions: psi = soil water TENSION, positive, in cm (as in the manual);
## z = depth positive downward in m; flux q downward positive in m d-1.
## Richards eq. (299): dtheta/dt = -d/dz[K dpsi/dz] - dK/dz + S.

#' van Genuchten water retention curve
#'
#' \code{(theta - tr)/(ts - tr) = 1/[1 + (alpha*psi)^n]^m},
#' \code{m = 1 - 1/n} (manual eq. 290, p. 83).
#'
#' @param psi soil water tension (cm, >= 0).
#' @param alpha van Genuchten alpha (cm-1).
#' @param n van Genuchten n (-).
#' @param theta_r residual water content (fraction).
#' @param theta_s saturated water content (fraction).
#' @return Volumetric water content (fraction).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 83.
#' @export
vg_retention <- function(psi, alpha, n, theta_r, theta_s) {
  m <- 1 - 1 / n
  se <- (1 + (alpha * pmax(psi, 0))^n)^(-m)
  theta_r + (theta_s - theta_r) * se
}

#' Brooks-Corey water retention curve
#'
#' \code{(theta - tr)/(ts - tr) = (psi/psia)^-lambda} for
#' \code{psi > psia}, else 1 (manual eq. 291, p. 83).
#'
#' @param psi soil water tension (cm, >= 0).
#' @param psia air-entry tension (cm).
#' @param lambda pore-size distribution index (-).
#' @param theta_r residual water content (fraction).
#' @param theta_s saturated water content (fraction).
#' @return Volumetric water content (fraction).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 83.
#' @export
bc_retention <- function(psi, psia, lambda, theta_r, theta_s) {
  se <- ifelse(psi <= psia, 1, (psi / psia)^(-lambda))
  theta_r + (theta_s - theta_r) * se
}

#' Specific moisture capacity d(theta)/d(psi)
#'
#' Analytical derivative of the retention curve w.r.t. tension
#' (negative: water content falls as tension rises).
#'
#' @param psi soil water tension (cm, >= 0).
#' @param params parameter list (see \code{\link{richards_1d}}).
#' @return d(theta)/d(psi) (cm-1).
#' @export
moisture_capacity <- function(psi, params) {
  psi <- pmax(psi, 0)
  if (params$retention == "vg") {
    m <- 1 - 1 / params$n
    a_psi <- params$alpha * psi
    -(params$theta_s - params$theta_r) * m * params$n *
      params$alpha^params$n * psi^(params$n - 1) *
      (1 + a_psi^params$n)^(-(m + 1))
  } else {
    cap <- -(params$theta_s - params$theta_r) * params$lambda *
      params$psia^params$lambda * psi^(-(params$lambda + 1))
    ifelse(psi <= params$psia, 0, cap)
  }
}

#' Unsaturated hydraulic conductivity
#'
#' Brooks-Corey: \code{k = ksat*Se^((2+tau+lambda)/2)} (manual eq. 300).
#' van Genuchten-Mualem (standard form):
#' \code{k = ksat*Se^0.5*(1-(1-Se^(1/m))^m)^2}.
#' NOTE: the manual's printed VG-Mualem form (eq. 301) differs from the
#' standard Mualem expression and is flagged "check against code"; the
#' standard form is implemented here.
#' Temperature correction (manual eq. 302):
#' \code{k_unsat = (0.54 + 0.023*Ts)*max(k, kmin)} (frozen-soil term
#' omitted; = 1 without ice).
#'
#' @param psi soil water tension (cm, >= 0).
#' @param params parameter list with \code{retention} ("vg" or "bc"),
#'   \code{theta_r}, \code{theta_s}, \code{alpha}, \code{n},
#'   \code{psia}, \code{lambda}, \code{tau} (default 0.5),
#'   \code{k_sat} (m d-1), \code{k_min} (m d-1, default 1e-6).
#' @param t_soil soil temperature (degrees C), default 20.
#' @return Hydraulic conductivity (m d-1).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 85.
#' @export
unsat_conductivity <- function(psi, params, t_soil = 20) {
  psi <- pmax(psi, 0)
  if (params$retention == "vg") {
    m <- 1 - 1 / params$n
    se <- (1 + (params$alpha * psi)^params$n)^(-m)
    k <- params$k_sat * sqrt(se) * (1 - (1 - se^(1 / m))^m)^2
  } else {
    tau <- if (!is.null(params$tau)) params$tau else 0.5
    se <- ifelse(psi <= params$psia, 1,
                 (psi / params$psia)^(-params$lambda))
    k <- params$k_sat * se^((2 + tau + params$lambda) / 2)
  }
  kmin <- if (!is.null(params$k_min)) params$k_min else 1e-6
  (0.54 + 0.023 * t_soil) * pmax(k, kmin)
}

#' Tridiagonal solver (Thomas algorithm)
#'
#' Solves \code{a[i]*x[i-1] + b[i]*x[i] + c[i]*x[i+1] = d[i]}.
#' Internal helper.
#' @keywords internal
thomas_solve <- function(a, b, c, d) {
  n <- length(d)
  cp <- numeric(n); dp <- numeric(n)
  cp[1] <- c[1] / b[1]; dp[1] <- d[1] / b[1]
  for (i in 2:n) {
    m <- b[i] - a[i] * cp[i - 1]
    cp[i] <- if (i < n) c[i] / m else 0
    dp[i] <- (d[i] - a[i] * dp[i - 1]) / m
  }
  x <- numeric(n); x[n] <- dp[n]
  for (i in (n - 1):1) x[i] <- dp[i] - cp[i] * x[i + 1]
  x
}

#' 1-D Richards equation solver (vertical soil water movement)
#'
#' Solves the manual's eq. (299),
#' \code{dtheta/dt = -d/dz[K dpsi/dz] - dK/dz + S},
#' with a psi-based implicit finite-difference scheme and Picard
#' iteration (tridiagonal Thomas solve per iteration).
#'
#' @param psi_init initial soil water tension per node (cm, >= 0).
#' @param dz_m node spacing (m, uniform).
#' @param params parameter list for \code{\link{unsat_conductivity}}
#'   (must include \code{retention}, \code{theta_r}, \code{theta_s},
#'   \code{k_sat} in m d-1, plus \code{alpha}/\code{n} for "vg" or
#'   \code{psia}/\code{lambda} for "bc").
#' @param dt_day time step in days, default 1.
#' @param n_sub number of sub-steps, default 24.
#' @param top_flux surface water flux (m d-1, downward positive:
#'   rain positive, evaporation negative), default 0.
#' @param pond_ok allow switch to ponded (psi = 0) top boundary when the
#'   surface saturates, default TRUE.
#' @param bottom_bc \code{"free"} (unit-gradient drainage) or
#'   \code{"fixed"} (constant \code{psi_bottom}).
#' @param psi_bottom bottom tension for \code{bottom_bc = "fixed"} (cm).
#' @param source sink/source term per node (d-1, e.g. root uptake as
#'   negative), default 0.
#' @param t_soil soil temperature (degrees C), default 20.
#' @param picard_tol,max_picard Picard convergence control.
#' @return A list with \code{psi} (cm), \code{theta}, \code{drainage_m}
#'   (bottom flux over the step), \code{runoff_m} (rejected top flux
#'   under ponding), and \code{n_iter} (Picard iterations used).
#' @references Wu, L. (2022). SPACSYS Technical Manual v6.00, p. 85.
#' @export
richards_1d <- function(psi_init, dz_m, params, dt_day = 1, n_sub = 24,
                        top_flux = 0, pond_ok = TRUE,
                        bottom_bc = c("free", "fixed"), psi_bottom = 100,
                        source = 0, t_soil = 20,
                        picard_tol = 1e-4, max_picard = 30) {
  bottom_bc <- match.arg(bottom_bc)
  n <- length(psi_init)
  dz_cm <- dz_m * 100
  dt <- dt_day / n_sub
  psi <- pmax(psi_init, 0)
  source <- rep(source, length.out = n)
  drainage <- 0; runoff <- 0

  theta_of <- function(p)
    if (params$retention == "vg")
      vg_retention(p, params$alpha, params$n, params$theta_r, params$theta_s)
    else
      bc_retention(p, params$psia, params$lambda, params$theta_r, params$theta_s)

  for (s in seq_len(n_sub)) {
    theta_old <- theta_of(psi)
    psi_k <- psi
    q_top <- top_flux
    ponded <- FALSE

    for (it in seq_len(max_picard)) {
      k <- unsat_conductivity(psi_k, params, t_soil)
      k_mid <- sqrt(k[-n] * k[-1])          # geometric mean at faces
      cap <- moisture_capacity(psi_k, params)
      th_k <- theta_of(psi_k)

      lo <- numeric(n); di <- numeric(n); up <- numeric(n); rhs <- numeric(n)
      coef <- (dt / dz_m) / dz_cm          # (dt/dz)/dz_cm

      ## interior nodes
      for (i in 2:(n - 1)) {
        lo[i] <- coef * k_mid[i - 1]
        di[i] <- cap[i] - coef * (k_mid[i - 1] + k_mid[i])
        up[i] <- coef * k_mid[i]
        rhs[i] <- theta_old[i] - th_k[i] + cap[i] * psi_k[i] +
          dt * source[i] + (dt / dz_m) * (k_mid[i - 1] - k_mid[i])
      }
      ## top: prescribed flux (or ponded Dirichlet)
      if (ponded || (pond_ok && psi_k[1] <= 0 && q_top > 0)) {
        ponded <- TRUE
        di[1] <- 1; rhs[1] <- 0            # psi = 0
      } else {
        di[1] <- cap[1] - coef * k_mid[1]
        up[1] <- coef * k_mid[1]
        rhs[1] <- theta_old[1] - th_k[1] + cap[1] * psi_k[1] +
          dt * source[1] + (dt / dz_m) * (q_top - k_mid[1])
      }
      ## bottom
      if (bottom_bc == "free") {
        lo[n] <- coef * k_mid[n - 1]
        di[n] <- cap[n] - coef * k_mid[n - 1]
        rhs[n] <- theta_old[n] - th_k[n] + cap[n] * psi_k[n] +
          dt * source[n] + (dt / dz_m) * (k_mid[n - 1] - k[n])
      } else {
        psi_k[n] <- psi_bottom           # Dirichlet: fix bottom tension
        di[n] <- 1; rhs[n] <- psi_bottom
      }

      psi_new <- thomas_solve(lo, di, up, rhs)
      psi_new <- pmax(psi_new, 0)
      err <- max(abs(psi_new - psi_k))
      psi_k <- psi_new
      if (err < picard_tol) break
    }
    ## fluxes for bookkeeping
    k <- unsat_conductivity(psi_k, params, t_soil)
    k_mid <- sqrt(k[-n] * k[-1])
    q_bot <- if (bottom_bc == "free") k[n] else
      k_mid[n - 1] * ((psi_bottom - psi_k[n]) / dz_cm + 1)
    drainage <- drainage + q_bot * dt
    if (ponded) {
      ## excess top flux becomes runoff (surface cannot take more)
      q_in <- k_mid[1] * ((psi_k[2] - 0) / dz_cm + 1)
      runoff <- runoff + max(q_top - q_in, 0) * dt
    }
    psi <- psi_k
  }
  list(psi = psi, theta = theta_of(psi), drainage_m = drainage,
       runoff_m = runoff, n_iter = it)
}
