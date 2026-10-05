# =====================================================================
# 科学施肥推荐 App
# 基于目标产量法（养分平衡法）+ SPACSYS 作物养分参数思想
#
# 运行方法（Mac / 本机 R）：
#   install.packages("shiny")      # 只需装一次
#   shiny::runApp("~/workspace/spacsysr/fert-app")   # 路径换成 app 所在目录
# 或在 RStudio 中直接打开 app.R 点 "Run App"
# =====================================================================

# 定位 R/fert_core.R（兼容 shiny::runApp、RStudio Run App 与直接 source）
.ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
.base  <- if (!is.null(.ofile)) dirname(.ofile) else "."
source(file.path(.base, "R", "fert_core.R"))

library(shiny)

ui <- fluidPage(
  titlePanel("🌾 科学施肥推荐"),
  p("基于目标产量法（养分平衡法）：推荐施肥量 ＝（目标产量需肥量 − 土壤供肥量）/ 肥料利用率。",
    "填入地块与去年生产数据即可计算；如有土壤化验值，推荐更准。"),

  sidebarLayout(
    sidebarPanel(
      selectInput("crop", "作物", choices = c("水稻", "小麦")),
      numericInput("area", "地块面积（亩）", value = 10, min = 0.1, step = 1),
      numericInput("target", "目标产量（kg/亩）", value = 600, min = 1),
      numericInput("last_y", "去年产量（kg/亩）", value = 550, min = 1),
      h4("去年施肥量（纯养分，kg/亩）"),
      fluidRow(
        column(4, numericInput("last_N", "氮 N", value = 12, min = 0)),
        column(4, numericInput("last_P", "磷 P2O5", value = 5, min = 0)),
        column(4, numericInput("last_K", "钾 K2O", value = 6, min = 0))
      ),
      h4("土壤化验指标（选填，mg/kg；有则更准）"),
      fluidRow(
        column(6, numericInput("som", "有机质 (g/kg)", value = NA)),
        column(6, numericInput("ph", "pH", value = NA))
      ),
      fluidRow(
        column(4, numericInput("soil_N", "碱解氮", value = NA)),
        column(4, numericInput("soil_P", "有效磷", value = NA)),
        column(4, numericInput("soil_K", "速效钾", value = NA))
      ),
      br(),
      actionButton("go", "计算推荐施肥量", class = "btn-primary btn-lg")
    ),

    mainPanel(
      h3("推荐结果"),
      verbatimTextOutput("summary"),
      h4("肥料折算（常用肥料）"),
      h5("方案 A：单质肥料"),
      tableOutput("prodA"),
      h5("方案 B：磷酸二铵 + 尿素 + 氯化钾"),
      tableOutput("prodB"),
      h4("基肥 / 追肥分配（kg/亩，纯养分）"),
      tableOutput("split"),
      textOutput("split_note"),
      h4("计算过程明细"),
      verbatimTextOutput("steps"),
      h4("农艺建议"),
      verbatimTextOutput("advice"),
      br(),
      downloadButton("dl", "下载推荐方案（TXT 文本报告）")
    )
  )
)

server <- function(input, output, session) {
  res <- eventReactive(input$go, {
    recommend_fertilizer(
      crop         = input$crop,
      area_mu      = input$area,
      target_yield = input$target,
      last_yield   = input$last_y,
      last_N = input$last_N, last_P = input$last_P, last_K = input$last_K,
      som = input$som, ph = input$ph,
      soil_N = input$soil_N, soil_P = input$soil_P, soil_K = input$soil_K
    )
  })

  output$summary <- renderPrint({
    req(res())
    r <- res()
    cat(sprintf("作物：%s   面积：%.1f 亩\n", r$crop, r$area_mu))
    cat(sprintf("目标产量：%.0f kg/亩（去年 %.0f kg/亩）\n\n", r$target_yield, r$last_yield))
    cat("推荐纯养分量（kg/亩）：\n")
    cat(sprintf("  氮 N：%.2f\n  磷 P2O5：%.2f\n  钾 K2O：%.2f\n\n",
                r$fert[["N"]], r$fert[["P2O5"]], r$fert[["K2O"]]))
    cat(sprintf("全田总计（%.1f 亩）：N %.1f kg，P2O5 %.1f kg，K2O %.1f kg\n",
                r$area_mu, r$fert[["N"]] * r$area_mu,
                r$fert[["P2O5"]] * r$area_mu, r$fert[["K2O"]] * r$area_mu))
    cat(sprintf("与去年施肥相比：N %+.1f，P2O5 %+.1f，K2O %+.1f kg/亩\n",
                r$diff_last[["N"]], r$diff_last[["P2O5"]], r$diff_last[["K2O"]]))
  })

  output$prodA <- renderTable({ req(res()); res()$prod_A }, striped = TRUE)
  output$prodB <- renderTable({ req(res()); res()$prod_B }, striped = TRUE)
  output$split <- renderTable({ req(res()); res()$split }, striped = TRUE)
  output$split_note <- renderText({ req(res()); res()$split_note })

  output$steps <- renderPrint({
    req(res())
    cat(paste(res()$steps, collapse = "\n"))
  })

  output$advice <- renderPrint({
    req(res())
    cat(paste0(seq_along(res()$advice), ". ", res()$advice, collapse = "\n"))
  })

  output$dl <- downloadHandler(
    filename = function() {
      paste0("施肥推荐_", res()$crop, "_", format(Sys.Date(), "%Y%m%d"), ".txt")
    },
    content = function(file) {
      writeLines(res()$report_text, file, useBytes = TRUE)
    }
  )
}

shinyApp(ui = ui, server = server)
