# fert_core.R 冒烟测试（纯 base R）
# 运行：Rscript tests/test_core.R   （在 fert-app 目录下）

source(file.path(dirname(sys.frame(1)$ofile), "..", "R", "fert_core.R"))

ok <- function(cond, msg) {
  if (!isTRUE(cond)) stop(paste("FAIL:", msg))
  cat("PASS:", msg, "\n")
}

# 场景1：水稻，无化验值（反推路径）——期望值已用 Python 独立验算
r1 <- recommend_fertilizer("水稻", area_mu = 10, target_yield = 650, last_yield = 600,
                           last_N = 12, last_P = 5, last_K = 6)
ok(abs(r1$fert[["N"]] - 15.14) < 0.01, "水稻 N 推荐 = 15.14 kg/亩")
ok(abs(r1$fert[["P2O5"]] - 7.5) < 0.01, "水稻 P2O5 推荐 = 7.5 kg/亩")
ok(abs(r1$fert[["K2O"]] - 8.7) < 0.01, "水稻 K2O 推荐 = 8.7 kg/亩")
ok(all(r1$supply_from == "去年产量与施肥量反推"), "无化验值时供应量来源为反推")
ok(abs(r1$prod_B$每亩用量kg[1] - 16.3) < 0.1, "方案B 二铵 = 16.3 kg/亩")
ok(abs(r1$prod_B$每亩用量kg[2] - 26.5) < 0.1, "方案B 尿素 = 26.5 kg/亩")
ok(abs(sum(r1$split$基肥 + r1$split$分蘖肥 + r1$split$穗肥) -
       sum(r1$fert)) < 0.2, "水稻基追肥分配加总 = 总推荐量")

# 场景2：小麦，有化验值（化验路径）
r2 <- recommend_fertilizer("小麦", area_mu = 5, target_yield = 550, last_yield = 500,
                           last_N = 14, last_P = 6, last_K = 5,
                           soil_N = 110, soil_P = 18, soil_K = 120)
ok(all(r2$supply_from == "土壤化验值"), "有化验值时供应量来源为化验值")
ok(abs(r2$supply[["N"]] - 110 * 0.15 * 0.6) < 1e-9, "土壤供氮 = 化验值 × 0.15 × 校正系数")
ok(abs(r2$fert[["N"]] - 18.86) < 0.01, "小麦 N 推荐 = 18.86 kg/亩")
ok(abs(r2$fert[["P2O5"]] - 24.9) < 0.01, "小麦 P2O5 推荐 = 24.9 kg/亩")

# 边界：土壤供应充足时推荐量不为负
r3 <- recommend_fertilizer("水稻", area_mu = 10, target_yield = 400, last_yield = 700,
                           last_N = 15, last_P = 8, last_K = 10)
ok(all(r3$fert >= 0), "推荐量不为负")

# 自定义参数
r4 <- recommend_fertilizer("水稻", area_mu = 10, target_yield = 650, last_yield = 600,
                           last_N = 12, last_P = 5, last_K = 6,
                           eff = c(0.40, 0.25, 0.55))
ok(abs(r4$fert[["N"]] - (14.3 - 9.0) / 0.40) < 0.01, "自定义利用率生效")

# 报告文本非空
ok(nchar(r1$report_text) > 500, "文本报告正常生成")

cat("\n全部测试通过。\n")
