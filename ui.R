## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

shinyUI(
    dashboardPage(
          skin = "blue",
          dashboardHeader(title = "Movie Recommender"),
          
          dashboardSidebar(
            sidebarMenu(
              menuItem("Genres", tabName = "genres"),
              menuItem("Movies", tabName = "movies")
            )
          ),

          dashboardBody(includeCSS("css/movies.css"),
              tabItems(
                tabItem(tabName = "movies",
                  fluidRow(
                    box(width = 12, title = "What Movies do you like?",
                        status = "info", solidHeader = TRUE, collapsible = TRUE,
                        div(class = "rateitems",
                            uiOutput('ratings')
                        ),
                        br(),
                        withBusyIndicatorUI(
                          actionButton("btn1", "Click here to get our recommendations", 
                                       class = "btn-warning")
                        ),
                    )
                  ),
                  fluidRow(
                    useShinyjs(),
                    box(
                      width = 12, status = "info", solidHeader = TRUE,
                      title = "Our Recommendations",
                      tableOutput("results")
                    )
                  ) 
              ),
              tabItem(tabName = "genres",
                  fluidRow(
                    box(width = 12, title = "Step 1: Select your favorite genre", 
                        status = "info", solidHeader = TRUE, collapsible = TRUE,
                        selectInput("genreChoice", h4("What do you like to watch?"), 
                                    choices = list("Drama" = "Drama", 
                                                   "Thriller" = "Thriller",
                                                   "Comedy" = "Comedy"), selected = "Drama"),
                        withBusyIndicatorUI(
                          actionButton("btn2", "Click here to get our recommendations", 
                                       class = "btn-warning")
                        )
                    )
                  ),
                  
                  fluidRow(
                    useShinyjs(),
                    box(
                      width = 12, status = "info", solidHeader = TRUE,
                      title = "Our Recommendations For Selected Genre",
                      tableOutput("genre_results")
                    )
                  )
              ) # end of genre tab.
            ) # end of tabItems
        ) # end of dashboard body
    ) # end of dashboard page
  )#