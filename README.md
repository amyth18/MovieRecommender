# Overview
This repository contains the code for **Movie Recommender** app built as part of CS598 Practical Statistical Learning Course in Fall of 2021.
This was solo project undertaken by ameed2@illinois.edu.

# Workflows
The application has 2 workflows
1. Movie recommendation based on user selected genre
2. Movie recommendation based on user's ratings of sample movies.

# Impelementation Details

## Front and Backend
The app is based on Shiny web app framework from R Studio. This app is based on top of [ShinyRatingInput](https://github.com/stefanwilhelm/ShinyRatingInput) but the collaborative filtering algorithms are replaced by our own implementation. The code for front end can be found in ```ui.R``` and code for backend can be found in ```server.R```.

## Recommender Algorithms
We have implemented 2 recommender algorithms. One genre based recommendation and second based on collobartive filtering algorithms. We use User Based Collaborative filtering algorithm. We use UCBF implementation from ```recommderlab``` R package. All the code for recommendation can be found in ```recommder.R```. A detailed evaluation of these algorithms is presented this [R markdown](link) file.

# Credits
1. [ShinyRatingInput](https://github.com/stefanwilhelm/ShinyRatingInput)
2. [shinyJS](https://github.com/daattali/shinyjs)
