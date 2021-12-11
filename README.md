# Overview
This repository contains the code for **Movie Recommender** app built as part of CS598 Practical Statistical Learning Course in Fall of 2021.
This was solo project undertaken by ameed2@illinois.edu.

A working version of this app is hosted on shinyapps at https://ameed2.shinyapps.io/MovieRecommender/

# Workflows
The application has 2 workflows
1. Movie recommendation based on user selected genre
2. Movie recommendation based on user's ratings of sample movies.

# Impelementation Details

## Front and Backend
The app is based on Shiny web app framework from R Studio. This app is based on top of [ShinyRatingInput](https://github.com/stefanwilhelm/ShinyRatingInput) but the collaborative filtering algorithms are replaced by our own implementation. The code for front end can be found in ```ui.R``` and code for backend can be found in ```server.R```.

## Recommender Algorithms
We have implemented 2 types of recommender systems in the application. The code for these algorithmns can be found in ```recommender.R``` file in the repository.

### Recommendation Based on Static Rules
In this system we computed the F1 score for each movie within a genre (i.e grouped by genre). When the user selects genre of his choice we recommend the top#10 movies with highest F1 score in that genre. Please refer to the [Rmarkdown] file for more details on details of this approach.

### Recommendation Based on UBCF
In this system we train a UBCF model on the entire training data when the application bootstraps using the ```recommenderlab``` R package. We then ask a user to rate some sample movies in UI and then use the ```predict()``` function with ```type=topNList``` to get top#10 movie recommendations from the UBCF model.

# Credits
1. https://github.com/stefanwilhelm/ShinyRatingInput
2. https://github.com/daattali/shinyjs
