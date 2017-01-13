############################
## habitata - pca.R
##
## Creating the Urbanization Index
############################


#########
## Data
#########

# Load and combine all GIMP-created data files
hab <- do.call('rbind', 
               lapply(list.files(path = "./data/", pattern = ".txt$", full.names=T), 
                      FUN = function(x) read.csv(x)))
head(hab)

# If you wish, combine different parameters to get values of natural vegetation
hab$natural <- hab$trees + hab$bushes + hab$naturalgrass
hab <- hab[, -grep("trees|bushes|naturalgrass", names(hab))]

# Make each a percentage of the total
hab$total <- rowSums(hab[, -1])
hab[, -grep("ID|total", names(hab))] <- hab[, -grep("ID|total", names(hab))] / hab$total

# Make sure all worked (should show nothing)
hab[hab$total == 0,] 

# Get a data frame with the variables of interest for creating a pca index
hab.pca <- hab[, c("natural", "grass", "pavement", "buildings")]

## /*---------*/
##' ## PCA
## /*---------*/
pca <- prcomp(~., data = hab.pca, scale = TRUE, center = TRUE)
pca
summary(pca)

library(vegan)
screeplot(pca, bstick = TRUE)


##' Save the index
hab$hab <- predict(pca)[,1]

write.csv(hab, "./pca.csv", row.names = FALSE)
