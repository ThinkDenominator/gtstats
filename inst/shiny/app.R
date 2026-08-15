options(shiny.sanitize.errors = FALSE)

if (!requireNamespace("shiny", quietly = TRUE) ||
    !requireNamespace("gt", quietly = TRUE) ||
    !requireNamespace("gtstats", quietly = TRUE)) {
  stop(
    "The gtstats GUI requires the gtstats, shiny, and gt packages. ",
    "Install the missing package(s) and run gtstats_app() again.",
    call. = FALSE
  )
}

library(shiny)

`%||%` <- function(x, y) if (is.null(x)) y else x

app_data <- function(name) {
  environment <- new.env(parent = emptyenv())
  utils::data(list = name, package = "gtstats", envir = environment)
  get(name, envir = environment)
}

as_gt <- function(x) {
  if (inherits(x, "gt_tbl")) return(x)
  if (!is.null(x$table) && inherits(x$table, "gt_tbl")) return(x$table)
  if (inherits(x, "gtstats")) return(gtstats::tbl_stats(x))
  if (is.data.frame(x)) return(gt::gt(x))
  stop("This result cannot be displayed as a table.", call. = FALSE)
}

render_result <- function(expression) {
  gt::render_gt({
    result <- expression()
    req(result)
    as_gt(result)
  })
}

download_result <- function(output, id, result) {
  formats <- c(docx = "docx", html = "html", pdf = "pdf", rtf = "rtf")
  for (format in formats) {
    local({
      extension <- format
      output[[paste0(id, "_", extension)]] <- downloadHandler(
        filename = function() paste0("gtstats-", id, ".", extension),
        content = function(file) {
          gtstats::save_output(result(), file, quiet = TRUE)
        }
      )
    })
  }
}

download_strip <- function(id) {
  tags$div(
    class = "download-strip",
    downloadButton(paste0(id, "_docx"), "DOCX"),
    downloadButton(paste0(id, "_html"), "HTML"),
    downloadButton(paste0(id, "_pdf"), "PDF"),
    downloadButton(paste0(id, "_rtf"), "RTF")
  )
}

download_code <- function(output, id, code) {
  output[[paste0(id, "_r")]] <- downloadHandler(
    filename = function() paste0("gtstats-", gsub("_", "-", id), ".R"),
    content = function(file) writeLines(code(), file, useBytes = TRUE)
  )
}

code_card <- function(id) {
  div(
    class = "gtx-card",
    tags$div(class = "card-heading", tags$h4("Reusable code"),
      tags$button(
        type = "button", class = "btn btn-default copy-code",
        `data-copy-target` = id, "Copy code"
      ),
      downloadButton(paste0(id, "_r"), "Download .R")
    ),
    verbatimTextOutput(id)
  )
}

code_vector <- function(x) {
  if (!length(x)) return("character(0)")
  paste0("c(", paste(sprintf('"%s"', x), collapse = ", "), ")")
}

data_type_note <- function(data) {
  paste0(nrow(data), " rows · ", ncol(data), " variables")
}

theme_css <- "
:root { --gtx-charcoal: #252525; --gtx-charcoal-dark: #111111; --gtx-charcoal-soft: #ECECEA; --gtx-green: #2E6A45; --gtx-green-soft: #EAF3EC; --gtx-soft: #F7F7F5; --gtx-line: #D9D9D4; --gtx-text: #252525; --gtx-muted: #62625E; }
body { color: var(--gtx-text); background: var(--gtx-soft); font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; font-size: 15px; line-height: 1.5; }
.navbar { min-height: 58px; background: var(--gtx-charcoal) !important; border: 0; box-shadow: 0 1px 3px rgba(15, 23, 42, .15); }
.navbar-brand, .navbar-nav > li > a { color: white !important; font-weight: 700; }
.navbar-brand { font-size: 1.2rem; letter-spacing: -.01em; }
.navbar-nav > li > a { padding-top: 19px; padding-bottom: 19px; }
.navbar-nav > .active > a, .navbar-nav > .active > a:hover { background: rgba(255, 255, 255, .16) !important; }
.navbar-toggle { border-color: rgba(255, 255, 255, .62); margin-top: 12px; margin-bottom: 12px; }
.navbar-toggle:hover, .navbar-toggle:focus { background: rgba(255, 255, 255, .12) !important; }
.navbar-toggle .icon-bar { background-color: #fff !important; }
.container-fluid { max-width: 1480px; }
.gtx-card, .cardish { border: 1px solid var(--gtx-line); background: #fff; border-radius: 12px; padding: 18px; margin-bottom: 18px; box-shadow: 0 2px 6px rgba(15, 23, 42, .045); }
.gtx-card h3, .cardish h3 { font-size: 1.25rem; font-weight: 750; letter-spacing: -.01em; margin: 0 0 8px; }
.gtx-card h4, .cardish h4 { font-size: 1.05rem; font-weight: 750; margin: 0 0 10px; }
.gtx-side { position: sticky; top: 12px; }
.gtx-help, .help-copy { color: var(--gtx-muted); font-size: .94rem; margin-bottom: 12px; line-height: 1.55; }
.gtx-badge { display: inline-block; padding: 3px 8px; border-radius: 999px; background: #E7E7E4; color: #353532; font-size: .76rem; font-weight: 800; letter-spacing: .02em; }
.gtx-step { border-left: 4px solid #555552; background: #FAFAF8; padding: 11px 13px; margin: 12px 0; color: #3D3D39; border-radius: 0 8px 8px 0; }
.gtx-note { background: #FFF8EE; border: 1px solid #F7D6A6; border-radius: 8px; padding: 11px 13px; color: #7A4015; margin: 12px 0; }
.btn { border-radius: 7px; font-weight: 650; transition: background-color .15s ease, border-color .15s ease, box-shadow .15s ease; }
.btn-primary { background: var(--gtx-charcoal); border-color: var(--gtx-charcoal); }
.btn-primary:hover, .btn-primary:focus { background: var(--gtx-charcoal-dark); border-color: var(--gtx-charcoal-dark); }
.btn-success { background: var(--gtx-green); border-color: var(--gtx-green); }
.btn-success:hover, .btn-success:focus { background: #14643A; border-color: #14643A; }
.btn-default { border-color: #C9C9C4; color: #3B3B38; background: #fff; }
.btn-default:hover, .btn-default:focus { background: #F0F0ED; border-color: #AFAFAA; }
.form-control, .selectize-input { min-height: 38px; border-color: #C9C9C4; border-radius: 7px; box-shadow: none; color: var(--gtx-text); }
.form-control:focus, .selectize-input.focus { border-color: #6B6B66; box-shadow: 0 0 0 3px rgba(37, 37, 37, .12); }
.radio input[type=radio], .checkbox input[type=checkbox] { accent-color: var(--gtx-charcoal); }
.download-strip .btn, .button-row .btn { margin-right: 6px; margin-bottom: 8px; }
.card-heading { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.card-heading h4 { margin: 0; }
.copy-code { font-weight: 700; }
.app-close { position: fixed; right: 18px; bottom: 18px; z-index: 2000; }
.app-close .btn { box-shadow: 0 4px 14px rgba(15, 23, 42, .20); font-weight: 700; }
.gtx-session-bar { background: #EFEFEB; border-bottom: 1px solid #D2D2CD; color: #353532; padding: 10px max(15px, calc((100% - 1450px) / 2)); font-weight: 700; }
.gtx-workflow { max-width: 1480px; margin: 14px auto 2px; padding: 0 15px; display: flex; flex-wrap: wrap; gap: 7px; }
.gtx-workflow-step { border: 1px solid var(--gtx-line); background: #fff; border-radius: 999px; padding: 6px 11px; color: var(--gtx-muted); font-size: .84rem; font-weight: 750; }
.gtx-workflow-step.active { background: var(--gtx-charcoal); border-color: var(--gtx-charcoal); color: white; box-shadow: 0 2px 4px rgba(37, 37, 37, .18); }
pre { background: #F8FAFC; border: 1px solid var(--gtx-line); border-radius: 8px; padding: 12px; }
.nav-tabs { border-bottom-color: var(--gtx-line); }
.nav-tabs > li > a { font-weight: 700; color: var(--gtx-muted); border-radius: 8px 8px 0 0; }
.nav-tabs > li.active > a { color: var(--gtx-charcoal); border-color: var(--gtx-line) var(--gtx-line) #fff; }
.form-group label { font-weight: 750; margin-bottom: 5px; }
.shiny-output-error { color: #B42318; font-weight: 700; }
@media (max-width: 767px) { body { font-size: 14px; } .gtx-card, .cardish { padding: 14px; border-radius: 10px; } .gtx-side { position: static; } .navbar-header { min-height: 58px; } .navbar-collapse { border-top-color: rgba(255,255,255,.18); box-shadow: none; } .navbar-nav { margin-top: 0; margin-bottom: 0; } .navbar-nav > li > a { padding: 12px 15px; } .gtx-session-bar { padding: 9px 15px; font-size: .88rem; } .gtx-workflow { margin-top: 10px; flex-wrap: nowrap; overflow-x: auto; padding-bottom: 4px; scrollbar-width: thin; } .gtx-workflow-step { flex: 0 0 auto; } .download-strip { display: flex; flex-wrap: wrap; gap: 5px; } .download-strip .btn { margin: 0; } .app-close { right: 12px; bottom: 12px; } }
"

copy_code_js <- "
$(document).on('click', '.copy-code', function () {
  var button = this;
  var target = document.getElementById($(button).data('copy-target'));
  if (!target) return;
  var text = target.innerText || target.textContent;
  var copied = function () {
    var old = $(button).text();
    $(button).text('Copied!');
    setTimeout(function () { $(button).text(old); }, 1400);
  };
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text).then(copied);
  } else {
    var area = document.createElement('textarea');
    area.value = text; document.body.appendChild(area); area.select();
    document.execCommand('copy'); document.body.removeChild(area); copied();
  }
});
"

ui <- navbarPage(
  title = tagList("gtstats", span(class = "gtx-badge", "App")),
  id = "workflow",
  header = tagList(
    tags$head(tags$style(HTML(theme_css)), tags$script(HTML(copy_code_js))),
    uiOutput("active_data_status"),
    uiOutput("workflow_progress"),
    tags$div(
      class = "app-close",
      actionButton("close_app", "Close app", icon = icon("xmark"), class = "btn-danger")
    )
  ),
  tabPanel("Data", value = "data",
        br(), fluidRow(
          column(4, div(class = "cardish gtx-side",
            tags$h3("Choose your data"),
            radioButtons("data_source", NULL,
              choices = c("Use a teaching dataset" = "teaching", "Upload my own data" = "upload"),
              selected = "teaching"),
            conditionalPanel("input.data_source === 'teaching'",
              selectInput("teaching_data", "Teaching dataset", choices = c("Birth-weight example" = "birthwt", "Three-arm trial" = "trial_data", "Paired-data example" = "paired_data"), selected = "birthwt"),
              tags$p(class = "help-copy", "Choose a labelled example designed for a different common analysis.")),
            conditionalPanel("input.data_source === 'upload'",
              fileInput("data_file", "Data file", accept = c(".csv", ".xlsx", ".xls", ".rds", ".dta", ".sav", "text/csv", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")),
              textInput("upload_sheet", "Excel worksheet (optional)", placeholder = "First sheet by default"),
              checkboxInput("csv_strings", "Keep text columns as text (CSV only)", value = FALSE)
            ),
            tags$p(class = "help-copy", "Supported uploads: CSV, Excel (.xlsx/.xls), R data (.rds), Stata (.dta), and SPSS (.sav). Uploaded data stay in this browser session only. Excel, Stata, and SPSS import use the optional rio package.")
          )),
          column(8,
            tabsetPanel(
              tabPanel("Preview", div(class = "cardish",
                tags$h3("A first look"), textOutput("data_caption"), br(),
                download_strip("data_preview"), gt::gt_output("data_preview")
              )),
              tabPanel("Data dictionary", div(class = "cardish",
                tags$h3("Variables at a glance"),
                tags$p(class = "help-copy", "This is a working data dictionary: names, labels, detected type, completeness, and values or range."),
                download_strip("data_dictionary"), gt::gt_output("data_dictionary")
              ))
            ),
            code_card("data_code")
          )
        )
      ),
      tabPanel("Understand", value = "understand",
        br(), fluidRow(
          column(4, div(class = "cardish",
            tags$h3("Dataset overview"),
            tags$p(class = "help-copy", "Start here. It identifies variable types, missing values, likely ordinal variables, and concise summaries."),
            actionButton("run_describe", "Describe data", class = "btn-primary"),
            hr(),
            tags$h3("Distribution / spread"),
            selectizeInput("diagnostic_vars", "Continuous variables", choices = NULL, multiple = TRUE),
            selectInput("diagnostic_group", "Group (optional)", choices = NULL),
            checkboxInput("show_variance", "Also show spread by group", FALSE),
            actionButton("run_distribution", "Assess distribution", class = "btn-primary")
          )),
          column(8,
            div(class = "cardish", tags$h3("What is in this dataset?"), download_strip("describe"), gt::gt_output("describe_table")),
            div(class = "cardish", tags$h3("Continuous-variable diagnostics"), download_strip("distribution"), gt::gt_output("distribution_table")),
            conditionalPanel("output.has_variance === true", div(class = "cardish", tags$h3("Spread by group"), download_strip("variance"), gt::gt_output("variance_table"))),
            code_card("understand_code")
          )
        )
      ),
      tabPanel("Data Prep", value = "data_prep",
        br(), gtstats:::mod_data_prep_ui("data_prep")
      ),
      tabPanel("Table 1", value = "table1",
        br(), fluidRow(
          column(4, div(class = "cardish gtx-side",
            tags$h3("The recipe"),
            tags$ol(tags$li("Choose the group columns (optional)."), tags$li("Choose the variables to summarise."), tags$li("Choose the overall column and display style."), tags$li("Create the table.")),
            selectInput("table_group", "Group columns by", choices = NULL),
            uiOutput("table_vars_ui"),
            tags$div(class = "button-row",
              actionButton("table_select_all", "Select all"),
              actionButton("table_clear_all", "Clear")
            ),
            selectInput("table_overall", "Overall column", choices = c("No overall column" = "false", "First" = "first", "Last" = "last")),
            tags$h4("Presentation"),
            selectInput("table_statistic", "Continuous display", choices = c("Recommended for each variable" = "recommended", "Mean (SD)" = "mean_sd", "Mean (95% CI)" = "mean_ci", "Median (IQR)" = "median_iqr", "Both mean (SD) and median (IQR)" = "both")),
            selectInput("table_categorical", "Categorical display", choices = c("n (%)" = "n_percent", "n/N (%)" = "n_over_N_percent", "n only" = "n", "% only" = "percent")),
            tags$div(class = "card-heading", tags$h4("Percentage denominator"), actionLink("percent_help", "Why?")),
            selectInput("table_percent", NULL, choices = c("Within each column" = "column", "Within each row" = "row", "Whole dataset" = "overall")),
            selectInput("table_missing", "Missing values", choices = c("Show when present" = "ifany", "Always show" = "always", "Do not show" = "no")),
            numericInput("table_digits", "Decimal places", 1, min = 0, max = 5, step = 1),
            checkboxInput("table_p", "Add p-values (when grouped)", FALSE),
            actionButton("run_table", "Create Table 1", class = "btn-primary")
          )),
          column(8,
            tabsetPanel(
              tabPanel("Table", div(class = "gtx-card",
                tags$h3("Publication-ready preview"),
                download_strip("summary"), gt::gt_output("summary_table"),
                tags$div(class = "gtx-step", tags$strong("What next? "), "Copy or download the R code for your report. Use the display controls on the left to tailor Table 1 before exporting.")
              )),
              tabPanel("Code", code_card("summary_code"))
            )
          )
        )
      ),
      tabPanel("Compare groups", value = "compare",
        br(), fluidRow(
          column(4, div(class = "cardish",
            tags$h3("One focused question"),
            tags$p(class = "help-copy", "Choose one variable and one grouping variable. For repeated measurements, turn on paired analysis and identify the participant ID. Auto chooses a method from the design and outcome type."),
            selectInput("compare_variable", "Variable to compare", choices = NULL),
            selectInput("compare_group", "Compare across groups", choices = NULL),
            selectInput("compare_test", "Test", choices = c("Auto (recommended starting point)" = "auto", "Student t-test (independent)" = "t_test", "Welch t-test (independent)" = "welch_t", "Wilcoxon rank-sum / signed-rank" = "wilcox", "Classical ANOVA (independent)" = "anova", "Welch ANOVA (independent)" = "welch_anova", "Repeated-measures ANOVA" = "rm_anova", "Kruskal-Wallis (independent)" = "kruskal", "Friedman test (paired 3+)" = "friedman", "Chi-square (independent)" = "chisq", "Fisher's exact (independent)" = "fisher", "McNemar test (paired binary, 2)" = "mcnemar", "Cochran's Q test (paired binary, 3+)" = "cochran_q")),
            tags$div(class = "card-heading", tags$h4("Design"), actionLink("compare_help", "Why?")),
            checkboxInput("compare_paired", "Repeated measurements from the same participant", FALSE),
            conditionalPanel("input.compare_paired", selectInput("compare_id", "Participant ID", choices = NULL), tags$p(class = "help-copy", "Each participant must occur once at every compared occasion. Auto selects paired t/Wilcoxon, repeated-measures ANOVA/Friedman, McNemar, or Cochran's Q as appropriate.")),
            conditionalPanel("!input.compare_paired", checkboxInput("compare_var_equal", "For auto: equal variances are justified", FALSE), tags$p(class = "help-copy", "This only changes a suitable independent, non-skewed continuous auto comparison to Student's t-test or classical ANOVA. It does not run a variance test.")),
            checkboxInput("compare_effect", "Include effect size when supported", FALSE),
            actionButton("run_compare", "Compare groups", class = "btn-primary")
          )),
          column(8,
            tabsetPanel(
              tabPanel("Result", div(class = "gtx-card",
                download_strip("comparison"), gt::gt_output("comparison_table"),
                tags$h4("What did auto choose?"), verbatimTextOutput("comparison_note"),
                tags$div(class = "gtx-step", tags$strong("What next? "), "Review the Audit tabs before reporting a comparison, then copy the code to preserve the decision you made.")
              )),
              tabPanel("Audit", tabsetPanel(
                tabPanel("Diagnostics", div(class = "gtx-card", download_strip("comparison_diagnostics"), gt::gt_output("comparison_diagnostics"))),
                tabPanel("Assumptions", div(class = "gtx-card", download_strip("comparison_assumptions"), gt::gt_output("comparison_assumptions"))),
                tabPanel("Denominators", div(class = "gtx-card", download_strip("comparison_denominators"), gt::gt_output("comparison_denominators")))
              )),
              tabPanel("Code", code_card("comparison_code"))
            )
          )
        )
      ),
      tabPanel("Crosstabs", value = "crosstabs",
        br(), fluidRow(
          column(4, div(class = "cardish",
            tags$h3("Categorical association"),
            tags$p(class = "help-copy", "Use this for two categorical variables. A 2×2 table also reports risk ratio, odds ratio, and risk difference by default."),
            selectInput("cross_row", "Rows (exposure)", choices = NULL),
            selectInput("cross_col", "Columns (outcome)", choices = NULL),
            checkboxGroupInput("cross_percent", "Percentages in cells", choices = c("Column" = "column", "Row" = "row", "Total" = "total"), selected = "column"),
            selectInput("cross_test", "Association test", choices = c("Auto" = "auto", "Chi-square" = "chisq", "Fisher's exact" = "fisher", "Do not test" = "none")),
            actionButton("run_cross", "Create crosstab", class = "btn-primary")
          )),
          column(8,
            tabsetPanel(
              tabPanel("Crosstab", div(class = "gtx-card",
                download_strip("crosstab"), gt::gt_output("crosstab_table"),
                tags$div(class = "gtx-step", tags$strong("What next? "), "For a 2×2 table, read the association test together with the risk ratio, odds ratio, and risk difference; then export or copy the code.")
              )),
              tabPanel("Code", code_card("crosstab_code"))
            )
          )
        )
      ),
      tabPanel("History", value = "history",
        br(), fluidRow(
          column(4, div(class = "cardish",
            tags$h3("This session"),
            tags$p(class = "help-copy", "Keep track of the analyses you ran while exploring this dataset. Download one reproducible script containing the import, preparation, and analyses you actually ran."),
            downloadButton("download_session_script", "Download complete R script", class = "btn-primary"),
            actionButton("clear_history", "Clear history", class = "btn-default")
          )),
          column(8, div(class = "cardish",
            tags$h3("Recent analyses"), download_strip("history"), gt::gt_output("history_table")
          ))
        )
      ),
      tabPanel("Help", value = "help",
        br(), div(class = "cardish",
          tags$h3("From click to code"),
          tags$p(class = "help-copy", "This interface is designed to help you learn the package, not hide the analysis. Each analysis tab provides the matching R code. Copy it into an R script or Quarto document to make your work reproducible."),
          tags$h4("A safe beginner workflow"),
          tags$ol(tags$li("Inspect the data with Describe data."), tags$li("For continuous variables, inspect distribution and spread before interpreting comparisons."), tags$li("Build Table 1 with one consistent summary per variable."), tags$li("Use Compare groups for a focused inferential question."), tags$li("Review the output and the analysis code before reporting a result.")),
          tags$p(class = "help-copy", "Auto test selection is transparent but is not a replacement for study design, clinical judgement, or a prespecified analysis plan."),
          tags$div(class = "gtx-note", "To finish, click Close app in the bottom-right corner. This cleanly stops the local Shiny session and returns you to RStudio.")
        )
      )
)

server <- function(input, output, session) {
  history <- reactiveVal(data.frame(
    analysis = character(), details = character(), time = character(),
    stringsAsFactors = FALSE
  ))
  script_steps <- reactiveVal(list())
  table_selection <- reactiveVal(NULL)
  initial_clicks <- reactiveValues(
    distribution = NULL, table = NULL, comparison = NULL, crosstab = NULL
  )

  # A browser can restore a previous Shiny session's action-button values.
  # Record those values after the interface is connected so restored inputs
  # never silently run an analysis when the app starts.
  session$onFlushed(function() {
    isolate({
      initial_clicks$distribution <- input$run_distribution %||% 0
      initial_clicks$table <- input$run_table %||% 0
      initial_clicks$comparison <- input$run_compare %||% 0
      initial_clicks$crosstab <- input$run_cross %||% 0
    })
  }, once = TRUE)

  record_history <- function(analysis, details, code = NULL) {
    current <- history()
    history(rbind(current, data.frame(
      analysis = analysis,
      details = details,
      time = format(Sys.time(), "%H:%M:%S"),
      stringsAsFactors = FALSE
    )))
    if (!is.null(code) && nzchar(code)) {
      script_steps(c(script_steps(), list(list(analysis = analysis, code = code))))
    }
  }

  observeEvent(input$close_app, {
    shiny::stopApp()
  }, ignoreInit = TRUE)

  observeEvent(input$percent_help, {
    showModal(modalDialog(
      title = "Choose the denominator that answers your question",
      tags$p(tags$strong("Within each column"), " is the usual Table 1 choice: each percentage is calculated within the displayed group."),
      tags$p(tags$strong("Within each row"), " describes where a category is distributed across groups."),
      tags$p(tags$strong("Whole dataset"), " uses every included record as the denominator."),
      footer = modalButton("Close")
    ))
  }, ignoreInit = TRUE)

  observeEvent(input$compare_help, {
    showModal(modalDialog(
      title = "How Compare groups chooses a method",
      tags$p("Start with Auto unless your protocol specifies a test. It considers the outcome type, number of groups, whether observations are paired, and distribution guidance."),
      tags$ul(
        tags$li("Independent, non-skewed continuous outcomes use Welch methods by default."),
        tags$li("Tick equal variances only when that assumption is justified in advance; it changes the suitable independent parametric route to Student's t-test or classical ANOVA."),
        tags$li("Skewed continuous outcomes use rank-based methods; paired designs use paired methods."),
        tags$li("Categorical and ordinal outcomes use their own appropriate routes.")
      ),
      tags$p("Read the Result notes and Audit tabs before reporting a result."),
      footer = modalButton("Close")
    ))
  }, ignoreInit = TRUE)

  imported_data <- reactive({
    if (identical(input$data_source, "upload")) {
      req(input$data_file)
      extension <- tolower(tools::file_ext(input$data_file$name))
      if (identical(extension, "csv")) {
        utils::read.csv(input$data_file$datapath, check.names = FALSE,
          stringsAsFactors = !isTRUE(input$csv_strings))
      } else if (identical(extension, "rds")) {
        readRDS(input$data_file$datapath)
      } else if (extension %in% c("xlsx", "xls", "dta", "sav")) {
        if (!requireNamespace("rio", quietly = TRUE)) {
          stop("Excel, Stata, and SPSS import require the optional 'rio' package. Install it with install.packages('rio') and restart the app.", call. = FALSE)
        }
        if (extension %in% c("xlsx", "xls")) {
          worksheet <- input$upload_sheet %||% ""
          which <- if (!nzchar(worksheet)) 1L else if (grepl("^[0-9]+$", worksheet)) as.integer(worksheet) else worksheet
          as.data.frame(rio::import(input$data_file$datapath, which = which), stringsAsFactors = FALSE)
        } else {
          as.data.frame(rio::import(input$data_file$datapath), stringsAsFactors = FALSE)
        }
      } else {
        stop("Please upload a CSV, Excel, RDS, Stata, or SPSS file.", call. = FALSE)
      }
    } else {
      app_data(input$teaching_data)
    }
  })

  data_prep <- gtstats:::mod_data_prep_server("data_prep", source_data = imported_data)
  selected_data <- reactive({
    prepared <- data_prep$result()
    if (is.null(prepared)) imported_data() else prepared
  })
  output$active_data_status <- renderUI({
    data <- selected_data()
    source <- if (identical(input$data_source, "upload")) "Uploaded data" else paste0("Teaching dataset: ", input$teaching_data %||% "birthwt")
    state <- if (isTRUE(data_prep$using_prepared())) "prepared data" else "original data"
    tags$div(class = "gtx-session-bar", paste0(source, " · ", nrow(data), " rows · ", ncol(data), " variables · Analyses use ", state))
  })
  output$workflow_progress <- renderUI({
    steps <- c(data = "1 Data", data_prep = "2 Prepare", understand = "3 Understand", table1 = "4 Table 1", compare = "5 Compare", crosstabs = "6 Crosstabs")
    current <- input$workflow %||% "data"
    tags$div(class = "gtx-workflow", lapply(names(steps), function(step) {
      tags$span(class = paste("gtx-workflow-step", if (identical(step, current)) "active" else ""), steps[[step]])
    }))
  })

  observeEvent(selected_data(), {
    data <- selected_data()
    variables <- names(data)
    data_overview <- gtstats::describe_data(data, output = "tibble")
    continuous <- data_overview$variable[data_overview$type == "continuous"]
    discrete <- data_overview$variable[data_overview$type %in% c("binary", "categorical", "ordinal")]
    group_variables <- if (length(discrete)) discrete else variables
    updateSelectizeInput(session, "diagnostic_vars", choices = continuous, selected = head(continuous, 2L), server = TRUE)
    group_choices <- c("No grouping" = "", stats::setNames(group_variables, group_variables))
    updateSelectInput(session, "diagnostic_group", choices = group_choices, selected = "")
    updateSelectInput(session, "table_group", choices = group_choices, selected = "")
    compare_default <- if ("age" %in% variables) {
      "age"
    } else {
      setdiff(variables, if ("low" %in% variables) "low" else "")[[1L]]
    }
    updateSelectInput(session, "compare_variable", choices = variables, selected = compare_default)
    updateSelectInput(session, "compare_group", choices = group_variables, selected = if ("low" %in% group_variables) "low" else group_variables[[1L]])
    updateSelectInput(session, "compare_id", choices = variables, selected = variables[[1L]])
    updateSelectInput(session, "cross_row", choices = group_variables, selected = if ("smoke" %in% group_variables) "smoke" else group_variables[[1L]])
    updateSelectInput(session, "cross_col", choices = group_variables, selected = if ("low" %in% group_variables) "low" else group_variables[[min(2L, length(group_variables))]])
    table_selection(NULL)
  }, ignoreInit = FALSE)

  observeEvent(input$table_select_all, {
    table_selection(setdiff(names(selected_data()), input$table_group %||% ""))
  })
  observeEvent(input$table_clear_all, table_selection(character()))
  observeEvent(input$table_vars, table_selection(input$table_vars), ignoreInit = TRUE)

  output$table_vars_ui <- renderUI({
    variables <- names(selected_data())
    group <- input$table_group %||% ""
    choices <- setdiff(variables, group)
    selected <- table_selection()
    if (is.null(selected)) selected <- choices
    selected <- intersect(selected, choices)
    checkboxGroupInput(
      "table_vars", "Select variables to summarise",
      choices = choices, selected = selected
    )
  })

  output$data_caption <- renderText(data_type_note(selected_data()))
  data_preview_result <- reactive(gt::gt(utils::head(selected_data(), 8L)))
  output$data_preview <- render_result(data_preview_result)
  download_result(output, "data_preview", data_preview_result)
  data_dictionary_result <- reactive({
    overview <- gtstats::describe_data(selected_data(), output = "tibble")
    keep <- intersect(c("variable", "label", "type", "complete", "n_unique", "range_levels"), names(overview))
    gt::gt(overview[, keep, drop = FALSE])
  })
  output$data_dictionary <- render_result(data_dictionary_result)
  download_result(output, "data_dictionary", data_dictionary_result)
  data_code <- reactive({
    if (identical(input$data_source, "upload")) {
      extension <- tolower(tools::file_ext(input$data_file$name %||% "csv"))
      if (extension %in% c("xlsx", "xls")) {
        'data <- rio::import("path/to/file.xlsx") |> as.data.frame()'
      } else if (identical(extension, "rds")) {
        'data <- readRDS("path/to/file.rds")'
      } else if (extension %in% c("dta", "sav")) {
        'data <- rio::import("path/to/file.dta") |> as.data.frame()'
      } else {
        'data <- read.csv("path/to/file.csv", check.names = FALSE)'
      }
    } else {
      paste0('data("', input$teaching_data, '", package = "gtstats")\ndata <- ', input$teaching_data)
    }
  })
  output$data_code <- renderText(data_code())
  download_code(output, "data_code", data_code)

  described <- eventReactive(input$run_describe, gtstats::describe_data(selected_data()), ignoreInit = FALSE)
  output$describe_table <- render_result(described)
  download_result(output, "describe", described)

  diagnostic_result <- reactiveVal(NULL)
  observeEvent(input$run_distribution, {
    req(!is.null(initial_clicks$distribution),
      (input$run_distribution %||% 0) > initial_clicks$distribution)
    vars <- input$diagnostic_vars
    validate(need(length(vars) > 0L, "Select at least one continuous variable."))
    group <- input$diagnostic_group
    args <- list(data = selected_data(), vars = vars)
    if (nzchar(group)) args$by <- group
    diagnostic_result(do.call(gtstats::assess_distribution, args))
  }, ignoreInit = TRUE)
  output$distribution_table <- render_result(diagnostic_result)
  download_result(output, "distribution", diagnostic_result)

  variance_result <- reactiveVal(NULL)
  observeEvent(input$run_distribution, {
    req(!is.null(initial_clicks$distribution),
      (input$run_distribution %||% 0) > initial_clicks$distribution)
    req(isTRUE(input$show_variance), nzchar(input$diagnostic_group))
    variance_result(gtstats::assess_variance(selected_data(), vars = input$diagnostic_vars, by = input$diagnostic_group))
  }, ignoreInit = TRUE)
  output$has_variance <- reactive({ isTRUE(input$show_variance) && nzchar(input$diagnostic_group) })
  outputOptions(output, "has_variance", suspendWhenHidden = FALSE)
  output$variance_table <- render_result(variance_result)
  download_result(output, "variance", variance_result)
  understand_code <- reactive({
    group <- input$diagnostic_group %||% ""
    distribution <- if (length(input$diagnostic_vars)) {
      paste0(
        "\n\nassess_distribution(data, vars = ", code_vector(input$diagnostic_vars),
        if (nzchar(group)) paste0(", by = ", group) else "", " )"
      )
    } else ""
    variance <- if (isTRUE(input$show_variance) && nzchar(group) && length(input$diagnostic_vars)) {
      paste0("\n\nassess_variance(data, vars = ", code_vector(input$diagnostic_vars), ", by = ", group, ")")
    } else ""
    paste0("describe_data(data)", distribution, variance)
  })
  output$understand_code <- renderText(understand_code())
  download_code(output, "understand_code", understand_code)

  table_result <- reactiveVal(NULL)
  observeEvent(input$run_table, {
    req(!is.null(initial_clicks$table),
      (input$run_table %||% 0) > initial_clicks$table)
    vars <- input$table_vars
    validate(need(length(vars) > 0L, "Choose at least one variable for Table 1."))
    table_digits <- input$table_digits %||% 1L
    args <- list(data = selected_data(), include = vars,
      statistic = input$table_statistic %||% "recommended",
      categorical = input$table_categorical %||% "n_percent",
      percent = input$table_percent %||% "column",
      missing = input$table_missing %||% "ifany", digits = table_digits)
    if (nzchar(input$table_group)) args$by <- input$table_group
    if (identical(input$table_overall, "first")) args$overall <- "first"
    if (identical(input$table_overall, "last")) args$overall <- "last"
    result <- do.call(gtstats::summary_table, args)
    if (isTRUE(input$table_p)) {
      validate(need(nzchar(input$table_group), "P-values require a grouping variable."))
      result <- gtstats::add_p(result)
    }
    table_result(result)
  }, ignoreInit = TRUE)
  output$summary_table <- render_result(table_result)
  download_result(output, "summary", table_result)
  summary_code <- reactive({
    group <- input$table_group
    lines <- c("summary_table(", "  data,")
    if (nzchar(group)) lines <- c(lines, paste0("  by = ", group, ","))
    lines <- c(
      lines,
      paste0("  include = ", code_vector(input$table_vars), ","),
      paste0("  statistic = ", sprintf('"%s"', input$table_statistic %||% "recommended"), ","),
      paste0("  categorical = ", sprintf('"%s"', input$table_categorical %||% "n_percent"), ","),
      paste0("  percent = ", sprintf('"%s"', input$table_percent %||% "column"), ","),
      paste0("  missing = ", sprintf('"%s"', input$table_missing %||% "ifany"), ",")
    )
    if (!identical(input$table_overall, "false")) {
      lines <- c(lines, paste0("  overall = ", sprintf('"%s"', input$table_overall), ","))
    }
    lines <- c(lines, paste0("  digits = ", input$table_digits %||% 1L), ")")
    paste(c(lines, if (isTRUE(input$table_p)) "|> add_p()"), collapse = "\n")
  })
  output$summary_code <- renderText(summary_code())
  download_code(output, "summary_code", summary_code)

  comparison_result <- reactiveVal(NULL)
  observeEvent(input$run_compare, {
    req(!is.null(initial_clicks$comparison),
      (input$run_compare %||% 0) > initial_clicks$comparison)
    validate(need(!identical(input$compare_variable, input$compare_group), "Variable and group must be different."))
    if (isTRUE(input$compare_paired)) {
      validate(need(!is.null(input$compare_id) && nzchar(input$compare_id), "Choose the participant ID for paired analysis."))
      validate(need(!input$compare_id %in% c(input$compare_variable, input$compare_group), "Participant ID must differ from the outcome and grouping variable."))
    }
    compare_args <- list(
      data = selected_data(), variable = input$compare_variable,
      group = input$compare_group, paired = isTRUE(input$compare_paired),
      test = input$compare_test, var_equal = isTRUE(input$compare_var_equal),
      effect_size = isTRUE(input$compare_effect)
    )
    if (isTRUE(input$compare_paired)) compare_args$id <- input$compare_id
    comparison_result(do.call(gtstats::compare_groups, compare_args))
  }, ignoreInit = TRUE)
  output$comparison_table <- render_result(comparison_result)
  download_result(output, "comparison", comparison_result)
  comparison_diagnostics_result <- reactive({
    result <- comparison_result()
    req(result)
    gt::gt(gtstats::diagnostics_stats(result))
  })
  output$comparison_diagnostics <- render_result(comparison_diagnostics_result)
  download_result(output, "comparison_diagnostics", comparison_diagnostics_result)
  comparison_assumptions_result <- reactive({
    result <- comparison_result()
    req(result)
    gt::gt(gtstats::assumptions_stats(result))
  })
  output$comparison_assumptions <- render_result(comparison_assumptions_result)
  download_result(output, "comparison_assumptions", comparison_assumptions_result)
  comparison_denominators_result <- reactive({
    result <- comparison_result()
    req(result)
    gt::gt(gtstats::denominators_stats(result))
  })
  output$comparison_denominators <- render_result(comparison_denominators_result)
  download_result(output, "comparison_denominators", comparison_denominators_result)
  output$comparison_note <- renderText({
    result <- comparison_result()
    note <- result$notes
    if (length(note)) paste(note, collapse = "\n") else "See the result object for method details."
  })
  comparison_code <- reactive({
    paired_lines <- if (isTRUE(input$compare_paired)) paste0(",\n  paired = TRUE,\n  id = ", input$compare_id) else ""
    paste0("compare_groups(\n  data,\n  variable = ", input$compare_variable,
      ",\n  group = ", input$compare_group, ",\n  test = ", sprintf('"%s"', input$compare_test),
      paired_lines,
      ",\n  var_equal = ", if (isTRUE(input$compare_var_equal)) "TRUE" else "FALSE",
      ",\n  effect_size = ", if (isTRUE(input$compare_effect)) "TRUE" else "FALSE", "\n)")
  })
  output$comparison_code <- renderText(comparison_code())
  download_code(output, "comparison_code", comparison_code)

  crosstab_result <- reactiveVal(NULL)
  observeEvent(input$run_cross, {
    req(!is.null(initial_clicks$crosstab),
      (input$run_cross %||% 0) > initial_clicks$crosstab)
    validate(need(!identical(input$cross_row, input$cross_col), "Rows and columns must be different variables."))
    percentages <- input$cross_percent
    if (!length(percentages)) percentages <- "none"
    crosstab_result(gtstats::crosstabs(selected_data(), row = input$cross_row, col = input$cross_col,
      percent = percentages, test = input$cross_test))
  }, ignoreInit = TRUE)
  output$crosstab_table <- render_result(crosstab_result)
  download_result(output, "crosstab", crosstab_result)
  crosstab_code <- reactive({
    percentages <- input$cross_percent
    if (!length(percentages)) percentages <- "none"
    paste0("crosstabs(\n  data,\n  row = ", input$cross_row, ",\n  col = ", input$cross_col,
      ",\n  percent = ", code_vector(percentages), ",\n  test = ", sprintf('"%s"', input$cross_test), "\n)")
  })
  output$crosstab_code <- renderText(crosstab_code())
  download_code(output, "crosstab_code", crosstab_code)

  observeEvent(input$run_describe, {
    record_history("Describe data", "Dataset overview", isolate("describe_data(data)"))
  }, ignoreInit = TRUE)
  observeEvent(input$run_distribution, {
    distribution_code <- isolate({
      group <- input$diagnostic_group %||% ""
      code <- paste0("assess_distribution(data, vars = ", code_vector(input$diagnostic_vars), if (nzchar(group)) paste0(", by = ", group) else "", ")")
      if (isTRUE(input$show_variance) && nzchar(group)) code <- paste0(code, "\n\nassess_variance(data, vars = ", code_vector(input$diagnostic_vars), ", by = ", group, ")")
      code
    })
    record_history("Assess distribution", paste(length(input$diagnostic_vars), "variable(s)"), distribution_code)
  }, ignoreInit = TRUE)
  observeEvent(input$run_table, {
    record_history("Table 1", paste(length(input$table_vars), "variable(s)"), isolate(summary_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$run_compare, {
    record_history("Compare groups", paste(input$compare_variable, "by", input$compare_group), isolate(comparison_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$run_cross, {
    record_history("Crosstab", paste(input$cross_row, "by", input$cross_col), isolate(crosstab_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$clear_history, {
    showModal(modalDialog(
      title = "Clear this session's analysis history?",
      "This removes the on-screen history and generated session script. It does not change your data.",
      footer = tagList(modalButton("Cancel"), actionButton("confirm_clear_history", "Clear history", class = "btn-danger"))
    ))
  }, ignoreInit = TRUE)
  observeEvent(input$confirm_clear_history, {
    history(data.frame(analysis = character(), details = character(), time = character(), stringsAsFactors = FALSE))
    script_steps(list())
    removeModal()
    showNotification("Session history cleared.", type = "message")
  }, ignoreInit = TRUE)
  history_result <- reactive({
    entries <- history()
    if (!nrow(entries)) entries <- data.frame(Message = "No analyses have been run in this session.")
    gt::gt(entries)
  })
  output$history_table <- render_result(history_result)
  download_result(output, "history", history_result)
  complete_script <- reactive({
    header <- c(
      "# Reproducible script created by the GTstats app",
      paste0("# Created: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
      "",
      "library(gtstats)",
      ""
    )
    import <- if (identical(input$data_source, "upload")) {
      c("# Replace the placeholder path with your original file.", data_code())
    } else {
      data_code()
    }
    prep <- data_prep$code()
    prep_section <- if (!isTRUE(data_prep$using_prepared()) || identical(prep, "# No data-preparation changes applied.")) character() else c("", "# Data preparation", prep)
    steps <- script_steps()
    analysis_section <- unlist(lapply(steps, function(step) c("", paste0("# ", step$analysis), step$code)), use.names = FALSE)
    paste(c(header, "# Data", import, prep_section, analysis_section), collapse = "\n")
  })
  output$download_session_script <- downloadHandler(
    filename = function() "gtstats-session.R",
    content = function(file) writeLines(complete_script(), file, useBytes = TRUE)
  )
}

shinyApp(ui, server)
