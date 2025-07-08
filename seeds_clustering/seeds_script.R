## Molly Szeman   Aug 1, 2023   ALY6040   Project 3

# prepare the environment
cat("\014") # clears console
rm(list = ls()) # clears global environment
try(dev.off(dev.list()["RStudioGD"]), silent = TRUE) # clears plots
try(p_unload(p_loaded(), character.only = TRUE), silent = TRUE) # clears packages
options(scipen = 100) # disables scientific notion for entire R session

#load the packages
library(pacman)
library(dplyr)
library(skimr)
library(ggplot2)
library(tidyr)

# set seed
set.seed(63)

## read txt file into environment
data <- read.table("seeds_dataset.txt", header = FALSE)

## rename columns with variables names 
colnames(data) <- c("Area", "Perimeter", "Compactness", "length_of_kernel",
        "width_of_kernel", "asymmetry_coefficient", "length_of_kernel_groove")
head(data)

# list number of rows, columns, and structure of the data
nrow(data)
ncol(data)
str(data)

# drop column 8
data <- data[-8]

## data summary with skim and psych describe
skim(data)
psych::describe(data)

# Standardize the Data using scale()
data2<-scale(data)
head(data2)

# data summary of standardized data
skim(data2)

# Computing k-means clustering in R with the kmeans function. 
km_model<-kmeans(data2, centers=4, nstart=25)

#Model summary
km_model
# Cluster details of the data points
km_model$cluster
# Centers of each cluster for each variables
km_model$centers

##Plotting cluster
library(factoextra) 

# We plot cluster using fviz_cluster(). 
## If there are more than two dimensions (variables) fviz_cluster 
# will perform principal component analysis (PCA) and plot the data points
# First two of the principal components explain the
# majority of the variance.

fviz_cluster(km_model, data = data2)


###We will find the optimal cluster value k using Elbow method
# the "Elbow method" is supported by a single function (fviz_nbclust):
set.seed(123)
fviz_nbclust(data2, kmeans, method = "wss")


# We will compute using k=3
km_model_k2<-kmeans(data2, centers=3, nstart=25)
fviz_cluster(km_model_k2, data = data2)
# Cluster details of the data points
km_model_k2
km_model_k2$cluster
km_model_k2$centers


##### Hierachical clustering
dist_obs_seeds<-dist(data2, method="euclidean")
cluster_hier<-hclust(dist_obs_seeds,method="average")

require(factoextra)
fviz_dend(x = cluster_hier,
          rect = TRUE, 
          cex = 0.5, lwd = 0.6,
          k = 3,
          k_colors = c("purple","red", 
                       "green3"),
          rect_border = "gray", 
          rect_fill = FALSE)


dist_obs_seeds<-dist(data2, method="euclidean")
cluster_hier<-hclust(dist_obs_seeds,method="complete")

require(factoextra)
fviz_dend(x = cluster_hier,
          rect = TRUE, 
          cex = 0.5, lwd = 0.6,
          k = 3,
          k_colors = c("purple","red", 
                       "green3"),
          rect_border = "gray", 
          rect_fill = FALSE)

