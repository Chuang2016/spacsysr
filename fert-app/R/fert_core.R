# =====================================================================
# fert_core.R
# 科学施肥推荐 —— 核心算法（纯 base R，零依赖）
#
# 方法：目标产量法（养分平衡法），全国测土配方施肥技术规范常用公式
#
#   施肥量(kg/亩) = [目标产量 × 单位产量养分吸收量 − 土壤养分供应量]
#                   / 肥料当季利用率
#
# 土壤养分供应量按养分独立判断来源：
#   ① 有土壤化验值：供应量 = 化验值(mg/kg) × 0.15 × 校正系数
#      （0.15：亩耕层 0–20cm 土重约 150000 kg 的换算系数）
#   ② 无化验值：用去年产量与施肥量反推
#      供应量 = 去年产量需肥量 − 去年施肥纯养分量 × 当季利用率
#
# 作物养分吸收系数借鉴 SPACSYS 作物模块"单位产量养分需求"参数思想，
# 取值综合《中国主要作物施肥指南》与测土配方施肥常用值；
# 利用率、校正系数均为可调参数，建议用当地田间试验结果校准。
# =====================================================================

## 作物养分参数数据库 -------------------------------------------------
fert_crop_db <- function() {
  data.frame(
    crop     = c("水稻", "小麦"),
    # 每 100 kg 籽粒养分吸收量 (kg)：N / P2O5 / K2O
    N_uptake = c(2.2, 3.0),
    P_uptake = c(1.0, 1.2),
    K_uptake = c(2.7, 3.0),
    # 肥料当季利用率（默认）
    N_eff    = c(0.35, 0.35),
    P_eff    = c(0.20, 0.20),
    K_eff    = c(0.50, 0.50),
    # 土壤化验值 → 供肥量校正系数（默认）
    N_corr   = c(0.60, 0.60),
    P_corr   = c(0.60, 0.60),
    K_corr   = c(0.60, 0.60),
    stringsAsFactors = FALSE
  )
}

## 主函数：推荐施肥量 -------------------------------------------------
recommend_fertilizer <- function(crop = c("水稻", "小麦"),
                                 area_mu,
                                 target_yield, last_yield,
                                 last_N = 0, last_P = 0, last_K = 0,
                                 som = NA_real_, ph = NA_real_,
                                 soil_N = NA_real_, soil_P = NA_real_,
                                 soil_K = NA_real_,
                                 uptake = NULL, eff = NULL, corr = NULL) {
  crop <- match.arg(crop)
  db   <- fert_crop_db()
  prow <- db[db$crop == crop, ]

  get_par <- function(custom, cols) {
    if (!is.null(custom)) {
      if (length(custom) != 3)
        stop("自定义参数 uptake / eff / corr 需为长度 3 的数值向量（N, P2O5, K2O）")
      return(as.numeric(custom))
    }
    as.numeric(prow[, cols])
  }
  up <- get_par(uptake, c("N_uptake", "P_uptake", "K_uptake"))
  ef <- get_par(eff,    c("N_eff", "P_eff", "K_eff"))
  co <- get_par(corr,   c("N_corr", "P_corr", "K_corr"))

  nz <- function(x, d = 0) if (is.null(x) || length(x) == 0 || is.na(x)) d else x
  area_mu      <- nz(area_mu)
  target_yield <- nz(target_yield)
  last_yield   <- nz(last_yield)
  last_N <- nz(last_N); last_P <- nz(last_P); last_K <- nz(last_K)

  need      <- target_yield / 100 * up   # 目标产量需肥量 (kg/亩)
  last_need <- last_yield / 100 * up     # 去年产量需肥量 (kg/亩)
  names(need) <- names(last_need) <- c("N", "P2O5", "K2O")

  # 土壤供肥量（分养分独立判断来源）
  soil_test <- c(N = nz(soil_N, NA), P = nz(soil_P, NA), K = nz(soil_K, NA))
  last_fert <- c(N = last_N, P = last_P, K = last_K)
  supply      <- numeric(3)
  supply_from <- character(3)
  for (i in 1:3) {
    if (!is.na(soil_test[i])) {
      supply[i]      <- soil_test[i] * 0.15 * co[i]
      supply_from[i] <- "土壤化验值"
    } else {
      supply[i]      <- max(0, last_need[i] - last_fert[i] * ef[i])
      supply_from[i] <- "去年产量与施肥量反推"
    }
  }
  names(supply) <- names(supply_from) <- c("N", "P2O5", "K2O")

  # 推荐纯养分量 (kg/亩)，负值按 0 计
  fert <- pmax(0, (need - supply) / ef)
  names(fert) <- c("N", "P2O5", "K2O")

  # 与去年对比
  diff_last <- fert - last_fert

  # 肥料折算 ----------------------------------------------------------
  # 方案 A：单质肥料（尿素 46%N / 过磷酸钙 12%P2O5 / 氯化钾 60%K2O）
  prod_A <- data.frame(
    肥料       = c("尿素 (46% N)", "过磷酸钙 (12% P2O5)", "氯化钾 (60% K2O)"),
    每亩用量kg = round(c(fert[["N"]] / 0.46,
                        fert[["P2O5"]] / 0.12,
                        fert[["K2O"]] / 0.60), 1),
    全田用量kg = round(c(fert[["N"]] / 0.46,
                        fert[["P2O5"]] / 0.12,
                        fert[["K2O"]] / 0.60) * area_mu, 1),
    stringsAsFactors = FALSE
  )
  # 方案 B：磷酸二铵 (18-46-0) + 尿素 + 氯化钾
  dap        <- fert[["P2O5"]] / 0.46
  n_from_dap <- dap * 0.18
  urea_b     <- max(0, fert[["N"]] - n_from_dap) / 0.46
  kcl_b      <- fert[["K2O"]] / 0.60
  prod_B <- data.frame(
    肥料       = c("磷酸二铵 (18-46-0)", "尿素 (46% N)", "氯化钾 (60% K2O)"),
    每亩用量kg = round(c(dap, urea_b, kcl_b), 1),
    全田用量kg = round(c(dap, urea_b, kcl_b) * area_mu, 1),
    stringsAsFactors = FALSE
  )

  # 基肥 / 追肥分配 ---------------------------------------------------
  if (crop == "水稻") {
    split_df <- data.frame(
      养分     = c("氮 N", "磷 P2O5", "钾 K2O"),
      基肥     = round(c(fert[["N"]] * 0.5, fert[["P2O5"]], fert[["K2O"]] * 0.6), 1),
      分蘖肥   = round(c(fert[["N"]] * 0.3, 0, 0), 1),
      穗肥     = round(c(fert[["N"]] * 0.2, 0, fert[["K2O"]] * 0.4), 1),
      stringsAsFactors = FALSE
    )
    split_note <- "水稻：氮肥按 基肥:分蘖肥:穗肥 = 5:3:2；磷肥全部基施；钾肥 60% 基施、40% 穗期施。"
  } else {
    split_df <- data.frame(
      养分 = c("氮 N", "磷 P2O5", "钾 K2O"),
      基肥 = round(c(fert[["N"]] * 0.6, fert[["P2O5"]], fert[["K2O"]]), 1),
      追肥 = round(c(fert[["N"]] * 0.4, 0, 0), 1),
      stringsAsFactors = FALSE
    )
    split_note <- "小麦：氮肥 60% 基施、40% 返青–拔节期追施；磷、钾肥全部基施。"
  }

  # 农艺建议与风险提示 -------------------------------------------------
  advice <- character(0)
  n_limit <- if (crop == "水稻") 18 else 20
  if (fert[["N"]] > n_limit)
    advice <- c(advice, sprintf(
      "推荐施氮量（%.1f kg/亩）偏高，请核对目标产量与利用率参数，或分 3–4 次施用。",
      fert[["N"]]))
  if (!is.na(ph) && ph < 5.5)
    advice <- c(advice, "土壤 pH < 5.5 偏酸，建议配合施用石灰或钙镁磷肥调酸，磷肥宜集中条施。")
  if (!is.na(ph) && ph > 8.0)
    advice <- c(advice, "土壤 pH > 8.0 偏碱，磷易被固定，建议磷肥集中施用、适当增加用量。")
  if (!is.na(som) && som < 10)
    advice <- c(advice, "土壤有机质 < 10 g/kg 偏低，建议增施有机肥 1000–1500 kg/亩培肥地力。")
  if (target_yield > last_yield * 1.3)
    advice <- c(advice, "目标产量较去年增幅超过 30%，养分需求按线性外推，不确定性增大，建议保守取用。")
  if (any(supply_from == "去年产量与施肥量反推"))
    advice <- c(advice, "部分养分土壤供应量由去年数据反推；如有土壤化验值（碱解氮/有效磷/速效钾），填入后推荐更准。")
  advice <- c(advice, "氮肥分次深施、避免大水漫灌，可在保产的同时减少 N2O 排放。")

  # 计算过程明细（文字版）----------------------------------------------
  nm <- c("N", "P2O5", "K2O")
  steps <- c(
    sprintf("【输入】作物：%s；面积：%.1f 亩；目标产量：%.0f kg/亩；去年产量：%.0f kg/亩。",
            crop, area_mu, target_yield, last_yield),
    sprintf("【输入】去年施肥（纯养分）：N %.1f、P2O5 %.1f、K2O %.1f kg/亩。",
            last_N, last_P, last_K),
    sprintf("【参数】每100kg籽粒养分吸收量：N %.1f、P2O5 %.1f、K2O %.1f kg；当季利用率：N %.0f%%、P2O5 %.0f%%、K2O %.0f%%。",
            up[1], up[2], up[3], ef[1] * 100, ef[2] * 100, ef[3] * 100)
  )
  for (i in 1:3) {
    steps <- c(steps, sprintf(
      "【%s】目标需肥 %.2f ＝ %.0f/100 × %.1f；土壤供应 %.2f（%s）；推荐 %.2f ＝ (%.2f − %.2f) / %.2f kg/亩。",
      nm[i], need[i], target_yield, up[i], supply[i], supply_from[i],
      fert[i], need[i], supply[i], ef[i]))
  }
  steps <- c(steps, sprintf(
    "【对比去年】N %+.1f、P2O5 %+.1f、K2O %+.1f kg/亩。",
    diff_last[["N"]], diff_last[["P2O5"]], diff_last[["K2O"]]))

  # 文本报告 ------------------------------------------------------------
  L <- c(
    "========== 科学施肥推荐方案 ==========",
    sprintf("作物：%s   面积：%.1f 亩", crop, area_mu),
    sprintf("目标产量：%.0f kg/亩   去年产量：%.0f kg/亩", target_yield, last_yield),
    "",
    "—— 推荐纯养分量（kg/亩）——",
    sprintf("氮(N)：%.2f   磷(P2O5)：%.2f   钾(K2O)：%.2f",
            fert[["N"]], fert[["P2O5"]], fert[["K2O"]]),
    sprintf("全田总计（%.1f 亩）：N %.1f kg，P2O5 %.1f kg，K2O %.1f kg",
            area_mu, fert[["N"]] * area_mu, fert[["P2O5"]] * area_mu, fert[["K2O"]] * area_mu),
    "",
    "—— 折算常用肥料 ——",
    "方案A（单质肥料）：",
    sprintf("  尿素 %.1f kg/亩（全田 %.1f kg）",
            prod_A$每亩用量kg[1], prod_A$全田用量kg[1]),
    sprintf("  过磷酸钙 %.1f kg/亩（全田 %.1f kg）",
            prod_A$每亩用量kg[2], prod_A$全田用量kg[2]),
    sprintf("  氯化钾 %.1f kg/亩（全田 %.1f kg）",
            prod_A$每亩用量kg[3], prod_A$全田用量kg[3]),
    "方案B（二铵+尿素+氯化钾）：",
    sprintf("  磷酸二铵 %.1f kg/亩（全田 %.1f kg）",
            prod_B$每亩用量kg[1], prod_B$全田用量kg[1]),
    sprintf("  尿素 %.1f kg/亩（全田 %.1f kg）",
            prod_B$每亩用量kg[2], prod_B$全田用量kg[2]),
    sprintf("  氯化钾 %.1f kg/亩（全田 %.1f kg）",
            prod_B$每亩用量kg[3], prod_B$全田用量kg[3]),
    "",
    "—— 基肥 / 追肥分配（kg/亩，纯养分）——",
    split_note,
    "",
    "—— 计算过程 ——",
    steps,
    "",
    "—— 农艺建议 ——",
    paste0(seq_along(advice), ". ", advice),
    "",
    "注：本推荐基于目标产量法养分平衡计算，供田间决策参考；",
    "    利用率与校正系数为经验默认值，建议用当地试验结果校准。"
  )
  report_text <- paste(L, collapse = "\n")

  list(
    crop = crop, area_mu = area_mu,
    target_yield = target_yield, last_yield = last_yield,
    need = need, supply = supply, supply_from = supply_from,
    fert = fert, diff_last = diff_last,
    prod_A = prod_A, prod_B = prod_B,
    split = split_df, split_note = split_note,
    advice = advice, steps = steps, report_text = report_text
  )
}
