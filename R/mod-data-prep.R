# Internal Shiny module for safe, reversible data preparation.

mod_data_prep_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::tags$style(shiny::HTML(".gtx-prep-toolbar .nav { border-bottom: 1px solid #D9D9D4; margin-bottom: 0; display: flex; flex-wrap: wrap; gap: 2px; } .gtx-prep-toolbar .nav > li { float: none; } .gtx-prep-toolbar .nav > li > a { font-weight: 750; padding: 9px 13px; color:#3D3D39; border-radius: 7px 7px 0 0; } .gtx-prep-toolbar .nav > li > a:hover, .gtx-prep-toolbar .nav > li > a:focus { background:#ECECEA; color:#111111; } .gtx-prep-templates { margin-top: 12px; padding: 10px 12px; border-radius: 8px; background: #F7F7F5; border: 1px solid #E3E3DE; } .gtx-prep-templates strong { margin-right: 8px; } .gtx-prep-templates .btn { margin: 3px 5px 3px 0; } .gtx-prep-actions .btn { margin-right: 7px; margin-bottom: 8px; } .gtx-prep-apply { margin-top: 18px; padding-top: 14px; border-top: 1px solid #E3E3DE; } .gtx-value-guide { margin-top: 12px; padding: 11px 13px; border: 1px solid #D9D9D4; border-radius: 8px; background: #FAFAF8; } .gtx-value-guide h5 { margin: 0 0 6px; font-weight: 750; } .gtx-value-guide pre { white-space: pre-wrap; margin: 8px 0 0; padding: 8px; font-size: .9em; } .gtx-recode-map { margin-top: 14px; padding: 12px; border: 1px solid #D9D9D4; border-radius: 8px; background: #FDFDFC; } .gtx-recode-map h4 { margin: 0 0 4px; } .gtx-impact-table { width: 100%; margin-top: 8px; font-size: .92em; background: #fff; } .gtx-impact-table th, .gtx-impact-table td { padding: 7px 8px; border-bottom: 1px solid #E3E3DE; text-align: left; vertical-align: middle; } .gtx-impact-table th { font-weight: 750; color: #3D3D39; background: #F5F5F2; } .gtx-impact-table .form-group { margin-bottom: 0; } .gtx-impact-table .form-control { min-width: 170px; } @media (max-width: 767px) { .gtx-prep-toolbar .nav > li > a { padding: 8px 9px; font-size: .88em; } .gtx-impact-table { font-size: .85em; } .gtx-impact-table .form-control { min-width: 120px; } }")),
    shiny::div(class = "gtx-card",
      shiny::tags$h3("Data Prep"),
      shiny::tags$p(class = "help-copy", "Choose one clear task below. Each change is made to a working copy, can be undone, and becomes reproducible R code."),
      shiny::div(class = "gtx-prep-toolbar",
        shiny::tags$ul(class = "nav nav-pills",
          shiny::tags$li(shiny::actionLink(ns("menu_rename"), "Rename variable")),
          shiny::tags$li(shiny::actionLink(ns("menu_recode"), "Recode values")),
          shiny::tags$li(shiny::actionLink(ns("menu_type"), "Set type & order")),
          shiny::tags$li(shiny::actionLink(ns("menu_missing"), "Manage missing values")),
          shiny::tags$li(shiny::actionLink(ns("menu_calculation"), "Create calculation")),
          shiny::tags$li(shiny::actionLink(ns("menu_groups"), "Create groups")),
          shiny::tags$li(shiny::actionLink(ns("menu_filter"), "Filter observations")),
          shiny::tags$li(shiny::actionLink(ns("menu_keep"), "Keep variables"))
        )
      ),
      shiny::div(class = "gtx-prep-templates",
        shiny::tags$strong("Quick starts:"),
        shiny::actionButton(ns("template_age"), "Age groups", class = "btn-default btn-sm"),
        shiny::actionButton(ns("template_binary"), "0/1 to No/Yes", class = "btn-default btn-sm"),
        shiny::actionButton(ns("template_bmi"), "BMI-style calculation", class = "btn-default btn-sm"),
        shiny::actionButton(ns("template_missing"), "99/999 to missing", class = "btn-default btn-sm"),
        shiny::tags$span(class = "help-copy", "They fill a starting point only; review before applying.")
      )
    ),
    shiny::fluidRow(
      shiny::column(4, shiny::div(class = "cardish",
        shiny::tags$h4("Set up this change"), shiny::uiOutput(ns("operation_hint")), shiny::uiOutput(ns("controls")), shiny::uiOutput(ns("impact_preview")), shiny::uiOutput(ns("value_guide")),
        shiny::div(class = "gtx-prep-apply", shiny::tags$p(class = "help-copy", "Review the preview, then apply this one change."), shiny::actionButton(ns("apply"), "Apply this change", class = "btn-primary"))
      )),
      shiny::column(8, shiny::div(class = "gtx-card",
        shiny::tags$div(class = "card-heading", shiny::tags$h4("Working-data preview"), shiny::textOutput(ns("status"))),
        gt::gt_output(ns("preview"))
      ))
    ),
    shiny::div(class = "gtx-card gtx-prep-actions",
      shiny::tags$h4("Change controls"),
      shiny::actionButton(ns("undo"), "Undo last change"),
      shiny::actionButton(ns("redo"), "Redo"),
      shiny::actionButton(ns("reset"), "Reset all"),
      shiny::tags$hr(),
      shiny::tags$strong("Choose the data for analysis: "),
      shiny::actionButton(ns("continue_original"), "Use original data"),
      shiny::actionButton(ns("use_prepared"), "Use prepared data", class = "btn-success"),
      shiny::tags$hr(),
      shiny::tags$strong("Download the prepared data: "),
      shiny::selectInput(ns("prepared_format"), NULL, choices = c("CSV" = "csv", "Excel (.xlsx)" = "xlsx", "R data (.rds)" = "rds", "Stata (.dta)" = "dta"), selected = "csv", width = "160px"),
      shiny::downloadButton(ns("download_prepared"), "Download prepared data")
    ),
    shiny::tabsetPanel(type = "tabs",
      shiny::tabPanel("Change log", shiny::div(class = "gtx-card", shiny::verbatimTextOutput(ns("history")))),
      shiny::tabPanel("Reusable code", shiny::div(class = "gtx-card", shiny::tags$div(class = "card-heading", shiny::tags$h4("Copy this into RStudio"),
        shiny::tags$button(type = "button", class = "btn btn-default copy-code", `data-copy-target` = ns("code"), "Copy code"),
        shiny::downloadButton(ns("download_code"), "Download .R")), shiny::verbatimTextOutput(ns("code"))))
    )
  )
}

mod_data_prep_server <- function(id, source_data) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    state <- shiny::reactiveValues(raw_data = NULL, working_data = NULL, history = list(), redo_stack = list(), result = NULL, using_prepared = FALSE)
    shiny::observeEvent(source_data(), {
      state$raw_data <- source_data(); state$working_data <- source_data()
      state$history <- list(); state$redo_stack <- list(); state$result <- NULL; state$using_prepared <- FALSE
    }, ignoreInit = FALSE)
    variables <- shiny::reactive(names(state$working_data %||% data.frame()))
    operation <- shiny::reactiveVal("rename")
    transform_mode <- shiny::reactiveVal("arithmetic")
    choose_operation <- function(selected_operation, mode = NULL) {
      operation(selected_operation)
      if (!is.null(mode)) transform_mode(mode)
    }
    shiny::observeEvent(input$menu_rename, choose_operation("rename"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_recode, choose_operation("recode"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_type, choose_operation("type"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_missing, choose_operation("missing"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_filter, choose_operation("filter"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_keep, choose_operation("keep"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_calculation, choose_operation("transform", "arithmetic"), ignoreInit = TRUE)
    shiny::observeEvent(input$menu_groups, choose_operation("transform", "case_when"), ignoreInit = TRUE)
    numeric_variable <- function(preferred = NULL) {
      data <- state$working_data
      if (is.null(data)) return("")
      candidates <- names(data)[vapply(data, is.numeric, logical(1))]
      if (!length(candidates)) return("")
      if (!is.null(preferred) && preferred %in% candidates) preferred else candidates[[1L]]
    }
    after_controls_render <- function(code) session$onFlushed(code, once = TRUE)
    shiny::observeEvent(input$template_age, {
      variable <- numeric_variable("age")
      if (!nzchar(variable)) return(shiny::showNotification("Age groups needs a numeric variable. Choose Create groups after importing suitable data.", type = "warning"))
      choose_operation("transform", "case_when")
      after_controls_render(function() {
        shiny::updateSelectInput(session, "group_variable", selected = variable)
        shiny::updateRadioButtons(session, "group_count", selected = "2")
        shiny::updateSelectInput(session, "rule_op_1", selected = ">=")
        shiny::updateTextInput(session, "rule_value_1", value = "65")
        shiny::updateTextInput(session, "rule_result_1", value = "65 or older")
        shiny::updateTextInput(session, "rule_default", value = "Under 65")
        shiny::updateTextInput(session, "transform_new", value = paste0(variable, "_group"))
      })
      shiny::showNotification("Age-group starter loaded. Check the cut-off and labels before applying.", type = "message")
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$template_binary, {
      data <- state$working_data
      candidates <- names(data)[vapply(data, function(x) {
        values <- sort(unique(as.character(x[!is.na(x)])))
        identical(values, c("0", "1"))
      }, logical(1))]
      if (!length(candidates)) return(shiny::showNotification("No variable coded exactly 0 and 1 was found. Choose Recode values and select a variable yourself.", type = "warning"))
      choose_operation("recode")
      after_controls_render(function() {
        shiny::updateSelectInput(session, "variable", selected = candidates[[1L]])
        after_controls_render(function() {
          shiny::updateTextInput(session, "recode_to_1", value = "No")
          shiny::updateTextInput(session, "recode_to_2", value = "Yes")
        })
      })
      shiny::showNotification("0/1 recoding starter loaded. Confirm that 0 means No and 1 means Yes before applying.", type = "message")
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$template_bmi, {
      variable <- numeric_variable()
      if (!nzchar(variable)) return(shiny::showNotification("BMI-style calculation needs numeric variables.", type = "warning"))
      choose_operation("transform", "arithmetic")
      after_controls_render(function() {
        shiny::updateRadioButtons(session, "calculation_mode", selected = "ratio_power")
        after_controls_render(function() {
          shiny::updateSelectInput(session, "transform_source", selected = variable)
          shiny::updateNumericInput(session, "transform_number", value = 2)
          shiny::updateTextInput(session, "transform_new", value = "bmi")
        })
      })
      shiny::showNotification("BMI-style starter loaded. Choose weight in kg and height in metres before applying.", type = "message")
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$template_missing, {
      variable <- numeric_variable()
      if (!nzchar(variable)) return(shiny::showNotification("This starter needs a variable that contains recorded missing-data codes.", type = "warning"))
      choose_operation("missing")
      after_controls_render(function() {
        shiny::updateSelectInput(session, "variable", selected = variable)
        shiny::updateRadioButtons(session, "missing_action", selected = "to_na")
        shiny::updateTextInput(session, "codes", value = "99, 999")
      })
      shiny::showNotification("Missing-code starter loaded. Replace 99/999 unless those are genuinely your missing-data codes.", type = "message")
    }, ignoreInit = TRUE)
    output$operation_hint <- shiny::renderUI({
      hint <- switch(operation(),
        rename = shiny::tagList(
          shiny::tags$strong("Give a variable a clearer name."),
          shiny::tags$p(class = "help-copy", "Example: rename `smoke` to `smoking_status`. This changes the column name only; values are unchanged.")
        ),
        recode = shiny::tagList(
          shiny::tags$strong("Give each recorded value a clear label."),
          shiny::tags$p(class = "help-copy", "Each recorded value is shown below with its replacement label. Edit only the labels you want to change; values left unchanged stay as they are.")
        ),
        type = shiny::tagList(
          shiny::tags$strong("Set how a variable is treated in tables and analyses."),
          shiny::tags$p(class = "help-copy", "Use categorical for unordered values such as No/Yes; use ordered categorical for values with a real order, such as None, One, Two or more. The level order is used in tables and charts.")
        ),
        missing = shiny::tagList(
          shiny::tags$strong("Make missingness explicit and reproducible."),
          shiny::tags$p(class = "help-copy", "Convert recorded missing-data codes such as `999` or `Unknown` to R missing values (`NA`). Or, for a categorical variable, show existing NA values as a labelled Missing category for presentation.")
        ),
        transform = shiny::tagList(
          shiny::tags$strong("Create a new variable without changing the source variable."),
          shiny::tags$p(class = "help-copy", "Create calculations such as BMI or unit conversions, or use Create groups for age bands, BMI categories, and risk groups. The source variable is always retained.")
        ),
        filter = shiny::tagList(
          shiny::tags$strong("Keep only records meeting your eligibility criteria."),
          shiny::tags$p(class = "help-copy", "Example: age is at least 18 AND consent equals Yes. Always check the included, excluded, and unknown counts before continuing.")
        ),
        keep = shiny::tagList(
          shiny::tags$strong("Make a smaller analysis dataset without deleting the original import."),
          shiny::tags$p(class = "help-copy", "Tick the variables needed for your analysis. You can Undo this change at any time.")
        )
      )
      shiny::tags$div(class = "gtx-step", hint)
    })
    output$controls <- shiny::renderUI({
      ns <- session$ns; vars <- variables(); shiny::req(length(vars))
      if (identical(operation(), "rename")) shiny::tagList(
        shiny::selectInput(ns("variable"), "Existing variable", vars), shiny::textInput(ns("new_name"), "New variable name")
      ) else if (identical(operation(), "recode")) shiny::tagList(
        shiny::selectInput(ns("variable"), "Variable", vars),
        shiny::uiOutput(ns("recode_mapping")),
        shiny::checkboxInput(ns("recode_ordered"), "Treat as ordered categorical, in the order shown", FALSE),
        shiny::tags$p(class = "help-copy", "The recoded variable is categorical. Tick this only when the displayed order has a genuine meaning, such as None, Mild, Moderate, Severe.")
      ) else if (identical(operation(), "type")) shiny::tagList(
        shiny::selectInput(ns("variable"), "Variable", vars),
        shiny::selectInput(ns("variable_type"), "Treat this variable as", c("Categorical" = "factor", "Ordered categorical" = "ordered", "Numeric" = "numeric", "Text" = "text")),
        shiny::uiOutput(ns("type_order_grid"))
      ) else if (identical(operation(), "missing")) shiny::tagList(
        shiny::selectInput(ns("variable"), "Variable", vars),
        shiny::radioButtons(ns("missing_action"), "What do you want to do?", c("Convert recorded codes to missing (NA)" = "to_na", "Show existing missing values as a category" = "show_category"), selected = "to_na"),
        shiny::uiOutput(ns("missing_controls"))
      ) else if (identical(operation(), "transform")) {
        mode <- transform_mode()
        numeric_vars <- vars[vapply(state$working_data[vars], is.numeric, logical(1))]
        operators <- c("equal to" = "==", "not equal to" = "!=", "greater than" = ">", "greater than or equal to" = ">=", "less than" = "<", "less than or equal to" = "<=")
        if (identical(mode, "arithmetic") && !length(numeric_vars)) shiny::tags$div(class = "gtx-note", "Create calculation needs at least one numeric variable. Use Create groups to make categories from recorded values.")
        else if (identical(mode, "arithmetic")) shiny::tagList(
          shiny::tags$strong("Create a new numeric variable."),
          shiny::tags$p(class = "help-copy", "Choose a common calculation pattern. Your original variables are always retained."),
          shiny::radioButtons(ns("calculation_mode"), "Calculation type", c("Adjust one variable" = "single", "Combine two variables" = "two_variables", "Divide by another variable raised to a power" = "ratio_power"), selected = "single"),
          shiny::uiOutput(ns("calculation_controls"))
        ) else shiny::tagList(
          shiny::tags$strong("Create a new grouped variable."),
          shiny::tags$p(class = "help-copy", "Choose one source variable, decide how many groups you need, then give each group a clear label. Groups are checked from top to bottom; the first matching condition wins."),
          shiny::selectInput(ns("group_variable"), "Variable to group", vars),
          shiny::radioButtons(ns("group_count"), "How many groups?", c("Two groups" = "2", "Three groups" = "3", "Four groups" = "4"), selected = "2", inline = TRUE),
          shiny::uiOutput(ns("group_rules")),
          shiny::textInput(ns("transform_new"), "Name for the new grouped variable", placeholder = "Example: age_group")
        )
      } else if (identical(operation(), "keep")) shiny::tagList(
        shiny::tags$strong("Choose the variables for your analysis dataset."),
        shiny::tags$p(class = "help-copy", "Start with all variables, remove those you do not need, and search by name when your dataset is large. This does not change the original imported data."),
        shiny::div(class = "gtx-prep-actions",
          shiny::actionButton(ns("keep_all"), "Keep all variables", class = "btn-default btn-sm"),
          shiny::actionButton(ns("keep_none"), "Clear selection", class = "btn-default btn-sm")
        ),
        shiny::selectizeInput(ns("keep_vars"), "Variables to keep", choices = vars, selected = vars, multiple = TRUE, options = list(placeholder = "Search and select variables"))
      ) else shiny::tagList(
        shiny::tags$strong("Keep observations that meet your inclusion criteria."),
        shiny::tags$p(class = "help-copy", "Start with one condition. Add a second only when needed. The preview shows exactly how many records will be kept, excluded, or have an unknown result because of missing data."),
        shiny::uiOutput(ns("filter_conditions"))
      )
    })
    recode_values <- shiny::reactive({
      variable <- input$variable %||% ""
      data <- state$working_data
      if (!nzchar(variable) || is.null(data) || !variable %in% names(data)) return(character())
      unique(as.character(data[[variable]][!is.na(data[[variable]])]))
    })
    output$recode_mapping <- shiny::renderUI({
      values <- recode_values()
      if (!length(values)) return(shiny::tags$p(class = "help-copy", "This variable has no observed values to recode."))
      rows <- lapply(seq_along(values), function(index) {
        shiny::tags$tr(
          shiny::tags$td(shiny::tags$code(values[[index]])),
          shiny::tags$td(shiny::textInput(ns(paste0("recode_to_", index)), NULL, value = values[[index]]))
        )
      })
      shiny::tags$div(class = "gtx-recode-map",
        shiny::tags$h4("Value mapping"),
        shiny::tags$p(class = "help-copy", "Change the label beside each recorded value. The left column is read-only."),
        shiny::tags$table(class = "gtx-impact-table",
          shiny::tags$thead(shiny::tags$tr(shiny::tags$th("Recorded value"), shiny::tags$th("New label"))),
          shiny::tags$tbody(rows)
        )
      )
    })
    recode_labels <- shiny::reactive({
      values <- recode_values()
      if (!length(values)) return(character())
      vapply(seq_along(values), function(index) {
        input[[paste0("recode_to_", index)]] %||% values[[index]]
      }, character(1))
    })
    type_order_values <- shiny::reactive({
      variable <- input$variable %||% ""
      data <- state$working_data
      if (!nzchar(variable) || is.null(data) || !variable %in% names(data)) return(character())
      unique(as.character(data[[variable]][!is.na(data[[variable]])]))
    })
    output$type_order_grid <- shiny::renderUI({
      variable_type <- input$variable_type %||% "factor"
      if (identical(variable_type, "factor")) {
        return(shiny::tags$p(class = "help-copy", "Categorical treats values as separate groups with no meaningful order. Their current display order is retained."))
      }
      if (!identical(variable_type, "ordered")) {
        return(shiny::tags$p(class = "help-copy", "Numeric converts recorded values to numbers where possible. Text keeps labels as plain text."))
      }
      values <- type_order_values()
      if (!length(values)) return(shiny::tags$p(class = "help-copy", "This variable has no observed values to order."))
      ranks <- stats::setNames(seq_along(values), paste0(seq_along(values), ifelse(seq_along(values) == 1L, " (first)", "")))
      rows <- lapply(seq_along(values), function(index) {
        shiny::tags$tr(
          shiny::tags$td(shiny::tags$code(values[[index]])),
          shiny::tags$td(shiny::selectInput(ns(paste0("type_rank_", index)), NULL, choices = ranks, selected = index))
        )
      })
      shiny::tags$div(class = "gtx-recode-map",
        shiny::tags$h4("Display order"),
        shiny::tags$p(class = "help-copy", "Give each recorded value a different position. The default keeps the current order. This controls the order in tables and charts."),
        shiny::tags$table(class = "gtx-impact-table",
          shiny::tags$thead(shiny::tags$tr(shiny::tags$th("Recorded value"), shiny::tags$th("Position"))),
          shiny::tags$tbody(rows)
        )
      )
    })
    type_levels <- shiny::reactive({
      values <- type_order_values()
      if (!length(values)) return(character())
      ranks <- vapply(seq_along(values), function(index) {
        suppressWarnings(as.integer(input[[paste0("type_rank_", index)]] %||% index))
      }, integer(1))
      if (anyNA(ranks) || anyDuplicated(ranks) || !setequal(ranks, seq_along(values))) {
        stop("Give every recorded value a different display position.", call. = FALSE)
      }
      values[order(ranks)]
    })
    output$missing_controls <- shiny::renderUI({
      if (identical(input$missing_action %||% "to_na", "show_category")) {
        shiny::tagList(
          shiny::textInput(ns("missing_label"), "Label to show for missing values", value = "Missing"),
          shiny::tags$p(class = "help-copy", "This creates a categorical level for existing NA values. Use it only when showing missingness as a table category is appropriate; it changes how the variable is analysed.")
        )
      } else {
        shiny::tagList(
          shiny::textInput(ns("codes"), "Recorded codes to convert to missing", placeholder = "Example: 999, Unknown, N/A"),
          shiny::tags$p(class = "help-copy", "Use this only for codes that truly mean no value was recorded. R uses NA to represent missing data.")
        )
      }
    })
    output$group_rules <- shiny::renderUI({
      count <- suppressWarnings(as.integer(input$group_count %||% 2L))
      count <- if (count %in% 2:4) count else 2L
      operators <- c("is equal to" = "==", "is not equal to" = "!=", "is greater than" = ">", "is at least" = ">=", "is less than" = "<", "is at most" = "<=", "is between (inclusive)" = "between", "is outside a range" = "outside")
      rule_rows <- lapply(seq_len(count - 1L), function(index) {
        operator_id <- ns(paste0("rule_op_", index))
        shiny::tags$div(class = "gtx-step",
          shiny::tags$strong(paste("Group", index)),
          shiny::selectInput(ns(paste0("rule_op_", index)), "Include values that", operators),
          shiny::textInput(ns(paste0("rule_value_", index)), "Value or lower bound", placeholder = if (index == 1L) "Example: 65" else "Example: 25"),
          shiny::conditionalPanel(
            condition = paste0("input['", operator_id, "'] === 'between' || input['", operator_id, "'] === 'outside'"),
            shiny::textInput(ns(paste0("rule_value2_", index)), "Upper bound", placeholder = "Example: 65")
          ),
          shiny::textInput(ns(paste0("rule_result_", index)), "Group label", placeholder = if (index == 1L) "Example: Older adult" else "Example: Adult")
        )
      })
      shiny::tagList(
        rule_rows,
        shiny::tags$div(class = "gtx-step",
          shiny::tags$strong(paste("Group", count, "(everyone else)")),
          shiny::textInput(ns("rule_default"), "Group label", placeholder = "Example: Younger adult")
        )
      )
    })
    output$filter_conditions <- shiny::renderUI({
      operators <- c("is equal to" = "==", "is not equal to" = "!=", "is greater than" = ">", "is at least" = ">=", "is less than" = "<", "is at most" = "<=")
      vars <- variables()
      shiny::tagList(
        shiny::tags$div(class = "gtx-step",
          shiny::tags$strong("Condition 1"),
          shiny::selectInput(ns("variable1"), "Variable", vars),
          shiny::selectInput(ns("operator1"), "Keep when", operators),
          shiny::textInput(ns("value1"), "Value", placeholder = "Example: 18")
        ),
        shiny::checkboxInput(ns("filter_second"), "Add another condition", FALSE),
        shiny::uiOutput(ns("filter_second_condition"))
      )
    })
    shiny::observeEvent(input$keep_all, {
      shiny::updateSelectizeInput(session, "keep_vars", selected = variables(), server = TRUE)
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$keep_none, {
      shiny::updateSelectizeInput(session, "keep_vars", selected = character(), server = TRUE)
    }, ignoreInit = TRUE)
    output$filter_second_condition <- shiny::renderUI({
      if (!isTRUE(input$filter_second)) return(NULL)
      operators <- c("is equal to" = "==", "is not equal to" = "!=", "is greater than" = ">", "is at least" = ">=", "is less than" = "<", "is at most" = "<=")
      shiny::tags$div(class = "gtx-step",
        shiny::tags$strong("Condition 2"),
        shiny::radioButtons(ns("connector"), "Keep records meeting", c("Both conditions" = "AND", "Either condition" = "OR"), selected = "AND", inline = TRUE),
        shiny::selectInput(ns("variable2"), "Variable", variables()),
        shiny::selectInput(ns("operator2"), "Keep when", operators),
        shiny::textInput(ns("value2"), "Value", placeholder = "Example: Yes")
      )
    })
    output$calculation_controls <- shiny::renderUI({
      numeric_vars <- variables()[vapply(state$working_data[variables()], is.numeric, logical(1))]
      mode <- input$calculation_mode %||% "single"
      if (!length(numeric_vars)) return(shiny::tags$p(class = "help-copy", "No numeric variables are available."))
      if (identical(mode, "single")) return(shiny::tagList(
        shiny::selectInput(ns("transform_source"), "Numeric variable", numeric_vars),
        shiny::selectInput(ns("transform_operator"), "Calculation", c("Add a number" = "+", "Subtract a number" = "-", "Multiply by a number" = "*", "Divide by a number" = "/", "Raise to a power" = "^")),
        shiny::numericInput(ns("transform_number"), "Number", 1),
        shiny::textInput(ns("transform_new"), "Name for the new variable", placeholder = "Example: weight_kg")
      ))
      if (identical(mode, "two_variables")) return(shiny::tagList(
        shiny::selectInput(ns("transform_source"), "First numeric variable", numeric_vars),
        shiny::selectInput(ns("transform_operator"), "Calculation", c("Add" = "+", "Subtract second from first" = "-", "Multiply" = "*", "Divide first by second" = "/")),
        shiny::selectInput(ns("transform_second"), "Second numeric variable", numeric_vars),
        shiny::textInput(ns("transform_new"), "Name for the new variable", placeholder = "Example: total_score")
      ))
      shiny::tagList(
        shiny::selectInput(ns("transform_source"), "Numerator variable", numeric_vars),
        shiny::selectInput(ns("transform_second"), "Denominator variable", numeric_vars),
        shiny::numericInput(ns("transform_number"), "Denominator power", 2),
        shiny::tags$p(class = "help-copy", "This calculates numerator / (denominator ^ power). For BMI, use weight in kg divided by height in metres with power 2."),
        shiny::textInput(ns("transform_new"), "Name for the new variable", placeholder = "Example: bmi")
      )
    })
    selected_variable <- shiny::reactive({
      if (operation() %in% c("recode", "type", "missing")) return(input$variable %||% "")
      if (identical(operation(), "transform")) {
        if (identical(transform_mode(), "arithmetic")) return(input$transform_source %||% "")
        return(input$group_variable %||% "")
      }
      if (identical(operation(), "filter")) return(input$variable1 %||% "")
      ""
    })
    output$value_guide <- shiny::renderUI({
      variable <- selected_variable()
      data <- state$working_data
      shiny::req(!is.null(data), nzchar(variable), variable %in% names(data))
      x <- data[[variable]]
      missing <- sum(is.na(x))
      is_categorical <- is.factor(x) || is.character(x) || is.logical(x)
      if (is_categorical) {
        values <- unique(as.character(x[!is.na(x)]))
        shown <- utils::head(values, 40L)
        suffix <- if (length(values) > length(shown)) paste0("\n... plus ", length(values) - length(shown), " more value(s)") else ""
        value_text <- paste0(paste(shown, collapse = ", "), suffix)
        shiny::tags$div(class = "gtx-value-guide",
          shiny::tags$h5("Recorded values"),
          shiny::tags$p(class = "help-copy", paste0("Exact non-missing values in `", variable, "` (", length(values), " unique; ", missing, " missing). Use these spellings when recoding or filtering.")),
          shiny::tags$button(type = "button", class = "btn btn-default btn-xs copy-code", `data-copy-target` = ns("values_to_copy"), "Copy values"),
          shiny::tags$pre(id = ns("values_to_copy"), value_text)
        )
      } else if (is.numeric(x)) {
        observed <- x[is.finite(x)]
        if (!length(observed)) return(shiny::tags$div(class = "gtx-value-guide", shiny::tags$h5("Numeric variable"), "No finite observed values are available."))
        unique_values <- sort(unique(observed))
        details <- paste0("Range: ", format(min(observed), trim = TRUE), " to ", format(max(observed), trim = TRUE), "; ", length(unique_values), " unique; ", missing, " missing.")
        if (length(unique_values) <= 12L) details <- paste0(details, " Recorded values: ", paste(unique_values, collapse = ", "), ".")
        shiny::tags$div(class = "gtx-value-guide", shiny::tags$h5("Numeric variable guide"), shiny::tags$p(class = "help-copy", details))
      } else {
        shiny::tags$div(class = "gtx-value-guide", shiny::tags$h5("Selected variable"), shiny::tags$p(class = "help-copy", paste0("Class: ", paste(class(x), collapse = ", "), "; ", missing, " missing value(s).")))
      }
    })
    impact_table <- function(headers, rows) {
      shiny::tags$table(class = "gtx-impact-table",
        shiny::tags$thead(shiny::tags$tr(lapply(headers, shiny::tags$th))),
        shiny::tags$tbody(lapply(rows, function(row) shiny::tags$tr(lapply(row, shiny::tags$td))))
      )
    }
    output$impact_preview <- shiny::renderUI({
      data <- state$working_data
      shiny::req(!is.null(data))
      content <- tryCatch({
        if (identical(operation(), "rename")) {
          if (!nzchar(input$new_name %||% "")) return(NULL)
          list(message = "Values will not change; only the column name will change.")
        } else if (identical(operation(), "recode")) {
          from <- recode_values()
          if (!length(from) || !nzchar(input$variable %||% "")) return(NULL)
          affected <- sum(as.character(data[[input$variable]]) %in% from, na.rm = TRUE)
          to <- recode_labels()
          if (any(!nzchar(to))) return(list(message = "Enter a new label for every displayed recorded value."))
          counts <- vapply(from, function(value) sum(as.character(data[[input$variable]]) %in% value, na.rm = TRUE), numeric(1))
          changed <- sum(counts[from != to])
          type_note <- if (isTRUE(input$recode_ordered)) " It will be an ordered categorical variable in the displayed order." else " It will be a categorical variable."
          list(message = paste0(changed, " cell(s) will receive a new label.", type_note), table = impact_table(c("Recorded value", "New label", "Affected rows"), Map(function(a, b, n) list(a, b, format(n, trim = TRUE)), from, to, counts)))
        } else if (identical(operation(), "type")) {
          if (!nzchar(input$variable %||% "")) return(NULL)
          list(message = paste0("All values will be retained. The variable will be treated as ", switch(input$variable_type %||% "factor", factor = "categorical", ordered = "ordered categorical", numeric = "numeric", text = "text"), "."))
        } else if (identical(operation(), "missing")) {
          if (identical(input$missing_action %||% "to_na", "show_category")) {
            if (!nzchar(input$variable %||% "")) return(NULL)
            affected <- sum(is.na(data[[input$variable]]))
            label <- trimws(input$missing_label %||% "")
            if (!nzchar(label)) return(list(message = "Enter a label to preview the missing category."))
            return(list(message = paste0(affected, " existing NA value(s) will be shown as the category ", encodeString(label, quote = '"'), ". This changes how the variable is analysed."), table = impact_table(c("Current value", "New category", "Affected rows"), list(list("NA (missing)", label, format(affected, trim = TRUE))))))
          }
          codes <- trimws(strsplit(input$codes %||% "", ",", fixed = TRUE)[[1L]])
          codes <- codes[nzchar(codes)]
          if (!length(codes) || !nzchar(input$variable %||% "")) return(NULL)
          affected <- sum(!is.na(data[[input$variable]]) & as.character(data[[input$variable]]) %in% codes)
          rows <- lapply(codes, function(code) {
            list(code, format(sum(!is.na(data[[input$variable]]) & as.character(data[[input$variable]]) %in% code), trim = TRUE))
          })
          list(message = paste0(affected, " value(s) will become missing (NA)."), table = impact_table(c("Code", "Values becoming missing"), rows))
        } else if (identical(operation(), "transform") && identical(transform_mode(), "arithmetic")) {
          if (!nzchar(input$transform_source %||% "")) return(NULL)
          mode <- input$calculation_mode %||% "single"
          second <- input$transform_second %||% ""
          count <- if (identical(mode, "single")) sum(!is.na(data[[input$transform_source]])) else if (second %in% names(data)) sum(!is.na(data[[input$transform_source]]) & !is.na(data[[second]])) else 0L
          description <- switch(mode, single = "The source variable will be retained.", two_variables = "Both source variables will be retained.", ratio_power = "This uses numerator / (denominator ^ power); both source variables will be retained.")
          list(message = paste0("A new variable will be created with ", count, " non-missing calculated value(s). ", description))
        } else if (identical(operation(), "filter")) {
          if (!nzchar(input$value1 %||% "") || !nzchar(input$variable1 %||% "")) return(NULL)
          variable2 <- if (isTRUE(input$filter_second)) input$variable2 %||% "" else ""
          value2 <- if (isTRUE(input$filter_second)) input$value2 %||% "" else ""
          filtered <- gt_dp_filter(data, input$variable1, input$operator1, input$value1, input$connector %||% "AND", variable2, input$operator2 %||% "==", value2)
          counts <- attr(filtered, "gt_dp_filter_counts")
          list(message = "Check the expected filter result before applying.", table = impact_table(c("Result", "Rows"), list(list("Kept", format(counts[["included"]], trim = TRUE)), list("Excluded", format(counts[["excluded"]], trim = TRUE)), list("Unknown", format(counts[["unknown"]], trim = TRUE)), list("Total", format(counts[["before"]], trim = TRUE)))))
        } else if (identical(operation(), "keep")) {
          selected <- input$keep_vars %||% character()
          if (!length(selected)) return(NULL)
          list(message = paste0(length(selected), " of ", ncol(data), " variable(s) will be retained; ", ncol(data) - length(selected), " will be removed from the working dataset."))
        } else if (identical(operation(), "transform")) {
          count <- suppressWarnings(as.integer(input$group_count %||% 2L))
          count <- if (count %in% 2:4) count else 2L
          indices <- seq_len(count - 1L)
          group_variable <- input$group_variable %||% ""
          if (!nzchar(group_variable) || !group_variable %in% names(data)) return(NULL)
          variables <- rep(group_variable, length(indices))
          operators <- vapply(indices, function(index) input[[paste0("rule_op_", index)]] %||% "==", character(1))
          values <- vapply(indices, function(index) input[[paste0("rule_value_", index)]] %||% "", character(1))
          values2 <- vapply(indices, function(index) input[[paste0("rule_value2_", index)]] %||% "", character(1))
          results <- vapply(indices, function(index) input[[paste0("rule_result_", index)]] %||% "", character(1))
          needs_upper <- operators %in% c("between", "outside")
          if (any(!nzchar(values)) || any(!nzchar(results)) || any(needs_upper & !nzchar(values2)) || !nzchar(input$rule_default %||% "")) return(list(message = "Complete every group condition and label, including an upper bound for any range and the everyone-else group, to preview your groups."))
          grouped <- gt_dp_group_values(data, variables, operators, values, values2, results, input$rule_default)
          counts <- grouped$counts
          list(message = paste0("The new ", count, "-group variable uses the first matching condition. Every proposed group has at least one row."), table = impact_table(c("New group", "Rows"), lapply(seq_along(counts), function(index) list(names(counts)[[index]], format(unname(counts[[index]]), trim = TRUE)))))
        }
      }, error = function(e) NULL)
      if (is.null(content)) return(NULL)
      shiny::tags$div(class = "gtx-note", shiny::tags$strong("Before you apply: "), content$message, content$table)
    })
    apply_change <- function(label, after, code) {
      state$history <- c(state$history, list(list(label = label, before = state$working_data, after = after, code = code)))
      state$working_data <- after; state$redo_stack <- list()
    }
    shiny::observeEvent(input$apply, {
      shiny::req(state$working_data)
      tryCatch({
        if (identical(operation(), "rename")) {
          after <- gt_dp_rename(state$working_data, input$variable, input$new_name)
          apply_change(paste("Rename", input$variable, "to", input$new_name), after, gt_dp_code_line("rename", variable = input$variable, new_name = input$new_name))
        } else if (identical(operation(), "recode")) {
          from <- recode_values(); to <- recode_labels()
          if (!length(from) || any(!nzchar(to))) stop("Enter a new label for every displayed recorded value.", call. = FALSE)
          after <- gt_dp_recode(state$working_data, input$variable, from, to, TRUE)
          recoded <- attr(after, "gt_dp_affected")
          code <- gt_dp_code_line("recode", variable = input$variable, from = from, to = to)
          recode_type <- if (isTRUE(input$recode_ordered)) "ordered" else "factor"
          after <- gt_dp_set_type(after, input$variable, recode_type, to)
          final_levels <- base::levels(after[[input$variable]])
          code <- paste(code, gt_dp_code_line("type", variable = input$variable, type = recode_type, levels = final_levels), sep = "\n")
          type_label <- if (identical(recode_type, "ordered")) " as ordered categorical" else " as categorical"
          apply_change(paste0("Recode ", input$variable, " (", recoded, " cells)", type_label), after, code)
        } else if (identical(operation(), "type")) {
          level_values <- if (identical(input$variable_type, "ordered")) type_levels() else character()
          after <- gt_dp_set_type(state$working_data, input$variable, input$variable_type, level_values)
          final_levels <- if (input$variable_type %in% c("factor", "ordered")) base::levels(after[[input$variable]]) else character()
          apply_change(paste("Set", input$variable, "as", switch(input$variable_type, factor = "categorical", ordered = "ordered categorical", numeric = "numeric", text = "text")), after, gt_dp_code_line("type", variable = input$variable, type = input$variable_type, levels = final_levels))
        } else if (identical(operation(), "missing")) {
          if (identical(input$missing_action %||% "to_na", "show_category")) {
            after <- gt_dp_show_missing(state$working_data, input$variable, input$missing_label)
            apply_change(paste("Show missing values in", input$variable, "as", input$missing_label, "(", attr(after, "gt_dp_affected"), "cells)"), after, gt_dp_code_line("missing_category", variable = input$variable, label = input$missing_label))
          } else {
            codes <- trimws(strsplit(input$codes, ",", fixed = TRUE)[[1L]]); after <- gt_dp_define_missing(state$working_data, input$variable, codes)
            apply_change(paste("Convert missing-data codes in", input$variable, "to NA (", attr(after, "gt_dp_affected"), "cells)"), after, gt_dp_code_line("missing", variable = input$variable, codes = codes))
          }
        } else if (identical(operation(), "transform")) {
          if (identical(transform_mode(), "arithmetic")) {
            mode <- input$calculation_mode %||% "single"
            after <- gt_dp_calculate(state$working_data, input$transform_source, input$transform_new, mode, input$transform_operator %||% "+", input$transform_number %||% 1, input$transform_second %||% NULL)
            code <- switch(mode,
              single = paste0("data$", input$transform_new, " <- data$", input$transform_source, " ", input$transform_operator, " ", input$transform_number),
              two_variables = paste0("data$", input$transform_new, " <- data$", input$transform_source, " ", input$transform_operator, " data$", input$transform_second),
              ratio_power = paste0("data$", input$transform_new, " <- data$", input$transform_source, " / (data$", input$transform_second, " ^ ", input$transform_number, ")")
            )
          } else {
            count <- suppressWarnings(as.integer(input$group_count %||% 2L))
            count <- if (count %in% 2:4) count else 2L
            indices <- seq_len(count - 1L)
            group_variable <- input$group_variable %||% ""
            if (!nzchar(group_variable) || !group_variable %in% names(state$working_data)) stop("Choose the variable to group.", call. = FALSE)
            variables <- rep(group_variable, length(indices))
            operators <- vapply(indices, function(index) input[[paste0("rule_op_", index)]] %||% "==", character(1))
            values <- vapply(indices, function(index) input[[paste0("rule_value_", index)]] %||% "", character(1))
            values2 <- vapply(indices, function(index) input[[paste0("rule_value2_", index)]] %||% "", character(1))
            results <- vapply(indices, function(index) input[[paste0("rule_result_", index)]] %||% "", character(1))
            if (any(!nzchar(values)) || any(!nzchar(results)) || any(operators %in% c("between", "outside") & !nzchar(values2)) || !nzchar(input$rule_default %||% "")) stop("Complete every group condition and label, including an upper bound for any range and the everyone-else group.", call. = FALSE)
            after <- gt_dp_transform_case_when(state$working_data, input$transform_new, variables, operators, values, results, input$rule_default, values2)
            rule_code <- vapply(indices, function(index) {
              condition <- if (identical(operators[[index]], "between")) {
                paste0("dplyr::between(data$", variables[[index]], ", ", values[[index]], ", ", values2[[index]], ")")
              } else if (identical(operators[[index]], "outside")) {
                paste0("(data$", variables[[index]], " < ", values[[index]], " | data$", variables[[index]], " > ", values2[[index]], ")")
              } else {
                paste0("data$", variables[[index]], " ", operators[[index]], " ", encodeString(values[[index]], quote = '"'))
              }
              paste0("  ", condition, " ~ ", encodeString(results[[index]], quote = '"'))
            }, character(1))
            code <- paste0("data$", input$transform_new, " <- dplyr::case_when(\n", paste(rule_code, collapse = ",\n"), ",\n  TRUE ~ ", encodeString(input$rule_default, quote = '"'), "\n)")
          }
          apply_change(paste("Create", input$transform_new, "(", attr(after, "gt_dp_affected"), "values matched)"), after, gt_dp_code_line("transform", code = code))
        } else if (identical(operation(), "keep")) {
          after <- gt_dp_keep_variables(state$working_data, input$keep_vars)
          apply_change(paste("Keep", ncol(after), "variable(s); remove", attr(after, "gt_dp_affected")), after, gt_dp_code_line("keep", variables = names(after)))
        } else {
          variable2 <- if (isTRUE(input$filter_second)) input$variable2 %||% "" else ""
          value2 <- if (isTRUE(input$filter_second)) input$value2 %||% "" else ""
          after <- gt_dp_filter(state$working_data, input$variable1, input$operator1, input$value1, input$connector %||% "AND", variable2, input$operator2 %||% "==", value2)
          counts <- attr(after, "gt_dp_filter_counts")
          expression <- paste(input$variable1, input$operator1, encodeString(input$value1, quote = '"'))
          if (nzchar(variable2) && nzchar(value2)) {
            connector <- if (identical(input$connector, "OR")) " | " else " & "
            expression <- paste0(expression, connector, variable2, " ", input$operator2, " ", encodeString(value2, quote = '"'))
          }
          apply_change(paste0("Filter: before ", counts[["before"]], "; included ", counts[["included"]], "; excluded ", counts[["excluded"]], "; unknown ", counts[["unknown"]]), after, gt_dp_code_line("filter", expression = expression))
        }
        shiny::showNotification("Change applied. Undo is available.", type = "message")
      }, error = function(e) shiny::showNotification(conditionMessage(e), type = "error", duration = NULL))
    })
    shiny::observeEvent(input$undo, { if (length(state$history)) { last <- state$history[[length(state$history)]]; state$history <- utils::head(state$history, -1L); state$redo_stack <- c(state$redo_stack, list(last)); state$working_data <- last$before } })
    shiny::observeEvent(input$redo, { if (length(state$redo_stack)) { last <- state$redo_stack[[length(state$redo_stack)]]; state$redo_stack <- utils::head(state$redo_stack, -1L); state$history <- c(state$history, list(last)); state$working_data <- last$after } })
    shiny::observeEvent(input$reset, {
      shiny::showModal(shiny::modalDialog(
        title = "Reset all data-preparation changes?",
        "This restores the original imported dataset and clears the change log. You cannot undo a reset.",
        footer = shiny::tagList(shiny::modalButton("Cancel"), shiny::actionButton(ns("confirm_reset"), "Reset all changes", class = "btn-danger"))
      ))
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$confirm_reset, {
      state$working_data <- state$raw_data; state$history <- list(); state$redo_stack <- list(); state$result <- NULL; state$using_prepared <- FALSE
      shiny::removeModal()
      shiny::showNotification("Data preparation reset. Analyses now use the original data until you choose otherwise.", type = "message")
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$continue_original, { state$result <- state$raw_data; state$using_prepared <- FALSE; shiny::showNotification("Analyses will use the original data.", type = "message") })
    shiny::observeEvent(input$use_prepared, { state$result <- state$working_data; state$using_prepared <- TRUE; shiny::showNotification("Analyses will use the prepared data.", type = "message") })
    output$preview <- gt::render_gt({ gt::gt(utils::head(state$working_data, 10L)) })
    output$status <- shiny::renderText({
      analysis_state <- if (isTRUE(state$using_prepared)) {
        "analyses use prepared data"
      } else if (!is.null(state$result)) {
        "analyses use original data"
      } else {
        "choose original or prepared data for analysis"
      }
      paste(nrow(state$working_data), "prepared rows |", ncol(state$working_data), "variables |", length(state$history), "applied change(s) |", analysis_state)
    })
    output$history <- shiny::renderText({ if (!length(state$history)) "No changes applied." else paste(vapply(state$history, `[[`, character(1), "label"), collapse = "\n") })
    prep_code <- shiny::reactive({ if (!length(state$history)) "# No data-preparation changes applied." else paste(vapply(state$history, `[[`, character(1), "code"), collapse = "\n") })
    output$code <- shiny::renderText(prep_code())
    output$download_code <- shiny::downloadHandler(
      filename = function() "gtstats-data-prep.R",
      content = function(file) writeLines(prep_code(), file, useBytes = TRUE)
    )
    output$download_prepared <- shiny::downloadHandler(
      filename = function() paste0("gtstats-prepared-data.", input$prepared_format %||% "csv"),
      content = function(file) {
        data <- state$working_data
        format <- input$prepared_format %||% "csv"
        if (identical(format, "csv")) {
          utils::write.csv(data, file, row.names = FALSE, na = "")
        } else if (identical(format, "rds")) {
          saveRDS(data, file)
        } else {
          if (!requireNamespace("rio", quietly = TRUE)) {
            stop("Excel and Stata download require the optional 'rio' package. Install it with install.packages('rio') and restart the app.", call. = FALSE)
          }
          rio::export(data, file)
        }
      }
    )
    list(result = shiny::reactive(state$result), working_data = shiny::reactive(state$working_data), changed = shiny::reactive(length(state$history) > 0L), using_prepared = shiny::reactive(state$using_prepared), code = prep_code)
  })
}
