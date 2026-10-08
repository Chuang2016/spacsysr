---
title: "水稻积水层与多情景碳足迹对比"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{水稻积水层与多情景碳足迹对比}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



本 vignette 演示 v0.5.0 的两个新功能：

1. **积水层模块**（`ponding`）：稻田淹水水位动态 + 水体溶存气体排放；
2. **多情景批量运行**（`run_scenarios()`）：施肥 × 灌溉制度的碳足迹一次对比。

## 1. 准备数据


``` r
set.seed(42); n <- 150
weather <- data.frame(
  date   = seq(as.Date("2026-06-01"), by = "day", length.out = n),
  tmax   = 31 + 3 * sin(2 * pi * (1:n) / n) + rnorm(n, 0, 1.5),
  tmin   = 23 + 2 * sin(2 * pi * (1:n) / n) + rnorm(n, 0, 1.2),
  precip = pmax(0, rnorm(n, 2.5, 6)))
w <- weather_complete(weather, lat_deg = 30, t_base = 8)
soil <- soil_init(depth_mm = c(200, 300, 500),
                  soc = c(1000, 600, 300),
                  nh4_init = 0.3, no3_init = 0.5)
crop <- crop_default_params("rice")
fert <- data.frame(date = as.Date(c("2026-06-08", "2026-07-10", "2026-08-15")),
                   nh4_add = c(6, 4, 3), no3_add = c(0, 0, 0))
```

## 2. 积水 vs 无积水

`ponding = list(target_mm = 30)` 开启积水模块：每天自动灌溉维持 30 mm
水层（模拟稻田水管理），降雨先蓄于田面再入渗，表土保持饱和（犁底层
限制排水），扩散态 CH4/N2O 经由水体溶存–水柱氧化–水气界面扩散后
排向大气，通气组织传输与逸出气泡则直接 bypass。


``` r
r_paddy <- spacsys_lite_run(w, soil, crop, n_inputs = fert,
                            lat_deg = 30, ponding = list(target_mm = 30))
r_awd   <- spacsys_lite_run(w, soil, crop, n_inputs = fert,
                            lat_deg = 30, ponding = FALSE)
cat("积水天数(>1mm):", sum(r_paddy$pond_mm > 1),
    " 平均水深:", round(mean(r_paddy$pond_mm), 1), "mm\n")
#> 积水天数(>1mm): 84  平均水深: 17.6 mm
for (nm in c("CH4", "N2O")) invisible(nm)
cat(sprintf("paddy: CH4 %.1f kg/ha, N2O %.2f kg N2O/ha\n",
            sum(r_paddy$ch4) * 10, sum(r_paddy$n2o) * 10 * 44 / 28))
#> paddy: CH4 9.5 kg/ha, N2O 1.54 kg N2O/ha
cat(sprintf("AWD  : CH4 %.1f kg/ha, N2O %.2f kg N2O/ha\n",
            sum(r_awd$ch4) * 10, sum(r_awd$n2o) * 10 * 44 / 28))
#> AWD  : CH4 0.2 kg/ha, N2O 0.59 kg N2O/ha
```

持续淹水下 CH4 显著高于干湿交替（AWD），而 N2O 被抑制——
符合稻田实测规律（持续厌氧促进产甲烷、反硝化彻底则 N2O 占比下降）。

## 2.5 田埂高度：控制溢出径流的参数

`bund_mm` 是田埂高度（默认 80 mm）：田面水超过它就漫埂溢出，
计为地表径流。**田埂加高 → 溢出减少**。暴雨天对比一下：


``` r
w_storm <- w; w_storm$precip[60] <- 70  # 一场 70 mm 暴雨
for (b in c(40, 80, 140)) {
  r <- spacsys_lite_run(w_storm, soil, crop, n_inputs = fert, lat_deg = 30,
                        ponding = list(target_mm = 30, bund_mm = b))
  cat(sprintf("bund_mm = %3d: 暴雨日溢出径流 %.1f mm, 最高水位 %.1f mm\n",
              b, r$runoff[60], max(r$pond_mm)))
}
#> bund_mm =  40: 暴雨日溢出径流 19.2 mm, 最高水位 40.0 mm
#> bund_mm =  80: 暴雨日溢出径流 0.0 mm, 最高水位 59.2 mm
#> bund_mm = 140: 暴雨日溢出径流 0.0 mm, 最高水位 59.2 mm
```

田埂是稻田水管理的"总开关"：矮田埂暴雨即排（防涝但肥水流失）、
高田埂蓄水保肥（但有漫灌风险）。模型里调 `bund_mm` 即可做这种
管理情景分析。

## 3. 多情景批量碳足迹对比


``` r
tab <- run_scenarios(w, soil, crop, scenarios = list(
  "持续淹水+施肥" = list(n_inputs = fert, ponding = list(target_mm = 30)),
  "持续淹水不施肥" = list(ponding = list(target_mm = 30)),
  "AWD+施肥"      = list(irrig = TRUE, n_inputs = fert),
  "雨养+施肥"      = list(n_inputs = fert)
), lat_deg = 30)
print(tab[, c("scenario", "yield_t_ha", "ch4_kg_ha", "n2o_kg_ha",
              "ghg_co2eq_kg_ha", "intensity_kg_co2eq_per_t_grain")],
      digits = 4)
#>         scenario yield_t_ha ch4_kg_ha n2o_kg_ha ghg_co2eq_kg_ha
#> 1  持续淹水+施肥     3.0650    9.4863    1.5357           21283
#> 2 持续淹水不施肥     0.7886    8.5545    0.1024           14267
#> 3       AWD+施肥     3.0650    3.3116    0.8179           23790
#> 4      雨养+施肥     1.9165    0.2455    0.5925           17261
#>   intensity_kg_co2eq_per_t_grain
#> 1                           6944
#> 2                          18091
#> 3                           7762
#> 4                           9006
```

`intensity_kg_co2eq_per_t_grain`（每吨籽粒的 CO2 当量）可直接用于
不同水肥管理制度的碳足迹排序。
