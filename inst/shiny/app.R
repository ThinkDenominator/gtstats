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
  formats <- c(docx = "docx", pptx = "pptx", html = "html", pdf = "pdf", rtf = "rtf")
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
    downloadButton(paste0(id, "_pptx"), "PPTX"),
    downloadButton(paste0(id, "_html"), "HTML"),
    downloadButton(paste0(id, "_pdf"), "PDF"),
    downloadButton(paste0(id, "_rtf"), "RTF")
  )
}

download_plot_strip <- function(id) {
  tags$div(
    class = "download-strip",
    downloadButton(paste0(id, "_png"), "PNG"),
    downloadButton(paste0(id, "_pdf"), "PDF")
  )
}

download_plot_result <- function(output, id, result) {
  for (extension in c("png", "pdf")) {
    local({
      file_extension <- extension
      output[[paste0(id, "_", file_extension)]] <- downloadHandler(
        filename = function() paste0("gtstats-", id, ".", file_extension),
        content = function(file) {
          ggplot2::ggsave(
            filename = file, plot = result(), device = file_extension,
            width = 8, height = 6, units = "in", dpi = 300
          )
        }
      )
    })
  }
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

code_named_vector <- function(x) {
  if (!length(x)) return("character(0)")
  paste0("c(", paste(sprintf('"%s" = "%s"', names(x), unname(x)), collapse = ", "), ")")
}

parse_label_mapping <- function(text, label) {
  lines <- unlist(strsplit(text %||% "", "\n", fixed = TRUE), use.names = FALSE)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  if (!length(lines)) return(character())
  values <- character()
  for (line in lines) {
    separator <- regexpr("=", line, fixed = TRUE)[[1L]]
    if (separator < 1L) {
      stop(label, ': use one `current = new` mapping per line. Problem: "', line, '".', call. = FALSE)
    }
    current <- trimws(substr(line, 1L, separator - 1L))
    replacement <- trimws(substr(line, separator + 1L, nchar(line)))
    current <- sub("^`(.*)`$", "\\1", current)
    if (!nzchar(current) || !nzchar(replacement)) {
      stop(label, ': both sides of `=` must contain text. Problem: "', line, '".', call. = FALSE)
    }
    if (current %in% names(values)) {
      stop(label, ': "', current, '" is listed more than once.', call. = FALSE)
    }
    values[[current]] <- replacement
  }
  values
}

parse_name_list <- function(text) {
  values <- trimws(unlist(strsplit(text %||% "", ",", fixed = TRUE), use.names = FALSE))
  unique(values[nzchar(values)])
}

parse_override_lines <- function(text, selected, types, allowed_by_type, kind) {
  lines <- unlist(strsplit(text %||% "", "\n", fixed = TRUE), use.names = FALSE)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  if (!length(lines)) return(list(values = character(), errors = character()))
  values <- character()
  errors <- character()
  for (line in lines) {
    pieces <- strsplit(line, "=", fixed = TRUE)[[1L]]
    if (length(pieces) != 2L) {
      errors <- c(errors, paste0('Use `variable = option` for: "', line, '".'))
      next
    }
    variable <- trimws(pieces[[1L]])
    variable <- sub("^`(.*)`$", "\\1", variable)
    choice <- tolower(trimws(pieces[[2L]]))
    choice <- sub('^["\'](.*)["\']$', "\\1", choice)
    if (!variable %in% selected) {
      errors <- c(errors, paste0('Variable "', variable, '" is not selected in the summary table.'))
      next
    }
    if (variable %in% names(values)) {
      errors <- c(errors, paste0('Variable "', variable, '" is listed more than once.'))
      next
    }
    type <- types[[variable]] %||% "categorical"
    allowed <- allowed_by_type[[type]] %||% character()
    if (!choice %in% allowed) {
      errors <- c(errors, paste0(
        '"', choice, '" is not a supported ', kind, ' for ', variable,
        '. Use one of: ', paste(allowed, collapse = ", "), "."
      ))
      next
    }
    values[[variable]] <- choice
  }
  list(values = values, errors = unique(errors))
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
.gtx-details { border: 1px solid var(--gtx-line); border-radius: 8px; padding: 9px 11px; margin: 10px 0 14px; background: #FAFAF8; }
.gtx-details > summary { cursor: pointer; font-weight: 750; color: var(--gtx-charcoal); }
.gtx-details[open] > summary { margin-bottom: 12px; }
.gtx-control-section { border-top: 1px solid var(--gtx-line); padding-top: 14px; margin-top: 16px; }
.gtx-control-title { display: flex; align-items: center; gap: 8px; margin: 0 0 5px; font-size: 1.08rem; font-weight: 800; color: var(--gtx-charcoal); }
.gtx-control-number { display: inline-flex; align-items: center; justify-content: center; width: 25px; height: 25px; border-radius: 50%; background: var(--gtx-charcoal); color: #fff; font-size: .78rem; }
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
.gtx-variable-options { overflow-x: auto; margin: 14px 0; }
.gtx-variable-options table { min-width: 500px; }
.gtx-variable-options td, .gtx-variable-options th { vertical-align: middle !important; }
.gtx-variable-options .form-group { margin-bottom: 0; }
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
        br(),
        fluidRow(
          column(4, div(class = "cardish gtx-side",
            tags$h3("Dataset overview"),
            tags$p(class = "help-copy", "Start here. It identifies variable types, missing values, likely ordinal variables, and concise summaries."),
            actionButton("run_describe", "Describe data", class = "btn-primary"),
            tags$p(class = "help-copy", "The result opens in the Overview tab below and can be downloaded in publication-ready formats.")
          )),
          column(8, div(class = "cardish",
            tags$h3("Distribution / spread"),
            tags$p(class = "help-copy", "Choose variables once, then assess their numerical distribution, visual shape, and—when grouped—observed spread."),
            fluidRow(
              column(6,
                selectizeInput("diagnostic_vars", "Continuous variables", choices = NULL, multiple = TRUE),
                selectInput("diagnostic_group", "Group (optional)", choices = NULL),
                checkboxInput("show_variance", "Also assess spread by group", FALSE),
                conditionalPanel(
                  "input.show_variance && input.diagnostic_group !== ''",
                  selectInput(
                    "variance_test", "Supporting variance test",
                    choices = c(
                      "Levene / Brown-Forsythe (median-centred)" = "levene",
                      "None (descriptive spread only)" = "none",
                      "Bartlett (requires normal group distributions)" = "bartlett"
                    ),
                    selected = "levene"
                  ),
                  tags$p(class = "help-copy", "Supporting evidence only; it does not change Auto test selection.")
                )
              ),
              column(6,
                checkboxInput("distribution_plots", "Create visual distribution diagnostics", TRUE),
                conditionalPanel(
                  "input.distribution_plots",
                  selectInput("distribution_plot_variable", "Variable to plot", choices = NULL),
                  selectInput("distribution_plot_type", "Diagnostic plot", choices = c(
                    "Histogram" = "histogram", "Density plot" = "density",
                    "Q-Q plot" = "qq", "Boxplot" = "boxplot"
                  )),
                  tags$p(class = "help-copy", "Choose one view at a time. Switch views after assessment without rerunning it.")
                ),
                tags$details(class = "gtx-details",
                  tags$summary("Advanced distribution settings"),
                  checkboxInput("distribution_shapiro", "Include Shapiro-Wilk supporting information", TRUE),
                  numericInput("distribution_skew_cutoff", "Marked-skewness threshold", 1, min = 0.1, step = 0.1),
                  numericInput("distribution_min_n", "Minimum observations", 3, min = 3, step = 1),
                  numericInput("distribution_digits", "Decimal places", 2, min = 0, max = 5, step = 1)
                )
              )
            ),
            actionButton("run_distribution", "Assess distribution", class = "btn-primary")
          ))
        ),
        tabsetPanel(
          id = "understand_results_tab",
          tabPanel("Overview", div(class = "cardish",
            tags$h3("What is in this dataset?"),
            download_strip("describe"), gt::gt_output("describe_table")
          )),
          tabPanel("Distribution", div(class = "cardish",
            tags$h3("Continuous-variable diagnostics"),
            download_strip("distribution"), gt::gt_output("distribution_table")
          )),
          tabPanel("Variance", div(class = "cardish",
            tags$h3("Spread by group"),
            tags$p(class = "help-copy", "Select a group and turn on Also assess spread by group to populate this panel."),
            conditionalPanel("output.has_variance === true", download_strip("variance"), gt::gt_output("variance_table"))
          )),
          tabPanel("Plot", div(class = "cardish",
            tags$h3("Visual distribution diagnostic"),
            tags$p(class = "help-copy", "Histogram, density, Q-Q, and boxplot views are available from the selector above."),
            conditionalPanel("output.has_distribution_plot === true",
              download_plot_strip("distribution_plot"),
              plotOutput("distribution_plot", height = "540px")
            )
          ))
        ),
        code_card("understand_code")
      ),
      tabPanel("Data Prep", value = "data_prep",
        br(), gtstats:::mod_data_prep_ui("data_prep")
      ),
      tabPanel("Summary table", value = "table1",
        br(), fluidRow(
          column(5, div(class = "cardish gtx-side",
            tags$h3("Build your table, layer by layer"),
            tags$p(class = "help-copy", "Start with the descriptive foundation, then add only the layers your report needs. Like peeling an onion, every layer remains visible in the generated R code."),
            tags$div(class = "gtx-control-section",
              tags$div(class = "gtx-control-title", tags$span(class = "gtx-control-number", "1"), "Build the foundation"),
              tags$p(class = "help-copy", "Choose the variables and column structure. Rates and other specialist rows can be added later as optional layers."),
              selectInput("table_group", "Group columns by (optional)", choices = NULL),
              selectInput("table_overall", "Overall column", choices = c("No overall column" = "false", "First" = "first", "Last" = "last")),
              selectInput("table_layout", "Table layout", choices = c("Compact cells" = "compact", "Separate estimate and 95% CI columns" = "separate"), selected = "compact")
            ),
            conditionalPanel("true",
              tags$div(class = "gtx-control-section",
                tags$div(class = "gtx-control-title", tags$span(class = "gtx-control-number", "2"), "Choose how values are shown"),
                checkboxInput("table_include_summary", "Include ordinary variable summaries", TRUE),
                conditionalPanel("input.table_include_summary",
                  uiOutput("table_vars_ui"),
                  tags$div(class = "button-row",
                    actionButton("table_select_all", "Select all"),
                    actionButton("table_clear_all", "Clear")
                  ),
                  selectInput("table_stat_default", "Default for continuous variables", choices = c("Recommended" = "recommended", "Mean (SD)" = "mean_sd", "Mean (95% CI)" = "mean_ci", "Median (IQR)" = "median_iqr", "Mean (SD) and median (IQR)" = "both")),
                  tags$p(class = "help-copy", "Choose the rule for all continuous variables, then enter only exceptions below. Unlisted continuous variables use Recommended when the global choice is Recommended."),
                  textAreaInput("table_stat_overrides", "Summary-statistic overrides (optional)", rows = 4, placeholder = "age = mean_sd\nlwt = median_iqr\nbwt = mean_ci"),
                  tags$div(class = "button-row", actionButton("table_stat_example", "Insert example"), actionButton("table_stat_clear", "Clear overrides")),
                  uiOutput("table_stat_override_status"),
                  selectInput("table_categorical", "Categorical display", choices = c("n (%)" = "n_percent", "n/N (%)" = "n_over_N_percent", "n only" = "n", "% only" = "percent")),
                  selectInput(
                    "table_dichotomous", "Binary variables",
                    choices = c(
                      "Show both levels" = "all_levels",
                      "Show one event level" = "single_row"
                    ),
                    selected = "all_levels"
                  ),
                  conditionalPanel(
                    "input.table_dichotomous === 'single_row'",
                    tags$p(class = "help-copy", "Each binary variable becomes one compact row. By default the second declared level is shown. Enter only event-level overrides below."),
                    textAreaInput(
                      "table_dichotomous_values", "Event levels (optional)", rows = 3,
                      placeholder = "smoke = Yes\nht = Yes"
                    ),
                    tags$p(class = "help-copy", "Use one `variable = event level` per line. The selected event is retained in the result metadata and generated code.")
                  ),
                  selectInput(
                    "table_categorical_layout",
                    "Categorical columns",
                    choices = c(
                      "Keep n and % together (recommended)" = "combined",
                      "Place n and % in separate columns" = "separate"
                    ),
                    selected = "combined"
                  ),
                  tags$p(class = "help-copy", "Separate n and % columns are available for categorical-only tables without confidence intervals."),
                  tags$div(class = "card-heading", tags$h4("Percentage denominator"), actionLink("percent_help", "Why?")),
                  selectInput("table_percent", NULL, choices = c("Within each column" = "column", "Within each row" = "row", "Whole dataset" = "overall")),
                  selectInput("table_missing", "Missing values", choices = c("Show when present" = "ifany", "Always show" = "always", "Do not show" = "no")),
                  numericInput("table_digits", "Decimal places", 1, min = 0, max = 5, step = 1)
                )
              )
            ),
            conditionalPanel("true",
              tags$div(class = "gtx-control-section",
                tags$div(class = "gtx-control-title", tags$span(class = "gtx-control-number", "3"), "Add confidence intervals"),
                checkboxInput("table_ci", "Add confidence intervals", FALSE),
                conditionalPanel("input.table_ci",
                  tags$p(class = "help-copy", "Apply globally, or choose particular variables. Categorical levels receive proportion CIs; continuous means receive mean CIs. Median (IQR) summaries stay unchanged."),
                  selectInput("table_ci_scope", "Apply to", choices = c("All eligible variables" = "all", "Selected variables" = "selected")),
                  conditionalPanel("input.table_ci_scope === 'selected'", uiOutput("table_ci_vars_ui")),
                  selectInput("table_ci_method", "Categorical CI method", choices = c("Wilson (recommended)" = "wilson", "Exact binomial" = "exact")),
                  numericInput("table_conf_level", "Confidence level", 0.95, min = 0.5, max = 0.999, step = 0.01)
                )
              )
            ),
            conditionalPanel("true",
              tags$div(class = "gtx-control-section",
              tags$div(class = "gtx-control-title", tags$span(class = "gtx-control-number", "4"), "Add statistical comparisons"),
              checkboxInput("table_p", "Add p-values (requires a group)", FALSE),
              conditionalPanel(
                "input.table_p",
                tags$p(class = "help-copy", "Auto is used for every unlisted variable. Enter only exceptions; use none to keep a variable descriptive without testing it."),
                textAreaInput(
                  "table_test_overrides", "P-value test overrides (optional)", rows = 5,
                  placeholder = "age = welch_t\nlwt = wilcox\nrace = fisher\nbwt = none"
                ),
                tags$div(class = "button-row",
                  actionButton("table_test_example", "Insert example"),
                  actionButton("table_test_clear", "Clear overrides")
                ),
                uiOutput("table_test_override_status"),
                tags$details(class = "gtx-details",
                  tags$summary("Advanced Auto-test settings"),
                  checkboxInput("table_p_paired", "Repeated measurements from the same participant", FALSE),
                  conditionalPanel("input.table_p_paired", selectInput("table_p_id", "Participant ID", choices = NULL)),
                  checkboxInput("table_distribution_check", "Use distribution guidance in Auto", TRUE),
                  checkboxInput("table_var_equal", "For Auto: equal variances are justified", FALSE),
                  checkboxInput("table_p_correction", "Continuity correction where applicable", TRUE),
                  selectInput("table_p_adjust", "Multiple-testing adjustment", choices = c("None" = "none", "Holm" = "holm", "Bonferroni" = "bonferroni", "Benjamini-Hochberg" = "BH", "False-discovery rate" = "fdr")),
                  numericInput("table_p_digits", "P-value decimal places", 3, min = 1, max = 6, step = 1),
                  numericInput("table_fisher_seed", "Fisher simulation seed", 1049, min = 1, step = 1),
                  tags$p(class = "help-copy", "Distribution guidance uses marked skewness, not Shapiro-Wilk alone. Equal variances changes only suitable independent parametric tests; it does not run a variance test.")
                )
              ))
            ),
            tags$details(class = "gtx-details gtx-control-section", open = FALSE,
              tags$summary(tags$span(class = "gtx-control-title", tags$span(class = "gtx-control-number", "5"), "Add specialist ingredients")),
              conditionalPanel("true",
                checkboxInput("table_add_total", "Add total N row", FALSE),
                conditionalPanel("input.table_add_total",
                  textInput("table_total_label", "Total-row label", value = "Total (N)"),
                  selectInput("table_total_position", "Position", choices = c("First" = "first", "Last" = "last"))
                ),
                checkboxInput("table_add_proportion", "Add selected proportion row", FALSE),
                conditionalPanel("input.table_add_proportion",
                  selectInput("table_prop_var", "Variable", choices = NULL),
                  uiOutput("table_prop_level_ui"),
                  textInput("table_prop_label", "Row label (optional)", placeholder = "Example: Low birth weight"),
                  tags$p(class = "help-copy", "This adds one clinically important event as a new row. It is not needed to add CIs to ordinary categorical rows."),
                  checkboxInput("table_prop_ci", "Add confidence interval", TRUE),
                  tags$details(class = "gtx-details",
                    tags$summary("Advanced proportion options"),
                    selectInput("table_prop_settings", "Settings", choices = c("Inherit from the table" = "inherit", "Override for this row" = "custom")),
                    conditionalPanel("input.table_prop_settings === 'custom'",
                      selectInput("table_prop_display", "Display", choices = c("n (%)" = "n_percent", "% only" = "percent", "n/N (%)" = "n_over_N_percent")),
                      conditionalPanel("input.table_prop_ci",
                        numericInput("table_prop_conf", "Confidence level", 0.95, min = 0.5, max = 0.999, step = 0.01),
                        selectInput("table_prop_ci_method", "Interval method", choices = c("Wilson (recommended)" = "wilson", "Exact binomial" = "exact"))
                      ),
                      numericInput("table_prop_digits", "Decimal places", 1, min = 0, max = 5, step = 1)
                    )
                  )
                )
              ),
              checkboxInput("table_add_rate", "Add an event rate", FALSE),
              conditionalPanel("input.table_add_rate",
                tags$p(class = "help-copy", "A rate needs an event-count variable and a person-time variable."),
                selectInput("table_rate_event", "Event count", choices = NULL),
                selectInput("table_rate_time", "Person-time", choices = NULL),
                textInput("table_rate_label", "Rate label (optional)"),
                numericInput("table_rate_multiplier", "Multiplier", 1000, min = 0.0001),
                textInput("table_rate_time_label", "Time-unit label (optional)", placeholder = "Example: person-years"),
                checkboxInput("table_rate_ci", "Add confidence interval", TRUE),
                conditionalPanel("input.table_rate_ci", numericInput("table_rate_conf", "Confidence level", 0.95, min = 0.5, max = 0.999, step = 0.01)),
                numericInput("table_rate_digits", "Decimal places", 1, min = 0, max = 5, step = 1)
              ),
              checkboxInput("table_add_row", "Add a custom text row", FALSE),
              conditionalPanel("input.table_add_row",
                textInput("table_row_label", "Row label"),
                textInput("table_row_level", "Level text (optional)"),
                uiOutput("table_row_values_ui")
              )
            ),
            tags$details(class = "gtx-details gtx-control-section",
              tags$summary(tags$span(class = "gtx-control-title", tags$span(class = "gtx-control-number", "6"), "Finish the appearance")),
              selectInput("table_theme", "Table theme", choices = c("GTstats default" = "default", "Journal" = "journal", "Classic" = "classic", "Minimal" = "minimal", "Compact" = "compact")),
              textInput("table_title", "Title (optional)", placeholder = "Example: Participant characteristics"),
              textInput("table_subtitle", "Subtitle (optional)"),
              checkboxInput("table_bold_labels", "Bold variable labels", TRUE),
              checkboxInput("table_footnotes", "Show relevant footnotes", TRUE),
              checkboxInput("table_striping", "Alternate row shading", FALSE),
              numericInput("table_font_size", "Font size", 14, min = 9, max = 24, step = 1)
            ),
            actionButton("run_table", "Create summary table", class = "btn-primary")
          )),
          column(7,
            tabsetPanel(
              tabPanel("Table", div(class = "gtx-card",
                tags$h3("Publication-ready preview"),
                download_strip("summary"), gt::gt_output("summary_table"),
                tags$div(class = "gtx-step", tags$strong("What next? "), "Copy or download the R code for your report. Use the controls on the left to tailor the summary table before exporting.")
              )),
              tabPanel("Code", code_card("summary_code"))
            )
          )
        )
      ),
      tabPanel("Customise table", value = "customise",
        br(), fluidRow(
          column(4, div(class = "cardish gtx-side",
            tags$h3("Refine your summary table"),
            tags$p(class = "help-copy", "Your completed Summary table is carried forward automatically. If it has not been created yet, return to Summary table and click Create summary table."),
            uiOutput("custom_source_ui"),
            tags$h4("Text and labels"),
            textInput("custom_title", "Title (optional)", placeholder = "Example: Participant characteristics"),
            textInput("custom_subtitle", "Subtitle (optional)"),
            textInput("custom_spanning_header", "Spanning header (optional)", placeholder = "Example: Birth-weight outcome"),
            textAreaInput("custom_col_labels", "Column labels", rows = 3, placeholder = "p-value = P value\nOverall = All participants"),
            tags$p(class = "help-copy", "One `current column = new label` per line. Use the column names shown in the completed table."),
            textAreaInput("custom_row_labels", "Variable or row labels", rows = 3, placeholder = "age = Maternal age (years)\nsmoke = Smoking status"),
            textAreaInput("custom_level_labels", "Category level labels", rows = 3, placeholder = "Yes = Present\nNo = Absent"),
            textAreaInput("custom_source_note", "Additional note (optional)", rows = 2, placeholder = "Values are based on available observations."),
            textAreaInput("custom_footnote_text", "Additional footnotes (optional)", rows = 2, placeholder = "Enter one note per line"),
            tags$h4("Appearance"),
            selectInput("custom_theme", "Table theme", choices = c("GTstats default" = "default", "Journal" = "journal", "Classic" = "classic", "Minimal" = "minimal", "Compact" = "compact")),
            selectInput("custom_borders", "Borders", choices = c("Horizontal rules" = "horizontal", "All cells" = "all", "Minimal" = "minimal")),
            selectInput("custom_density", "Table spacing", choices = c("Standard" = "standard", "Compact" = "compact", "Spacious" = "spacious")),
            checkboxInput("custom_bold_labels", "Bold variable labels", TRUE),
            checkboxInput("custom_footnotes", "Keep relevant footnotes", TRUE),
            checkboxInput("custom_striping", "Alternate row shading", FALSE),
            numericInput("custom_font_size", "Font size", 14, min = 9, max = 24, step = 1),
            tags$details(class = "gtx-details",
              tags$summary("Advanced appearance and columns"),
              textInput("custom_font", "Font family (optional)", placeholder = "Example: Arial"),
              numericInput("custom_width", "Table width (%)", 100, min = 20, max = 100, step = 5),
              textInput("custom_accent_color", "Rule/accent colour (optional)", placeholder = "#333333"),
              textInput("custom_stripe_color", "Stripe colour (optional)", placeholder = "#F2F2F2"),
              textInput("custom_align_left", "Left-align columns", placeholder = "Characteristic"),
              textInput("custom_align_center", "Centre columns", placeholder = "p-value"),
              textInput("custom_align_right", "Right-align columns", placeholder = "Overall"),
              textInput("custom_bold_cols", "Bold columns", placeholder = "Characteristic"),
              textInput("custom_italic_cols", "Italic columns", placeholder = "Example: Group"),
              tags$p(class = "help-copy", "For column controls, enter exact completed column names separated by commas. Legacy Variable is accepted as an alias for Characteristic.")
            ),
            tags$h4("P-values"),
            selectInput("custom_pvalue_style", "P-value display", choices = c("Threshold below cut-off" = "threshold", "Fixed decimals" = "fixed", "Scientific" = "scientific")),
            numericInput("custom_pvalue_digits", "P-value digits", 3, min = 1, max = 6, step = 1),
            numericInput("custom_pvalue_threshold", "Less-than threshold", 0.001, min = 0.000001, max = 0.1, step = 0.001),
            checkboxInput("custom_pvalue_prefix", "Show p = before ordinary values", FALSE),
            textInput("custom_hide_cols", "Hide columns (optional)", placeholder = "Example: p-value, Overall"),
            tags$p(class = "help-copy", "Enter exact column names separated by commas."),
            actionButton("run_customise", "Apply table changes", class = "btn-primary")
          )),
          column(8,
            tabsetPanel(
              tabPanel("Table", div(class = "gtx-card",
                tags$h3("Summary-table preview"),
                uiOutput("custom_preview_message"),
                download_strip("customised"), gt::gt_output("customised_table")
              )),
              tabPanel("Code", code_card("customised_code"))
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
            checkboxInput("compare_make_plot", "Create comparison plot", TRUE),
            conditionalPanel("input.compare_make_plot",
              selectInput("compare_plot_type", "Plot type", choices = c("Automatic" = "auto", "Boxplot" = "box", "Bar chart" = "bar")),
              selectInput("compare_plot_display", "Categorical bars", choices = c("Proportions" = "proportion", "Counts" = "count")),
              checkboxInput("compare_plot_points", "Show individual continuous observations", TRUE),
              checkboxInput("compare_plot_p", "Show test and p-value in caption", TRUE),
              tags$details(class = "gtx-details",
                tags$summary("Advanced plot appearance"),
                textInput("compare_plot_title", "Plot title (optional)"),
                textInput("compare_plot_caption", "Additional caption (optional)"),
                textInput("compare_plot_xlab", "X-axis label (optional)"),
                textInput("compare_plot_ylab", "Y-axis label (optional)"),
                textInput("compare_plot_legend", "Legend title (optional)"),
                textInput("compare_plot_palette", "Colours (optional)", placeholder = "#333333, #999999"),
                numericInput("compare_plot_size", "Base font size", 14, min = 8, max = 30, step = 1)
              )
            ),
            actionButton("run_compare", "Compare groups", class = "btn-primary")
          )),
          column(8,
            tabsetPanel(
              tabPanel("Result", div(class = "gtx-card",
                download_strip("comparison"), gt::gt_output("comparison_table"),
                tags$h4("What did auto choose?"), verbatimTextOutput("comparison_note"),
                tags$div(class = "gtx-step", tags$strong("What next? "), "Review the Audit tabs before reporting a comparison, then copy the code to preserve the decision you made.")
              )),
              tabPanel("Plot", div(class = "gtx-card",
                tags$h3("Publication-ready comparison plot"),
                download_plot_strip("comparison_plot"),
                plotOutput("comparison_plot", height = "600px")
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
      tabPanel("Correlation", value = "correlation",
        br(), fluidRow(
          column(4, div(class = "cardish gtx-side",
            tags$h3("Explore relationships"),
            tags$p(class = "help-copy", "Analyse one continuous-variable pair or build a publication correlation matrix. The table and plot always use the same coefficients."),
            radioButtons(
              "correlation_mode", "Analysis",
              choices = c("One pair" = "pair", "Correlation matrix" = "matrix"),
              selected = "matrix", inline = TRUE
            ),
            conditionalPanel(
              "input.correlation_mode === 'pair'",
              selectInput("correlation_x", "First variable", choices = NULL),
              selectInput("correlation_y", "Second variable", choices = NULL),
              selectInput("correlation_trend", "Plot trend", choices = c("Automatic" = "auto", "Linear" = "linear", "Smooth" = "smooth", "None" = "none")),
              checkboxInput("correlation_show_ci", "Show trend confidence band", TRUE),
              checkboxInput("correlation_show_result", "Show correlation in plot caption", TRUE)
            ),
            conditionalPanel(
              "input.correlation_mode === 'matrix'",
              checkboxGroupInput("correlation_vars", "Continuous variables", choices = NULL),
              uiOutput("correlation_selection_note"),
              tags$div(class = "button-row",
                actionButton("correlation_select_all", "Select all"),
                actionButton("correlation_clear_all", "Clear")
              ),
              selectInput("correlation_triangle", "Matrix layout", choices = c("Lower triangle (publication standard)" = "lower", "Upper triangle (longest row first)" = "upper", "Full matrix" = "full")),
              selectInput("correlation_display", "Cell content", choices = c("Coefficient only" = "estimate", "Coefficient + adjusted p-value" = "estimate_p", "Coefficient + pairwise n" = "estimate_n", "Coefficient + adjusted p-value + pairwise n" = "estimate_p_n", "Coefficient + confidence interval" = "estimate_ci")),
              tags$details(class = "gtx-details",
                tags$summary("Advanced matrix options"),
                selectInput("correlation_order", "Variable order", choices = c("As selected" = "input", "Alphabetical labels" = "alphabetical", "Cluster similar correlations" = "cluster")),
                checkboxInput("correlation_diagonal", "Show diagonal self-correlations", TRUE),
                selectInput("correlation_adjust", "P-value adjustment", choices = c("None" = "none", "Holm" = "holm", "Bonferroni" = "bonferroni", "Benjamini-Hochberg" = "BH")),
                checkboxInput("correlation_shade", "Shade publication-table cells", TRUE),
                checkboxInput("correlation_plot_values", "Show coefficients on heatmap", TRUE)
              )
            ),
            selectInput("correlation_method", "Method", choices = c("Auto" = "auto", "Pearson" = "pearson", "Spearman" = "spearman")),
            numericInput("correlation_digits", "Decimal places", 2, min = 0, max = 5, step = 1),
            textInput("correlation_title", "Plot title (optional)", placeholder = "Example: Correlation matrix"),
            tags$details(class = "gtx-details",
              tags$summary("Advanced plot appearance"),
              textInput("correlation_caption", "Additional caption (optional)"),
              textInput("correlation_xlab", "X-axis label (pair plot only)"),
              textInput("correlation_ylab", "Y-axis label (pair plot only)"),
              numericInput("correlation_conf_level", "Confidence level", 0.95, min = 0.50, max = 0.999, step = 0.01),
              numericInput("correlation_plot_size", "Base font size", 14, min = 8, max = 30, step = 1),
              conditionalPanel("input.correlation_mode === 'pair'",
                textInput("correlation_point_color", "Point colour", value = "#4472C4"),
                textInput("correlation_line_color", "Trend-line colour", value = "#ED7D31")
              ),
              conditionalPanel("input.correlation_mode === 'matrix'",
                textInput("correlation_low_color", "Negative-correlation colour", value = "#355C7D"),
                textInput("correlation_mid_color", "Zero-correlation colour", value = "#FFFFFF"),
                textInput("correlation_high_color", "Positive-correlation colour", value = "#C06C5B")
              )
            ),
            tags$div(class = "button-row",
              actionButton("run_correlation", "Create correlation output", class = "btn-primary"),
              actionButton("reset_correlation", "Reset options", class = "btn-default")
            )
          )),
          column(8,
            tabsetPanel(
              tabPanel("Table", div(class = "gtx-card",
                tags$h3("Publication-ready correlation table"),
                tags$div(class = "download-strip",
                  downloadButton("correlation_csv", "Tidy CSV")
                ),
                download_strip("correlation"),
                uiOutput("correlation_missingness_note"),
                gt::gt_output("correlation_table"),
                tags$div(class = "gtx-step", tags$strong("How to read it: "), "The coefficient describes direction and strength. Pairwise n may differ when values are missing. Correlation does not imply causation.")
              )),
              tabPanel("Plot", div(class = "gtx-card",
                tags$h3("Visual assessment"),
                download_plot_strip("correlation_plot"),
                plotOutput("correlation_plot", height = "620px")
              )),
              tabPanel("Audit", tabsetPanel(
                tabPanel("Diagnostics", div(class = "gtx-card", download_strip("correlation_diagnostics"), gt::gt_output("correlation_diagnostics"))),
                tabPanel("Assumptions", div(class = "gtx-card", download_strip("correlation_assumptions"), gt::gt_output("correlation_assumptions"))),
                tabPanel("Denominators", div(class = "gtx-card", download_strip("correlation_denominators"), gt::gt_output("correlation_denominators")))
              )),
              tabPanel("Code", code_card("correlation_code"))
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
          column(8, tabsetPanel(
            tabPanel("Recent analyses", div(class = "cardish",
              tags$h3("Recent analyses"), download_strip("history"), gt::gt_output("history_table")
            )),
            tabPanel("Complete R script", code_card("session_code"))
          ))
        )
      ),
      tabPanel("Help", value = "help",
        br(), div(class = "cardish",
          tags$h3("From click to code"),
          tags$p(class = "help-copy", "This interface is designed to help you learn the package, not hide the analysis. Each analysis tab provides the matching R code. Copy it into an R script or Quarto document to make your work reproducible."),
          tags$h4("A safe beginner workflow"),
          tags$ol(tags$li("Inspect the data with Describe data."), tags$li("For continuous variables, inspect distribution and spread before interpreting comparisons."), tags$li("Build a summary table with one consistent summary per variable."), tags$li("Use Compare groups for a focused inferential question."), tags$li("Review the output and the analysis code before reporting a result.")),
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
    distribution = NULL, table = NULL, comparison = NULL, correlation = NULL,
    crosstab = NULL, customise = NULL
  )

  # A browser can restore a previous Shiny session's action-button values.
  # Record those values after the interface is connected so restored inputs
  # never silently run an analysis when the app starts.
  session$onFlushed(function() {
    isolate({
      initial_clicks$distribution <- input$run_distribution %||% 0
      initial_clicks$table <- input$run_table %||% 0
      initial_clicks$comparison <- input$run_compare %||% 0
      initial_clicks$correlation <- input$run_correlation %||% 0
      initial_clicks$crosstab <- input$run_cross %||% 0
      initial_clicks$customise <- input$run_customise %||% 0
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
    steps <- c(data = "1 Data", data_prep = "2 Prepare", understand = "3 Understand", table1 = "4 Summary table", customise = "5 Customise", compare = "6 Compare", correlation = "7 Correlation", crosstabs = "8 Crosstabs")
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
    correlation_default <- head(continuous, min(4L, length(continuous)))
    correlation_x_default <- if (length(continuous)) continuous[[1L]] else ""
    correlation_y_default <- if (length(continuous) >= 2L) continuous[[2L]] else correlation_x_default
    updateSelectInput(session, "correlation_x", choices = continuous, selected = correlation_x_default)
    updateSelectInput(session, "correlation_y", choices = continuous,
      selected = correlation_y_default)
    updateCheckboxGroupInput(session, "correlation_vars", choices = continuous,
      selected = correlation_default)
    updateSelectInput(session, "cross_row", choices = group_variables, selected = if ("smoke" %in% group_variables) "smoke" else group_variables[[1L]])
    updateSelectInput(session, "cross_col", choices = group_variables, selected = if ("low" %in% group_variables) "low" else group_variables[[min(2L, length(group_variables))]])
    table_selection(NULL)
  }, ignoreInit = FALSE)

  observeEvent(input$table_select_all, {
    table_selection(setdiff(names(selected_data()), input$table_group %||% ""))
  })
  observeEvent(input$table_clear_all, table_selection(character()))
  observeEvent(input$table_vars, table_selection(input$table_vars), ignoreInit = TRUE)

  observeEvent(input$correlation_select_all, {
    continuous <- table_type_map()
    continuous <- names(continuous)[continuous == "continuous"]
    updateCheckboxGroupInput(session, "correlation_vars", selected = continuous)
  }, ignoreInit = TRUE)
  observeEvent(input$correlation_clear_all, {
    updateCheckboxGroupInput(session, "correlation_vars", selected = character())
  }, ignoreInit = TRUE)
  output$correlation_selection_note <- renderUI({
    selected <- input$correlation_vars %||% character()
    count <- length(selected)
    if (count > 12L) {
      tags$div(
        class = "gtx-note",
        tags$strong(paste(count, "variables selected. ")),
        "Large matrices are useful for exploration but rarely readable in a publication. Consider 12 or fewer variables or export the tidy CSV."
      )
    } else {
      tags$p(
        class = "help-copy",
        paste0(count, " continuous variable", if (count == 1L) " selected" else "s selected")
      )
    }
  })
  observeEvent(input$reset_correlation, {
    types <- table_type_map()
    continuous <- names(types)[types == "continuous"]
    selected <- head(continuous, min(4L, length(continuous)))
    updateRadioButtons(session, "correlation_mode", selected = "matrix")
    updateCheckboxGroupInput(session, "correlation_vars", selected = selected)
    updateSelectInput(session, "correlation_method", selected = "auto")
    updateSelectInput(session, "correlation_triangle", selected = "lower")
    updateSelectInput(session, "correlation_order", selected = "input")
    updateCheckboxInput(session, "correlation_diagonal", value = TRUE)
    updateSelectInput(session, "correlation_display", selected = "estimate")
    updateSelectInput(session, "correlation_adjust", selected = "none")
    updateCheckboxInput(session, "correlation_shade", value = TRUE)
    updateCheckboxInput(session, "correlation_plot_values", value = TRUE)
    updateSelectInput(session, "correlation_trend", selected = "auto")
    updateCheckboxInput(session, "correlation_show_ci", value = TRUE)
    updateCheckboxInput(session, "correlation_show_result", value = TRUE)
    updateNumericInput(session, "correlation_digits", value = 2)
    updateTextInput(session, "correlation_title", value = "")
    updateTextInput(session, "correlation_caption", value = "")
    updateTextInput(session, "correlation_xlab", value = "")
    updateTextInput(session, "correlation_ylab", value = "")
    updateNumericInput(session, "correlation_conf_level", value = 0.95)
    updateNumericInput(session, "correlation_plot_size", value = 14)
    updateTextInput(session, "correlation_point_color", value = "#4472C4")
    updateTextInput(session, "correlation_line_color", value = "#ED7D31")
    updateTextInput(session, "correlation_low_color", value = "#355C7D")
    updateTextInput(session, "correlation_mid_color", value = "#FFFFFF")
    updateTextInput(session, "correlation_high_color", value = "#C06C5B")
    correlation_result(NULL)
    showNotification("Correlation options reset. No analysis was run.", type = "message")
  }, ignoreInit = TRUE)

  observeEvent(input$diagnostic_vars, {
    variables <- input$diagnostic_vars %||% character()
    current <- input$distribution_plot_variable %||% ""
    selected <- if (current %in% variables) current else if (length(variables)) variables[[1L]] else character()
    updateSelectInput(session, "distribution_plot_variable", choices = variables, selected = selected)
  }, ignoreInit = FALSE)

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
  output$table_ci_vars_ui <- renderUI({
    choices <- input$table_vars %||% character()
    checkboxGroupInput(
      "table_ci_vars", "Variables receiving confidence intervals",
      choices = choices, selected = intersect(input$table_ci_vars %||% choices, choices)
    )
  })

  table_type_map <- reactive({
    overview <- gtstats::describe_data(selected_data(), output = "tibble")
    stats::setNames(overview$type, overview$variable)
  })
  observe({
    types <- table_type_map()
    proportion_vars <- names(types)[types %in% c("binary", "categorical", "ordinal")]
    current_prop <- input$table_prop_var %||% ""
    updateSelectInput(
      session, "table_prop_var", choices = proportion_vars,
      selected = if (current_prop %in% proportion_vars) current_prop else if (length(proportion_vars)) proportion_vars[[1L]] else character()
    )
    numeric_vars <- names(selected_data())[vapply(selected_data(), is.numeric, logical(1))]
    id_choices <- c("Choose ID" = "", stats::setNames(names(selected_data()), names(selected_data())))
    updateSelectInput(session, "table_p_id", choices = id_choices,
      selected = if ((input$table_p_id %||% "") %in% names(selected_data())) input$table_p_id else "")
    updateSelectInput(session, "table_rate_event", choices = numeric_vars,
      selected = if ((input$table_rate_event %||% "") %in% numeric_vars) input$table_rate_event else if (length(numeric_vars)) numeric_vars[[1L]] else character())
    time_default <- setdiff(numeric_vars, input$table_rate_event %||% "")
    updateSelectInput(session, "table_rate_time", choices = numeric_vars,
      selected = if ((input$table_rate_time %||% "") %in% numeric_vars) input$table_rate_time else if (length(time_default)) time_default[[1L]] else character())
  })
  output$table_prop_level_ui <- renderUI({
    variable <- input$table_prop_var %||% ""
    req(nzchar(variable), variable %in% names(selected_data()))
    values <- selected_data()[[variable]]
    levels_available <- if (is.factor(values)) levels(droplevels(values)) else unique(as.character(values[!is.na(values)]))
    selectInput("table_prop_level", "Event level", choices = levels_available,
      selected = if (length(levels_available)) levels_available[[length(levels_available)]] else character())
  })
  output$table_row_values_ui <- renderUI({
    group <- input$table_group %||% ""
    overall <- input$table_overall %||% "false"
    controls <- list()
    if (!identical(overall, "false")) {
      controls <- c(controls, list(textInput("table_row_overall", "Overall value")))
    }
    if (nzchar(group) && group %in% names(selected_data())) {
      values <- selected_data()[[group]]
      group_levels <- if (is.factor(values)) levels(droplevels(values)) else unique(as.character(values[!is.na(values)]))
      controls <- c(controls, lapply(seq_along(group_levels), function(i) {
        textInput(paste0("table_row_group_", i), paste0("Value for ", group_levels[[i]]))
      }))
    } else if (identical(overall, "false")) {
      controls <- c(controls, list(textInput("table_row_single", "Displayed value")))
    }
    tagList(controls)
  })
  table_override_settings <- reactive({
    vars <- input$table_vars %||% character()
    types <- table_type_map()
    summary_allowed <- list(
      continuous = c("recommended", "mean_sd", "mean_ci", "median_iqr", "both"),
      binary = character(), categorical = character(), ordinal = character()
    )
    test_allowed <- list(
      continuous = c("auto", "none", "welch_t", "t_test", "wilcox", "welch_anova", "anova", "kruskal"),
      binary = c("auto", "none", "chisq", "fisher"),
      categorical = c("auto", "none", "chisq", "fisher"),
      ordinal = c("auto", "none", "chisq", "fisher", "wilcox", "kruskal")
    )
    list(
      statistic = parse_override_lines(
        input$table_stat_overrides, vars, types, summary_allowed,
        "summary statistic"
      ),
      method = parse_override_lines(
        input$table_test_overrides, vars, types, test_allowed,
        "p-value test"
      )
    )
  })
  override_status <- function(parsed, fallback, noun) {
    if (length(parsed$errors)) {
      return(tags$div(class = "gtx-note", tags$strong("Please fix: "),
        tags$ul(lapply(parsed$errors, tags$li))))
    }
    count <- length(parsed$values)
    remaining <- max(0L, length(input$table_vars %||% character()) - count)
    tags$p(class = "help-copy", paste0(
      count, " override", if (count == 1L) "" else "s", " recognised. ",
      remaining, " other variable", if (remaining == 1L) "" else "s",
      " will use ", fallback, "."
    ))
  }
  output$table_stat_override_status <- renderUI({
    override_status(table_override_settings()$statistic, "Recommended", "summary")
  })
  output$table_test_override_status <- renderUI({
    parsed <- table_override_settings()$method
    if (length(parsed$errors)) return(override_status(parsed, "Auto", "test"))
    none <- sum(parsed$values == "none")
    explicit <- sum(parsed$values != "none")
    remaining <- max(0L, length(input$table_vars %||% character()) - length(parsed$values))
    tags$p(class = "help-copy", paste0(
      explicit, " explicit test", if (explicit == 1L) "" else "s", " recognised; ",
      none, " variable", if (none == 1L) "" else "s", " set to no test; ",
      remaining, " will use Auto."
    ))
  })
  observeEvent(input$table_stat_example, {
    vars <- input$table_vars %||% character()
    types <- table_type_map()
    continuous <- vars[types[vars] == "continuous"]
    if (!length(continuous)) {
      showNotification("Select at least one continuous variable first.", type = "warning")
    } else {
      choices <- c("mean_sd", "median_iqr", "mean_ci")
      example <- paste0(head(continuous, 3L), " = ", head(choices, length(head(continuous, 3L))))
      updateTextAreaInput(session, "table_stat_overrides", value = paste(example, collapse = "\n"))
    }
  }, ignoreInit = TRUE)
  observeEvent(input$table_stat_clear, {
    updateTextAreaInput(session, "table_stat_overrides", value = "")
  }, ignoreInit = TRUE)
  observeEvent(input$table_test_example, {
    vars <- input$table_vars %||% character()
    types <- table_type_map()
    continuous <- vars[types[vars] == "continuous"]
    categorical <- vars[types[vars] %in% c("binary", "categorical", "ordinal")]
    example <- character()
    if (length(continuous)) example <- c(example, paste0(continuous[[1L]], " = welch_t"))
    if (length(continuous) >= 2L) example <- c(example, paste0(continuous[[2L]], " = wilcox"))
    if (length(categorical)) example <- c(example, paste0(categorical[[1L]], " = fisher"))
    if (!length(example)) {
      showNotification("Select variables before inserting an example.", type = "warning")
    } else {
      updateTextAreaInput(session, "table_test_overrides", value = paste(example, collapse = "\n"))
    }
  }, ignoreInit = TRUE)
  observeEvent(input$table_test_clear, {
    updateTextAreaInput(session, "table_test_overrides", value = "")
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
    args <- list(
      data = selected_data(), vars = vars,
      normality_test = isTRUE(input$distribution_shapiro),
      skew_cutoff = input$distribution_skew_cutoff %||% 1,
      min_n = input$distribution_min_n %||% 3,
      plots = isTRUE(input$distribution_plots),
      digits = input$distribution_digits %||% 2
    )
    if (nzchar(group)) args$by <- group
    diagnostic_result(do.call(gtstats::assess_distribution, args))
  }, ignoreInit = TRUE)
  output$distribution_table <- render_result(diagnostic_result)
  download_result(output, "distribution", diagnostic_result)
  distribution_plot_result <- reactive({
    result <- diagnostic_result()
    req(result, isTRUE(input$distribution_plots))
    variable <- input$distribution_plot_variable %||% ""
    type <- input$distribution_plot_type %||% "histogram"
    req(nzchar(variable), !is.null(result$plots[[variable]][[type]]))
    result$plots[[variable]][[type]]
  })
  output$has_distribution_plot <- reactive({
    !is.null(diagnostic_result()) && isTRUE(input$distribution_plots) &&
      nzchar(input$distribution_plot_variable %||% "")
  })
  outputOptions(output, "has_distribution_plot", suspendWhenHidden = FALSE)
  output$distribution_plot <- renderPlot(distribution_plot_result(), res = 110)
  download_plot_result(output, "distribution_plot", distribution_plot_result)

  variance_result <- reactiveVal(NULL)
  observeEvent(input$run_distribution, {
    req(!is.null(initial_clicks$distribution),
      (input$run_distribution %||% 0) > initial_clicks$distribution)
    req(isTRUE(input$show_variance), nzchar(input$diagnostic_group))
    variance_result(gtstats::assess_variance(
      selected_data(),
      vars = input$diagnostic_vars,
      by = input$diagnostic_group,
      test = input$variance_test %||% "levene"
    ))
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
        if (nzchar(group)) paste0(", by = ", group) else "",
        ", normality_test = ", if (isTRUE(input$distribution_shapiro)) "TRUE" else "FALSE",
        ", skew_cutoff = ", input$distribution_skew_cutoff %||% 1,
        ", min_n = ", input$distribution_min_n %||% 3,
        ", plots = ", if (isTRUE(input$distribution_plots)) "TRUE" else "FALSE",
        ", digits = ", input$distribution_digits %||% 2, ")"
      )
    } else ""
    variance <- if (isTRUE(input$show_variance) && nzchar(group) && length(input$diagnostic_vars)) {
      paste0(
        "\n\nassess_variance(data, vars = ",
        code_vector(input$diagnostic_vars), ", by = ", group,
        if (!identical(input$variance_test %||% "levene", "levene")) {
          paste0(', test = "', input$variance_test, '"')
        } else "",
        ")"
      )
    } else ""
    paste0("describe_data(data)", distribution, variance)
  })
  output$understand_code <- renderText(understand_code())
  download_code(output, "understand_code", understand_code)

  table_result <- reactiveVal(NULL)
  observeEvent(input$run_table, {
    req(!is.null(initial_clicks$table),
      (input$run_table %||% 0) > initial_clicks$table)
    mode <- "summary"
    include_summary <- !identical(input$table_include_summary, FALSE)
    vars <- if (include_summary) input$table_vars %||% character() else character()
    if (include_summary) {
      validate(need(length(vars) > 0L, "Choose at least one variable for the main summaries."))
    }
    table_digits <- input$table_digits %||% 1L
    settings <- table_override_settings()
    if (include_summary) {
      validate(need(!length(settings$statistic$errors), paste(settings$statistic$errors, collapse = "\n")))
      dichotomous_values <- tryCatch(
        parse_label_mapping(input$table_dichotomous_values, "Binary event levels"),
        error = function(error) error
      )
      if (inherits(dichotomous_values, "error")) {
        validate(need(FALSE, conditionMessage(dichotomous_values)))
      }
      if (identical(input$table_categorical_layout %||% "combined", "separate")) {
        selected_types <- vapply(vars, function(variable) {
          gtstats:::.detect_type(selected_data()[[variable]])
        }, character(1))
        validate(need(
          all(selected_types != "continuous"),
          "Separate n and % columns require a categorical-only variable selection."
        ))
        validate(need(
          !isTRUE(input$table_ci),
          "For confidence intervals, keep n and % together and choose the separate estimate/CI table layout."
        ))
        validate(need(
          !isTRUE(input$table_add_proportion) && !isTRUE(input$table_add_rate),
          "Separate n and % columns are for ordinary categorical summaries. Use the combined layout for specialist proportion or rate rows."
        ))
      }
    }
    if (isTRUE(input$table_p)) {
      validate(need(!length(settings$method$errors), paste(settings$method$errors, collapse = "\n")))
    }
    statistic_default <- input$table_stat_default %||% "recommended"
    statistic_arg <- if (length(settings$statistic$values)) {
      c(continuous = statistic_default, settings$statistic$values)
    } else {
      statistic_default
    }
    args <- list(
      data = selected_data(), mode = mode,
      layout = input$table_layout %||% "compact"
    )
    if (include_summary) {
      args$include <- vars
      args$statistic <- statistic_arg
      args$categorical <- input$table_categorical %||% "n_percent"
      args$show_dichotomous <- input$table_dichotomous %||% "all_levels"
      if (identical(args$show_dichotomous, "single_row") &&
          length(dichotomous_values)) {
        args$value <- dichotomous_values
      }
      if (identical(input$table_categorical_layout %||% "combined", "separate")) {
        args$categorical_layout <- "separate"
      }
      args$percent <- input$table_percent %||% "column"
      args$missing <- input$table_missing %||% "ifany"
      args$digits <- table_digits
    }
    if (nzchar(input$table_group)) args$by <- input$table_group
    if (identical(input$table_overall, "first")) args$overall <- "first"
    if (identical(input$table_overall, "last")) args$overall <- "last"
    result <- do.call(gtstats::summary_table, args)
    if (include_summary && isTRUE(input$table_ci)) {
      ci_vars <- if (identical(input$table_ci_scope %||% "all", "selected")) {
        input$table_ci_vars %||% character()
      } else {
        NULL
      }
      if (identical(input$table_ci_scope %||% "all", "selected")) {
        validate(need(length(ci_vars) > 0L, "Choose at least one variable for confidence intervals."))
      }
      ci_args <- list(
        x = result,
        conf.level = input$table_conf_level %||% 0.95,
        method = input$table_ci_method %||% "wilson"
      )
      if (!is.null(ci_vars)) ci_args$vars <- ci_vars
      result <- do.call(gtstats::add_ci, ci_args)
    }
    if (isTRUE(input$table_p)) {
      validate(need(nzchar(input$table_group), "P-values require a grouping variable."))
      validate(need(length(vars) > 0L, "P-values require at least one ordinary variable summary."))
      if (isTRUE(input$table_p_paired)) {
        validate(need(nzchar(input$table_p_id %||% ""), "Choose the participant ID for paired p-values."))
      }
      method_overrides <- settings$method$values
      excluded_vars <- names(method_overrides)[method_overrides == "none"]
      tested_vars <- setdiff(vars, excluded_vars)
      explicit_methods <- method_overrides[method_overrides != "none"]
      if (length(tested_vars) > 0L) {
        p_args <- list(
          x = result,
          method = if (length(explicit_methods)) explicit_methods else "auto",
          include = tested_vars,
          paired = isTRUE(input$table_p_paired),
          distribution_check = isTRUE(input$table_distribution_check),
          var_equal = isTRUE(input$table_var_equal),
          correction = !identical(input$table_p_correction, FALSE),
          fisher_seed = as.integer(input$table_fisher_seed %||% 1049L),
          p_adjust = input$table_p_adjust %||% "none",
          digits = input$table_p_digits %||% 3L
        )
        if (isTRUE(input$table_p_paired)) p_args$id <- input$table_p_id
        result <- do.call(gtstats::add_p, p_args)
      }
    }
    if (isTRUE(input$table_add_total)) {
      result <- gtstats::add_total(
        result,
        label = input$table_total_label %||% "Total (N)",
        position = input$table_total_position %||% "first"
      )
    }
    if (isTRUE(input$table_add_proportion)) {
      validate(need(nzchar(input$table_prop_var %||% ""), "Choose a variable for the selected proportion row."))
      validate(need((input$table_prop_var %||% "") %in% names(selected_data()), "Choose a selected-proportion variable from the current dataset."))
      validate(need(nzchar(input$table_prop_level %||% ""), "Choose an event level for the selected proportion row."))
      prop_args <- list(
        x = result, var = input$table_prop_var, level = input$table_prop_level,
        ci = isTRUE(input$table_prop_ci)
      )
      if (identical(input$table_prop_settings %||% "inherit", "custom")) {
        prop_args$conf.level <- input$table_prop_conf %||% 0.95
        prop_args$ci_method <- input$table_prop_ci_method %||% "wilson"
        prop_args$display <- input$table_prop_display %||% "n_percent"
        prop_args$digits <- input$table_prop_digits %||% 1L
      }
      if (nzchar(input$table_prop_label %||% "")) prop_args$label <- input$table_prop_label
      result <- do.call(gtstats::add_proportion, prop_args)
    }
    if (isTRUE(input$table_add_rate)) {
      validate(need(nzchar(input$table_rate_event %||% ""), "Choose an event-count variable."))
      validate(need(nzchar(input$table_rate_time %||% ""), "Choose a person-time variable."))
      validate(need(!identical(input$table_rate_event, input$table_rate_time), "Event count and person-time must be different variables."))
      rate_args <- list(
        x = result, event = input$table_rate_event, time = input$table_rate_time,
        multiplier = input$table_rate_multiplier %||% 1000,
        ci = isTRUE(input$table_rate_ci),
        conf.level = input$table_rate_conf %||% 0.95,
        digits = input$table_rate_digits %||% 1L,
        layout = input$table_layout %||% "compact"
      )
      if (nzchar(input$table_rate_label %||% "")) rate_args$label <- input$table_rate_label
      if (nzchar(input$table_rate_time_label %||% "")) rate_args$time_label <- input$table_rate_time_label
      result <- do.call(gtstats::add_rate, rate_args)
    }
    if (isTRUE(input$table_add_row)) {
      validate(need(nzchar(input$table_row_label %||% ""), "Enter a label for the custom row."))
      row_args <- list(
        x = result,
        label = input$table_row_label,
        level = input$table_row_level %||% ""
      )
      if (!identical(input$table_overall %||% "false", "false")) {
        row_args$overall <- input$table_row_overall %||% ""
      }
      if (nzchar(input$table_group %||% "")) {
        group_columns <- unname(gtstats:::.builder_group_columns(result))
        group_values <- vapply(seq_along(group_columns), function(i) input[[paste0("table_row_group_", i)]] %||% "", character(1))
        keep <- nzchar(group_values)
        row_args$values <- stats::setNames(group_values[keep], group_columns[keep])
      } else if (identical(input$table_overall %||% "false", "false")) {
        row_args$values <- input$table_row_single %||% ""
      }
      result <- do.call(gtstats::add_row, row_args)
    }
    validate(need(!is.null(result$table) && nrow(result$table) > 0L,
      "Add at least one ingredient: ordinary summaries, a total, a proportion, a rate, or a custom row."))
    table_result(result)
  }, ignoreInit = TRUE)
  summary_display_result <- reactive({
    result <- table_result()
    req(result)
    gtstats::customise_table(
      result,
      engine = "gt",
      theme = input$table_theme %||% "default",
      title = if (nzchar(input$table_title %||% "")) input$table_title else NULL,
      subtitle = if (nzchar(input$table_subtitle %||% "")) input$table_subtitle else NULL,
      bold_labels = isTRUE(input$table_bold_labels),
      show_footnotes = isTRUE(input$table_footnotes),
      row_striping = isTRUE(input$table_striping),
      font_size = input$table_font_size %||% 14
    )
  })
  output$summary_table <- render_result(summary_display_result)
  download_result(output, "summary", summary_display_result)
  summary_code <- reactive({
    mode <- "summary"
    group <- input$table_group %||% ""
    settings <- table_override_settings()
    base_args <- "data"
    if (nzchar(group)) base_args <- c(base_args, paste0("by = ", group))
    if (!identical(input$table_overall, "false")) {
      base_args <- c(base_args, paste0("overall = ", sprintf('"%s"', input$table_overall)))
    }
    base_args <- c(base_args, paste0("layout = ", sprintf('"%s"', input$table_layout %||% "compact")))
    if (!identical(input$table_include_summary, FALSE)) {
      statistic_default <- input$table_stat_default %||% "recommended"
      statistic_code <- if (length(settings$statistic$values)) {
        code_named_vector(c(continuous = statistic_default, settings$statistic$values))
      } else {
        sprintf('"%s"', statistic_default)
      }
      base_args <- c(
        base_args,
        paste0("include = ", code_vector(input$table_vars %||% character())),
        paste0("statistic = ", statistic_code),
        paste0("categorical = ", sprintf('"%s"', input$table_categorical %||% "n_percent")),
        paste0("show_dichotomous = ", sprintf('"%s"', input$table_dichotomous %||% "all_levels")),
        paste0("percent = ", sprintf('"%s"', input$table_percent %||% "column")),
        paste0("missing = ", sprintf('"%s"', input$table_missing %||% "ifany")),
        paste0("digits = ", input$table_digits %||% 1L)
      )
      dichotomous_values <- tryCatch(
        parse_label_mapping(input$table_dichotomous_values, "Binary event levels"),
        error = function(error) character()
      )
      if (identical(input$table_dichotomous %||% "all_levels", "single_row") &&
          length(dichotomous_values)) {
        insert_after <- match(
          paste0("show_dichotomous = ", sprintf('"%s"', input$table_dichotomous %||% "all_levels")),
          base_args
        )
        base_args <- append(
          base_args,
          paste0("value = ", code_named_vector(dichotomous_values)),
          after = insert_after
        )
      }
      if (identical(input$table_categorical_layout %||% "combined", "separate")) {
        base_args <- append(
          base_args,
          'categorical_layout = "separate"',
          after = match(
            paste0("categorical = ", sprintf('"%s"', input$table_categorical %||% "n_percent")),
            base_args
          )
        )
      }
    }
    lines <- c("summary_table(", paste0("  ", base_args, collapse = ",\n"), ")")
    additions <- character()
    if (isTRUE(input$table_ci)) {
      selected_code <- if (identical(input$table_ci_scope %||% "all", "selected")) {
        paste0("vars = ", code_vector(input$table_ci_vars %||% character()), ", ")
      } else ""
      additions <- c(additions, paste0(
        "|>\n  add_ci(", selected_code,
        "conf.level = ", input$table_conf_level %||% 0.95,
        ", method = ", sprintf('"%s"', input$table_ci_method %||% "wilson"), ")"
      ))
    }
    if (isTRUE(input$table_p)) {
      method_overrides <- settings$method$values
      excluded_vars <- names(method_overrides)[method_overrides == "none"]
      tested_vars <- setdiff(input$table_vars %||% character(), excluded_vars)
      explicit_methods <- method_overrides[method_overrides != "none"]
      if (length(tested_vars) > 0L) {
        method_code <- if (length(explicit_methods)) code_named_vector(explicit_methods) else '"auto"'
        include_code <- if (length(excluded_vars)) {
          paste0(", include = ", code_vector(tested_vars))
        } else ""
        additions <- c(additions, paste0(
          "|>\n  add_p(method = ", method_code,
          include_code,
          ", paired = ", if (isTRUE(input$table_p_paired)) "TRUE" else "FALSE",
          if (isTRUE(input$table_p_paired)) paste0(", id = ", input$table_p_id) else "",
          ", distribution_check = ",
          if (isTRUE(input$table_distribution_check)) "TRUE" else "FALSE",
          ", var_equal = ",
          if (isTRUE(input$table_var_equal)) "TRUE" else "FALSE",
          ", correction = ", if (!identical(input$table_p_correction, FALSE)) "TRUE" else "FALSE",
          ", fisher_seed = ", as.integer(input$table_fisher_seed %||% 1049L),
          ", p_adjust = ", sprintf('"%s"', input$table_p_adjust %||% "none"),
          ", digits = ", input$table_p_digits %||% 3L, ")"
        ))
      }
    }
    if (isTRUE(input$table_add_total)) {
      additions <- c(additions, paste0(
        "|>\n  add_total(label = ", sprintf('"%s"', input$table_total_label %||% "Total (N)"),
        ", position = ", sprintf('"%s"', input$table_total_position %||% "first"), ")"
      ))
    }
    if (isTRUE(input$table_add_proportion)) {
      additions <- c(additions, paste0(
        "|>\n  add_proportion(\n    var = ", input$table_prop_var,
        ",\n    level = ", sprintf('"%s"', input$table_prop_level %||% ""),
        if (nzchar(input$table_prop_label %||% "")) paste0(",\n    label = ", sprintf('"%s"', input$table_prop_label)) else "",
        if (identical(input$table_prop_settings %||% "inherit", "custom")) paste0(",\n    display = ", sprintf('"%s"', input$table_prop_display %||% "n_percent")) else "",
        if (!isTRUE(input$table_prop_ci)) ",\n    ci = FALSE" else "",
        if (identical(input$table_prop_settings %||% "inherit", "custom")) paste0(",\n    conf.level = ", input$table_prop_conf %||% 0.95) else "",
        if (identical(input$table_prop_settings %||% "inherit", "custom")) paste0(",\n    ci_method = ", sprintf('"%s"', input$table_prop_ci_method %||% "wilson")) else "",
        if (identical(input$table_prop_settings %||% "inherit", "custom")) paste0(",\n    digits = ", input$table_prop_digits %||% 1L) else "",
        "\n  )"
      ))
    }
    if (isTRUE(input$table_add_rate)) {
      additions <- c(additions, paste0(
        "|>\n  add_rate(\n    event = ", input$table_rate_event,
        ",\n    time = ", input$table_rate_time,
        if (nzchar(input$table_rate_label %||% "")) paste0(",\n    label = ", sprintf('"%s"', input$table_rate_label)) else "",
        ",\n    multiplier = ", input$table_rate_multiplier %||% 1000,
        if (nzchar(input$table_rate_time_label %||% "")) paste0(",\n    time_label = ", sprintf('"%s"', input$table_rate_time_label)) else "",
        ",\n    ci = ", if (isTRUE(input$table_rate_ci)) "TRUE" else "FALSE",
        ",\n    conf.level = ", input$table_rate_conf %||% 0.95,
        ",\n    digits = ", input$table_rate_digits %||% 1L,
        ",\n    layout = ", sprintf('"%s"', input$table_layout %||% "compact"), "\n  )"
      ))
    }
    if (isTRUE(input$table_add_row)) {
      row_parts <- c(paste0("label = ", sprintf('"%s"', input$table_row_label %||% "")))
      if (nzchar(input$table_row_level %||% "")) row_parts <- c(row_parts, paste0("level = ", sprintf('"%s"', input$table_row_level)))
      if (!identical(input$table_overall %||% "false", "false")) row_parts <- c(row_parts, paste0("overall = ", sprintf('"%s"', input$table_row_overall %||% "")))
      if (nzchar(group)) {
        group_data <- selected_data()[[group]]
        group_levels <- if (is.factor(group_data)) levels(droplevels(group_data)) else unique(as.character(group_data[!is.na(group_data)]))
        group_values <- vapply(seq_along(group_levels), function(i) input[[paste0("table_row_group_", i)]] %||% "", character(1))
        keep <- nzchar(group_values)
        if (any(keep)) row_parts <- c(row_parts, paste0("values = ", code_named_vector(stats::setNames(group_values[keep], paste0(group, " = ", group_levels[keep])))))
      } else if (identical(input$table_overall %||% "false", "false")) {
        row_parts <- c(row_parts, paste0("values = ", sprintf('"%s"', input$table_row_single %||% "")))
      }
      additions <- c(additions, paste0("|>\n  add_row(\n    ", paste(row_parts, collapse = ",\n    "), "\n  )"))
    }
    additions <- c(additions, paste0(
      "|>\n  customise_table(theme = ", sprintf('"%s"', input$table_theme %||% "default"),
      if (nzchar(input$table_title %||% "")) paste0(", title = ", sprintf('"%s"', input$table_title)) else "",
      if (nzchar(input$table_subtitle %||% "")) paste0(", subtitle = ", sprintf('"%s"', input$table_subtitle)) else "",
      ", bold_labels = ", if (isTRUE(input$table_bold_labels)) "TRUE" else "FALSE",
      ", show_footnotes = ", if (isTRUE(input$table_footnotes)) "TRUE" else "FALSE",
      ", row_striping = ", if (isTRUE(input$table_striping)) "TRUE" else "FALSE",
      ", font_size = ", input$table_font_size %||% 14, ")"
    ))
    base_code <- paste(lines, collapse = "\n")
    if (length(additions)) paste0(base_code, " ", paste(additions, collapse = " ")) else base_code
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
    gtstats::diagnostics_stats(result)
  })
  output$comparison_diagnostics <- render_result(comparison_diagnostics_result)
  download_result(output, "comparison_diagnostics", comparison_diagnostics_result)
  comparison_assumptions_result <- reactive({
    result <- comparison_result()
    req(result)
    gtstats::assumptions_stats(result)
  })
  output$comparison_assumptions <- render_result(comparison_assumptions_result)
  download_result(output, "comparison_assumptions", comparison_assumptions_result)
  comparison_denominators_result <- reactive({
    result <- comparison_result()
    req(result)
    gtstats::denominators_stats(result)
  })
  output$comparison_denominators <- render_result(comparison_denominators_result)
  download_result(output, "comparison_denominators", comparison_denominators_result)
  output$comparison_note <- renderText({
    result <- comparison_result()
    note <- result$notes
    if (length(note)) paste(note, collapse = "\n") else "See the result object for method details."
  })
  comparison_plot_result <- reactive({
    req(comparison_result(), isTRUE(input$compare_make_plot))
    palette <- parse_name_list(input$compare_plot_palette)
    args <- list(
      data = selected_data(), variable = input$compare_variable,
      group = input$compare_group, paired = isTRUE(input$compare_paired),
      type = input$compare_plot_type %||% "auto",
      display = input$compare_plot_display %||% "proportion",
      show_points = isTRUE(input$compare_plot_points),
      show_p = isTRUE(input$compare_plot_p),
      test = input$compare_test %||% "auto",
      var_equal = isTRUE(input$compare_var_equal),
      base_size = input$compare_plot_size %||% 14,
      title = if (nzchar(input$compare_plot_title %||% "")) input$compare_plot_title else NULL,
      caption = if (nzchar(input$compare_plot_caption %||% "")) input$compare_plot_caption else NULL,
      xlab = if (nzchar(input$compare_plot_xlab %||% "")) input$compare_plot_xlab else NULL,
      ylab = if (nzchar(input$compare_plot_ylab %||% "")) input$compare_plot_ylab else NULL,
      legend_title = if (nzchar(input$compare_plot_legend %||% "")) input$compare_plot_legend else NULL
    )
    if (length(palette)) args$palette <- palette
    if (isTRUE(input$compare_paired)) args$id <- input$compare_id
    do.call(gtstats::plot_compare, args)
  })
  output$comparison_plot <- renderPlot(comparison_plot_result(), res = 110)
  download_plot_result(output, "comparison_plot", comparison_plot_result)
  comparison_code <- reactive({
    paired_lines <- if (isTRUE(input$compare_paired)) paste0(",\n  paired = TRUE,\n  id = ", input$compare_id) else ""
    paste0("compare_groups(\n  data,\n  variable = ", input$compare_variable,
      ",\n  group = ", input$compare_group, ",\n  test = ", sprintf('"%s"', input$compare_test),
      paired_lines,
      ",\n  var_equal = ", if (isTRUE(input$compare_var_equal)) "TRUE" else "FALSE",
      ",\n  effect_size = ", if (isTRUE(input$compare_effect)) "TRUE" else "FALSE", "\n)")
  })
  comparison_plot_code <- reactive({
    if (!isTRUE(input$compare_make_plot)) return("")
    palette <- parse_name_list(input$compare_plot_palette)
    optional <- c(
      if (isTRUE(input$compare_paired)) paste0("  paired = TRUE,\n  id = ", input$compare_id, ",") else character(),
      if (length(palette)) paste0("  palette = ", code_vector(palette), ",") else character(),
      if (nzchar(input$compare_plot_title %||% "")) paste0("  title = ", sprintf('"%s"', input$compare_plot_title), ",") else character(),
      if (nzchar(input$compare_plot_caption %||% "")) paste0("  caption = ", sprintf('"%s"', input$compare_plot_caption), ",") else character(),
      if (nzchar(input$compare_plot_xlab %||% "")) paste0("  xlab = ", sprintf('"%s"', input$compare_plot_xlab), ",") else character(),
      if (nzchar(input$compare_plot_ylab %||% "")) paste0("  ylab = ", sprintf('"%s"', input$compare_plot_ylab), ",") else character(),
      if (nzchar(input$compare_plot_legend %||% "")) paste0("  legend_title = ", sprintf('"%s"', input$compare_plot_legend), ",") else character()
    )
    paste0(
      "\n\ncomparison_plot <- plot_compare(\n  data,\n  variable = ", input$compare_variable,
      ",\n  group = ", input$compare_group, ",\n",
      if (length(optional)) paste0(paste(optional, collapse = "\n"), "\n") else "",
      "  type = ", sprintf('"%s"', input$compare_plot_type %||% "auto"), ",\n",
      "  display = ", sprintf('"%s"', input$compare_plot_display %||% "proportion"), ",\n",
      "  show_points = ", if (isTRUE(input$compare_plot_points)) "TRUE" else "FALSE", ",\n",
      "  show_p = ", if (isTRUE(input$compare_plot_p)) "TRUE" else "FALSE", ",\n",
      "  test = ", sprintf('"%s"', input$compare_test %||% "auto"), ",\n",
      "  var_equal = ", if (isTRUE(input$compare_var_equal)) "TRUE" else "FALSE", ",\n",
      "  base_size = ", input$compare_plot_size %||% 14, "\n)"
    )
  })
  comparison_full_code <- reactive(paste0(comparison_code(), comparison_plot_code()))
  output$comparison_code <- renderText(comparison_full_code())
  download_code(output, "comparison_code", comparison_full_code)

  correlation_result <- reactiveVal(NULL)
  observeEvent(input$run_correlation, {
    req(!is.null(initial_clicks$correlation),
      (input$run_correlation %||% 0) > initial_clicks$correlation)
    if (identical(input$correlation_mode, "matrix")) {
      vars <- input$correlation_vars %||% character()
      validate(need(length(vars) >= 2L, "Select at least two continuous variables for a matrix."))
      correlation_result(gtstats::correlation(
        selected_data(), vars = vars,
        method = input$correlation_method %||% "auto",
        triangle = input$correlation_triangle %||% "lower",
        order = input$correlation_order %||% "input",
        show_diagonal = isTRUE(input$correlation_diagonal),
        display = input$correlation_display %||% "estimate",
        shade = isTRUE(input$correlation_shade),
        adjust = input$correlation_adjust %||% "none",
        conf.level = input$correlation_conf_level %||% 0.95,
        digits = input$correlation_digits %||% 2L
      ))
    } else {
      validate(need(nzchar(input$correlation_x %||% "") && nzchar(input$correlation_y %||% ""),
        "Choose two continuous variables."))
      validate(need(!identical(input$correlation_x, input$correlation_y),
        "The two correlation variables must be different."))
      correlation_result(gtstats::correlation(
        selected_data(), x = input$correlation_x, y = input$correlation_y,
        method = input$correlation_method %||% "auto",
        conf.level = input$correlation_conf_level %||% 0.95,
        digits = input$correlation_digits %||% 2L
      ))
    }
  }, ignoreInit = TRUE)
  output$correlation_table <- render_result(correlation_result)
  download_result(output, "correlation", correlation_result)
  output$correlation_csv <- downloadHandler(
    filename = function() "gtstats-correlation-tidy.csv",
    content = function(file) {
      result <- correlation_result()
      req(result)
      utils::write.csv(result$summary, file, row.names = FALSE, na = "")
    }
  )
  output$correlation_missingness_note <- renderUI({
    result <- correlation_result()
    req(result)
    if (!inherits(result, "gt_correlation_matrix")) return(NULL)
    pair_n <- result$summary$n
    if (length(unique(pair_n)) <= 1L) return(NULL)
    tags$div(
      class = "gtx-note",
      tags$strong("Pairwise denominators differ. "),
      paste0(
        "The displayed correlations use between ", min(pair_n), " and ",
        max(pair_n), " complete pairs. Review the Denominators tab before comparing coefficients."
      )
    )
  })

  correlation_plot_result <- reactive({
    result <- correlation_result()
    req(result)
    title <- input$correlation_title %||% ""
    title <- if (nzchar(title)) title else NULL
    caption <- input$correlation_caption %||% ""
    caption <- if (nzchar(caption)) caption else NULL
    if (inherits(result, "gt_correlation_matrix")) {
      gtstats::plot_correlation(
        result,
        show_values = isTRUE(input$correlation_plot_values),
        base_size = input$correlation_plot_size %||% 14,
        title = title,
        caption = caption,
        low_color = input$correlation_low_color %||% "#355C7D",
        mid_color = input$correlation_mid_color %||% "#FFFFFF",
        high_color = input$correlation_high_color %||% "#C06C5B"
      )
    } else {
      gtstats::plot_correlation(
        selected_data(), x = input$correlation_x, y = input$correlation_y,
        method = input$correlation_method %||% "auto",
        trend = input$correlation_trend %||% "auto",
        show_ci = isTRUE(input$correlation_show_ci),
        show_correlation = isTRUE(input$correlation_show_result),
        conf.level = input$correlation_conf_level %||% 0.95,
        digits = input$correlation_digits %||% 2L,
        point_color = input$correlation_point_color %||% "#4472C4",
        line_color = input$correlation_line_color %||% "#ED7D31",
        base_size = input$correlation_plot_size %||% 14,
        title = title,
        caption = caption,
        xlab = if (nzchar(input$correlation_xlab %||% "")) input$correlation_xlab else NULL,
        ylab = if (nzchar(input$correlation_ylab %||% "")) input$correlation_ylab else NULL
      )
    }
  })
  output$correlation_plot <- renderPlot(correlation_plot_result(), res = 110)
  download_plot_result(output, "correlation_plot", correlation_plot_result)

  correlation_diagnostics_result <- reactive({
    result <- correlation_result(); req(result)
    gtstats::diagnostics_stats(result)
  })
  correlation_assumptions_result <- reactive({
    result <- correlation_result(); req(result)
    gtstats::assumptions_stats(result)
  })
  correlation_denominators_result <- reactive({
    result <- correlation_result(); req(result)
    gtstats::denominators_stats(result)
  })
  output$correlation_diagnostics <- render_result(correlation_diagnostics_result)
  output$correlation_assumptions <- render_result(correlation_assumptions_result)
  output$correlation_denominators <- render_result(correlation_denominators_result)
  download_result(output, "correlation_diagnostics", correlation_diagnostics_result)
  download_result(output, "correlation_assumptions", correlation_assumptions_result)
  download_result(output, "correlation_denominators", correlation_denominators_result)

  correlation_code <- reactive({
    title <- input$correlation_title %||% ""
    title_code <- if (nzchar(title)) paste0(", title = ", sprintf('"%s"', title)) else ""
    optional_text <- function(name, value) {
      value <- value %||% ""
      if (nzchar(value)) paste0(",\n  ", name, " = ", sprintf('"%s"', value)) else ""
    }
    if (identical(input$correlation_mode, "matrix")) {
      analysis <- paste0(
        "correlation_result <- correlation(\n  data,\n  vars = ", code_vector(input$correlation_vars %||% character()),
        ",\n  method = ", sprintf('"%s"', input$correlation_method %||% "auto"),
        ",\n  triangle = ", sprintf('"%s"', input$correlation_triangle %||% "lower"),
        ",\n  order = ", sprintf('"%s"', input$correlation_order %||% "input"),
        ",\n  show_diagonal = ", if (isTRUE(input$correlation_diagonal)) "TRUE" else "FALSE",
        ",\n  display = ", sprintf('"%s"', input$correlation_display %||% "estimate"),
        ",\n  shade = ", if (isTRUE(input$correlation_shade)) "TRUE" else "FALSE",
        ",\n  adjust = ", sprintf('"%s"', input$correlation_adjust %||% "none"),
        ",\n  conf.level = ", input$correlation_conf_level %||% 0.95,
        ",\n  digits = ", input$correlation_digits %||% 2L, "\n)"
      )
      plot <- paste0(
        "plot_correlation(\n  correlation_result,\n  show_values = ",
        if (isTRUE(input$correlation_plot_values)) "TRUE" else "FALSE",
        ",\n  base_size = ", input$correlation_plot_size %||% 14,
        ",\n  low_color = ", sprintf('"%s"', input$correlation_low_color %||% "#355C7D"),
        ",\n  mid_color = ", sprintf('"%s"', input$correlation_mid_color %||% "#FFFFFF"),
        ",\n  high_color = ", sprintf('"%s"', input$correlation_high_color %||% "#C06C5B"),
        title_code,
        optional_text("caption", input$correlation_caption), "\n)"
      )
    } else {
      analysis <- paste0(
        "correlation_result <- correlation(\n  data,\n  x = ", input$correlation_x,
        ",\n  y = ", input$correlation_y,
        ",\n  method = ", sprintf('"%s"', input$correlation_method %||% "auto"),
        ",\n  conf.level = ", input$correlation_conf_level %||% 0.95,
        ",\n  digits = ", input$correlation_digits %||% 2L, "\n)"
      )
      plot <- paste0(
        "plot_correlation(\n  data,\n  x = ", input$correlation_x,
        ",\n  y = ", input$correlation_y,
        ",\n  method = ", sprintf('"%s"', input$correlation_method %||% "auto"),
        ",\n  trend = ", sprintf('"%s"', input$correlation_trend %||% "auto"),
        ",\n  show_ci = ", if (isTRUE(input$correlation_show_ci)) "TRUE" else "FALSE",
        ",\n  show_correlation = ", if (isTRUE(input$correlation_show_result)) "TRUE" else "FALSE",
        ",\n  conf.level = ", input$correlation_conf_level %||% 0.95,
        ",\n  digits = ", input$correlation_digits %||% 2L,
        ",\n  point_color = ", sprintf('"%s"', input$correlation_point_color %||% "#4472C4"),
        ",\n  line_color = ", sprintf('"%s"', input$correlation_line_color %||% "#ED7D31"),
        ",\n  base_size = ", input$correlation_plot_size %||% 14,
        title_code,
        optional_text("caption", input$correlation_caption),
        optional_text("xlab", input$correlation_xlab),
        optional_text("ylab", input$correlation_ylab), "\n)"
      )
    }
    paste(analysis, plot, sep = "\n\n")
  })
  output$correlation_code <- renderText(correlation_code())
  download_code(output, "correlation_code", correlation_code)

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

  output$custom_source_ui <- renderUI({
    if (is.null(table_result())) {
      return(tags$div(
        class = "gtx-note",
        tags$strong("No Summary table yet. "),
        "Open Summary table, choose the variables, and click Create summary table."
      ))
    }
    tags$div(
      class = "gtx-step",
      tags$strong("Using: "), "the most recently created Summary table"
    )
  })
  selected_completed_table <- reactive({
    req(table_result())
    table_result()
  })
  completed_table_code <- reactive({
    req(table_result())
    summary_code()
  })
  custom_settings <- reactive({
    list(
      col_labels = parse_label_mapping(input$custom_col_labels, "Column labels"),
      row_labels = parse_label_mapping(input$custom_row_labels, "Row labels"),
      level_labels = parse_label_mapping(input$custom_level_labels, "Category level labels"),
      hide_cols = parse_name_list(input$custom_hide_cols),
      align = Filter(length, list(
        left = parse_name_list(input$custom_align_left),
        center = parse_name_list(input$custom_align_center),
        right = parse_name_list(input$custom_align_right)
      )),
      bold_cols = parse_name_list(input$custom_bold_cols),
      italic_cols = parse_name_list(input$custom_italic_cols)
    )
  })
  customised_result <- reactiveVal(NULL)
  observeEvent(table_result(), {
    customised_result(NULL)
  }, ignoreInit = TRUE)
  observeEvent(input$run_customise, {
    req(!is.null(initial_clicks$customise),
      (input$run_customise %||% 0) > initial_clicks$customise)
    settings <- tryCatch(custom_settings(), error = function(error) error)
    if (inherits(settings, "error")) {
      validate(need(FALSE, conditionMessage(settings)))
    }
    source <- selected_completed_table()
    customised_result(gtstats::customise_table(
      source,
      engine = "gt",
      theme = input$custom_theme %||% "default",
      title = if (nzchar(input$custom_title %||% "")) input$custom_title else NULL,
      subtitle = if (nzchar(input$custom_subtitle %||% "")) input$custom_subtitle else NULL,
      source_note = if (nzchar(input$custom_source_note %||% "")) input$custom_source_note else NULL,
      col_labels = if (length(settings$col_labels)) settings$col_labels else NULL,
      row_labels = if (length(settings$row_labels)) settings$row_labels else NULL,
      level_labels = if (length(settings$level_labels)) settings$level_labels else NULL,
      hide_cols = if (length(settings$hide_cols)) settings$hide_cols else NULL,
      align = if (length(settings$align)) settings$align else NULL,
      bold_cols = if (length(settings$bold_cols)) settings$bold_cols else NULL,
      italic_cols = if (length(settings$italic_cols)) settings$italic_cols else NULL,
      font_size = input$custom_font_size %||% 14,
      font = if (nzchar(input$custom_font %||% "")) input$custom_font else NULL,
      width = input$custom_width %||% 100,
      row_striping = isTRUE(input$custom_striping),
      accent_color = if (nzchar(input$custom_accent_color %||% "")) input$custom_accent_color else NULL,
      stripe_color = if (nzchar(input$custom_stripe_color %||% "")) input$custom_stripe_color else NULL,
      bold_labels = isTRUE(input$custom_bold_labels),
      show_footnotes = isTRUE(input$custom_footnotes),
      spanning_header = if (nzchar(input$custom_spanning_header %||% "")) input$custom_spanning_header else NULL,
      footnotes = {
        notes <- trimws(unlist(strsplit(input$custom_footnote_text %||% "", "\n", fixed = TRUE)))
        notes[nzchar(notes)]
      },
      borders = input$custom_borders %||% "horizontal",
      density = input$custom_density %||% "standard",
      pvalue_style = input$custom_pvalue_style %||% "threshold",
      pvalue_digits = input$custom_pvalue_digits %||% 3L,
      pvalue_threshold = input$custom_pvalue_threshold %||% 0.001,
      pvalue_prefix = isTRUE(input$custom_pvalue_prefix)
    ))
  }, ignoreInit = TRUE)
  customised_display_result <- reactive({
    customised_result() %||% table_result()
  })
  output$custom_preview_message <- renderUI({
    if (is.null(table_result())) return(NULL)
    if (is.null(customised_result())) {
      tags$p(class = "help-copy", "This is the current Summary table. Change the controls and click Apply table changes to create a customised copy.")
    } else {
      tags$p(class = "help-copy", "Customisation applied. The underlying Summary-table statistics are unchanged.")
    }
  })
  output$customised_table <- render_result(customised_display_result)
  download_result(output, "customised", customised_display_result)
  customised_code <- reactive({
    settings <- tryCatch(custom_settings(), error = function(error) NULL)
    settings <- settings %||% list(
      col_labels = character(), row_labels = character(),
      level_labels = character(), hide_cols = character(), align = list(),
      bold_cols = character(), italic_cols = character()
    )
    arguments <- c(
      paste0('  theme = "', input$custom_theme %||% "default", '"'),
      if (nzchar(input$custom_title %||% "")) paste0("  title = ", sprintf('"%s"', input$custom_title)) else character(),
      if (nzchar(input$custom_subtitle %||% "")) paste0("  subtitle = ", sprintf('"%s"', input$custom_subtitle)) else character(),
      if (nzchar(input$custom_spanning_header %||% "")) paste0("  spanning_header = ", sprintf('"%s"', input$custom_spanning_header)) else character(),
      if (nzchar(input$custom_source_note %||% "")) paste0("  source_note = ", sprintf('"%s"', input$custom_source_note)) else character(),
      {
        notes <- trimws(unlist(strsplit(input$custom_footnote_text %||% "", "\n", fixed = TRUE)))
        notes <- notes[nzchar(notes)]
        if (length(notes)) paste0("  footnotes = ", code_vector(notes)) else character()
      },
      if (length(settings$col_labels)) paste0("  col_labels = ", code_named_vector(settings$col_labels)) else character(),
      if (length(settings$row_labels)) paste0("  row_labels = ", code_named_vector(settings$row_labels)) else character(),
      if (length(settings$level_labels)) paste0("  level_labels = ", code_named_vector(settings$level_labels)) else character(),
      if (length(settings$hide_cols)) paste0("  hide_cols = ", code_vector(settings$hide_cols)) else character(),
      if (length(settings$align)) paste0("  align = list(", paste(
        paste0(names(settings$align), " = ", vapply(settings$align, code_vector, character(1))),
        collapse = ", "
      ), ")") else character(),
      if (length(settings$bold_cols)) paste0("  bold_cols = ", code_vector(settings$bold_cols)) else character(),
      if (length(settings$italic_cols)) paste0("  italic_cols = ", code_vector(settings$italic_cols)) else character(),
      paste0("  font_size = ", input$custom_font_size %||% 14),
      if (nzchar(input$custom_font %||% "")) paste0("  font = ", sprintf('"%s"', input$custom_font)) else character(),
      paste0("  width = ", input$custom_width %||% 100),
      if (nzchar(input$custom_accent_color %||% "")) paste0("  accent_color = ", sprintf('"%s"', input$custom_accent_color)) else character(),
      if (nzchar(input$custom_stripe_color %||% "")) paste0("  stripe_color = ", sprintf('"%s"', input$custom_stripe_color)) else character(),
      paste0('  borders = "', input$custom_borders %||% "horizontal", '"'),
      paste0('  density = "', input$custom_density %||% "standard", '"'),
      paste0('  pvalue_style = "', input$custom_pvalue_style %||% "threshold", '"'),
      paste0("  pvalue_digits = ", input$custom_pvalue_digits %||% 3L),
      paste0("  pvalue_threshold = ", input$custom_pvalue_threshold %||% 0.001),
      paste0("  pvalue_prefix = ", if (isTRUE(input$custom_pvalue_prefix)) "TRUE" else "FALSE"),
      paste0("  row_striping = ", if (isTRUE(input$custom_striping)) "TRUE" else "FALSE"),
      paste0("  bold_labels = ", if (isTRUE(input$custom_bold_labels)) "TRUE" else "FALSE"),
      paste0("  show_footnotes = ", if (isTRUE(input$custom_footnotes)) "TRUE" else "FALSE")
    )
    paste0(
      "completed_table <- ", completed_table_code(), "\n\n",
      "customised_table <- customise_table(\n  completed_table,\n",
      paste(arguments, collapse = ",\n"), "\n)"
    )
  })
  output$customised_code <- renderText(customised_code())
  download_code(output, "customised_code", customised_code)

  observeEvent(input$run_describe, {
    updateTabsetPanel(session, "understand_results_tab", selected = "Overview")
    record_history("Describe data", "Dataset overview", isolate("describe_data(data)"))
  }, ignoreInit = TRUE)
  observeEvent(input$run_distribution, {
    updateTabsetPanel(session, "understand_results_tab", selected = "Distribution")
    distribution_code <- isolate({
      group <- input$diagnostic_group %||% ""
      code <- paste0("assess_distribution(data, vars = ", code_vector(input$diagnostic_vars), if (nzchar(group)) paste0(", by = ", group) else "", ")")
      if (isTRUE(input$show_variance) && nzchar(group)) {
        code <- paste0(
          code, "\n\nassess_variance(data, vars = ",
          code_vector(input$diagnostic_vars), ", by = ", group,
          if (!identical(input$variance_test %||% "levene", "levene")) {
            paste0(', test = "', input$variance_test, '"')
          } else "",
          ")"
        )
      }
      code
    })
    record_history("Assess distribution", paste(length(input$diagnostic_vars), "variable(s)"), distribution_code)
  }, ignoreInit = TRUE)
  observeEvent(input$run_table, {
    record_history("Summary table", paste(length(input$table_vars), "variable(s)"), isolate(summary_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$run_compare, {
    record_history("Compare groups", paste(input$compare_variable, "by", input$compare_group), isolate(comparison_full_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$run_correlation, {
    details <- if (identical(input$correlation_mode, "matrix")) {
      paste(length(input$correlation_vars %||% character()), "variable matrix")
    } else {
      paste(input$correlation_x, "with", input$correlation_y)
    }
    record_history("Correlation", details, isolate(correlation_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$run_cross, {
    record_history("Crosstab", paste(input$cross_row, "by", input$cross_col), isolate(crosstab_code()))
  }, ignoreInit = TRUE)
  observeEvent(input$run_customise, {
    req(!is.null(customised_result()))
    record_history("Customise table", "Summary table", isolate(customised_code()))
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
  output$session_code <- renderText(complete_script())
  download_code(output, "session_code", complete_script)
}

shinyApp(ui, server)
