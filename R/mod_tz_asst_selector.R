# Module for displaying timezone and local currency selector
# Optionally disables asset selector on a given tab
# Server returns selected assets and timezone/local currency as reactive values

library(shiny)
library(here)

source(here::here("R", "reactive_utils.R"))

# tz_list: named list whose values correspond to the names (keys) in asst_list. Keys are shown to user in select input dropdown.
# asset_list: named list of lists whose names correspond to the values in tz_list. Sublists populate select input dropdown.
mod_tz_asset_selector_ui <- function(id, tz_list, asst_list, selected_tz) {
  ns <- NS(id)
  
  tagList(
    selectizeInput(
      ns("tzSelector"),
      "Select Local Currency and Time Zone",
      choices = tz_list,
      selected = tz_list[[selected_tz]],
      multiple = FALSE
    ),
    
    selectizeInput(
      ns("assets"), 
      "Select Assets", 
      choices = asst_list[[tz_list[[selected_tz]]]], 
      selected = asst_list[[tz_list[[selected_tz]]]][1:3], 
      multiple = TRUE
    )
  )
  
}

# selected_panel: optionally pass currently selected tabpanel
# disable_inputs_panel: optionally pass a tabpanel in which to disable inputs
# input_to_disable: optionally pass an input to disable when selected_panel == disable_inputs_panel
# returns: reactive values object containing selected timezone and assets
mod_tz_asset_selector_server <- function(id, tz_list, asst_list, selected_panel = NULL, disable_inputs_panel = NULL, input_to_disable = "assets") {
  moduleServer(id, function(input, output, session) {
    
    # disable assets selector on specific panel
    if(!is.null(selected_panel)) {
      disable_inputs(selected_panel, disable_inputs_panel, input_to_disable)
    }
    
    selected <- reactiveValues(assets = NULL, timezone = NULL)
    
    observeEvent(input$tzSelector, {
      updateSelectizeInput(
        session = session, 
        inputId = "assets", 
        choices = asst_list[[input$tzSelector]], 
        selected = asst_list[[input$tzSelector]][1:3]
      )
      
      selected$assets <- input$assets
      selected$timezone <- input$tzSelector
      
    })
    
    observeEvent(input$assets, {
      selected$assets <- input$assets
    })
    
    return(selected)
  })
}

tz_asset_selector_app <- function() {
  ui <- fluidPage(
    mod_tz_asset_selector_ui(id = "seasAsstSelector", timezone_list, assets_list, "USD in ET")
  )
  
  server <- function(input, output, session) {
    mod_tz_asset_selector_server(id = "seasAsstSelector", timezone_list, assets_list)
  }
  
  shinyApp(ui, server)
}


# tz_asset_selector_app()
