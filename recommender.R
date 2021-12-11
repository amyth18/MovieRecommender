library(recommenderlab)
library(dplyr)
library(ggplot2)
library(DT)
library(data.table)
library(reshape2)
library(tidyr)

trainRecommender = function(ratings, type="UCBF") {
  print("in trainRecommnder()")
  i = paste0('u', ratings$UserID)
  j = paste0('m', ratings$MovieID)
  x = ratings$Rating
  tmp = data.frame(i, j, x, stringsAsFactors = T)
  
  sparseMatrix = sparseMatrix(as.integer(tmp$i), as.integer(tmp$j), x = tmp$x)
  rownames(sparseMatrix) = levels(tmp$i)
  colnames(sparseMatrix) = levels(tmp$j)
  
  Rmatrix = new('realRatingMatrix', data = sparseMatrix)
  
  if (type == "UBCF") {
    return(Recommender(Rmatrix, "UBCF", 
                  parameter = list(
                    normalize = 'Z-score',
                    method = 'cosine',
                    nn = 25,
                    weighted = TRUE
                  )))
  } else if (type == "IBCF") {
    return(Recommender(Rmatrix, "IBCF", 
                       parameter = list(
                         normalize = 'Z-score',
                         method = 'pearson',
                         k = 25
                       )))
  } else {
    return(Recommender(Rmatrix, "UBCF", 
                       parameter = list(
                         normalize = 'Z-score',
                         method = 'cosine',
                         nn = 25
                       )))
  }
}

getRecommendations = function(recommender, userRatingsTable) {
  movieIDs = colnames(getModel(recommender)$data)
  n_movies = length(movieIDs)
  
  newUserRatings = rep(NA, n_movies)
  for (i in 1:nrow(userRatingsTable)) {
    movieIdString = paste0("m", userRatingsTable[i,1])
    newUserRatings[which(movieIDs == movieIdString)] = userRatingsTable[i,2]
  }
  
  newUser = matrix(newUserRatings, nrow=1, ncol=n_movies,
                    dimnames = list(user=paste('unknown'), 
                                    item=movieIDs))
  
  newUserRmatrix = as(newUser, 'realRatingMatrix')
  
  ourRecommendation = predict(recommender, newUserRmatrix, 
                              type="topNList", n=10)
  
  return(ourRecommendation@items[[1]])
}

getUniqueGenres = function(movies) {
  movies_expanded = movies %>% separate_rows(Genres, sep = '[|]')
  return(pull(unique(movies_expanded['Genres']), Genres))
}

getHighestRatedMoviesByGenre = function(movies, ratings, genreChosen) {
  
  movies_expanded = movies %>% separate_rows(Genres, sep = '[|]')
  
  movies_f1score = 
    ratings %>% 
    group_by(MovieID) %>%
    summarize(NoOfRatings = n(), AvgRating = mean(Rating)) %>%
    mutate(F1Score = ((2*NoOfRatings*AvgRating)/(NoOfRatings+AvgRating)))
  
  highest_rated_movies_by_genre =
    movies_expanded %>%
    inner_join(movies_f1score, by = 'MovieID') %>%
    group_by(Genres) %>%
    arrange(desc(F1Score), .by_group = TRUE) %>%
    select(c("Genres", "MovieID", "Title", "NoOfRatings", "AvgRating", "F1Score"))
  
  top10 = highest_rated_movies_by_genre[which(highest_rated_movies_by_genre$Genres == 
                                        genreChosen),][1:10, c('MovieID')]  
  
  top10_vec = pull(top10, MovieID)
  m_ids = lapply(top10_vec, function(m, movies) {
    return(match(m, movies[,'MovieID']))
  }, movies)
  
  return(unlist(m_ids))
}

