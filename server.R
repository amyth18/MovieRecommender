source("recommender.R")

get_user_ratings = function(value_list) {
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = dat[Rating > 0]
}

# read in data
myurl = "https://liangfgithub.github.io/MovieData/"

# load movies
movies = readLines(paste0(myurl, 'movies.dat?raw=true'))
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies$MovieID = as.integer(movies$MovieID)
movies$Title = iconv(movies$Title, "latin1", "UTF-8")

small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

# load ratings.
ratings_url = paste0("https://liangfgithub.github.io/MovieData/",
                 "ratings.dat?raw=true")
ratings = read.csv(ratings_url,
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
ratings$Timestamp = NULL


ubcfRecommender = trainRecommender(ratings, "UBCF")

shinyServer(function(input, output, session) {
  
  ### Collaborative filtering based recommendation. ###
  
  # show the movies to be rated by the user.
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(style = "text-align:center", 
                     img(src = movies$image_url[(i - 1) * num_movies + j], 
                         height = 150)),
                 
                 div(style = "text-align:center", 
                     strong(movies$Title[(i - 1) * num_movies + j])),
                 
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;", 
                     ratingInput(paste0("select_", movies$MovieID[(i - 1) * num_movies + j]), 
                                 label = "", 
                                 dataStop = 5)))) #00c0ef
      })))
    })
  })
  
  # Calculate ratings.
  ubcfBasedRecom <- eventReactive(input$btn1, {
    withBusyIndicatorServer("btn1", { # showing the busy indicator
      # hide the rating container
      hide(id = "select-movies", anim = TRUE)
      
      # get the user's rating data
      value_list <- reactiveValuesToList(input)
      user_ratings <- get_user_ratings(value_list)
      print("input:")
      print(user_ratings)
      # TODO: get predicted ratings?
      # user_results = (1:10)/2
      ucfgPredMovieIds = getRecommendations(ubcfRecommender, user_ratings)
      gc(verbose = FALSE)
      return(ucfgPredMovieIds)
    }) # still busy
  }) # clicked on button
  
  # display the recommendations based on rated movies
  output$results <- renderUI({
    print("in movies results")
    num_rows <- 2
    num_movies <- 5
    ubcfRecMovieIds <- ubcfBasedRecom()
    print(ubcfRecMovieIds)
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        # get the index of the movie.
        mIdx = ubcfRecMovieIds[(i - 1) * num_movies + j]
        
        box(width = 2, status = "success", solidHeader = TRUE, 
            title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = movies$image_url[mIdx], 
                      height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(movies$Title[mIdx])
            )
        )        
      }))) # columns
    }) # rows
  }) # renderUI function
  
  ### genre based recommendation. ###
  
  genreBasedRecom <- eventReactive(input$btn2, {
    withBusyIndicatorServer("btn", { # showing the busy indicator
      # get the user's rating data
      genre <- input$genreChoice
      print(genre)
      # get top#10 movies for the selected genre.
      top10MovieIdsByGenre = getHighestRatedMoviesByGenre(movies, ratings, genre)
      gc(verbose = FALSE)
      # recom_results_for_genre <- data.table(Rank = 1:10, 
      #                            MovieID = movies$MovieID[movie_ids], 
      #                            Title = movies$Title[movie_ids], 
      #                            Predicted_rating =  user_results)
      return(top10MovieIdsByGenre)
    }) # still busy
  }) # clicked on button
  
  # display recommendation based on genre
  output$genre_results <- renderUI({
    num_rows <- 2
    num_movies <- 5
    highestRateMovieIds <- genreBasedRecom()
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        mIdx = highestRateMovieIds[(i - 1) * num_movies + j]
        
        box(width = 2, status = "success", solidHeader = TRUE, 
            title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = movies$image_url[mIdx], 
                      height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(movies$Title[mIdx])
            )
        )
      }))) # columns
    }) # rows
  }) # renderUI function
  
}) # server function