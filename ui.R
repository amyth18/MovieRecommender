## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

genreList = c("Animation", "Children's", "Comedy", "Adventure", "Fantasy", 
              "Romance", "Drama" , "Action", "Crime", "Thriller", "Horror", 
              "Sci-Fi", "Documentary", "War", "Musical", "Mystery", "Film-Noir",
              "Western")

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
                    box(id="select-movies", width = 12, title = "Tell us what movies do you like?",
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
                    box(id="select-genre", width = 12, title = "Select your favorite genre", 
                        status = "info", solidHeader = TRUE, collapsible = TRUE,
                        selectInput(
                          "genreChoice",
                          label = h4("What do you like to watch?"),
                          choices = genreList,
                          selected = "Drama"
                        ),
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
                      title = "Our recommendations for selected genre",
                      tableOutput("genre_results")
                    )
                  )
              ) # end of genre tab.
            ) # end of tabItems
        ) # end of dashboard body
    ) # end of dashboard page
  )#