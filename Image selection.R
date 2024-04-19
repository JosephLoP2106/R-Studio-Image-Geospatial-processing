install.packages("dplyr")
install.packages("tidyr")
install.packages("stringr")

library(dplyr)
library(tidyr)
library(stringr)
#This process involves checking the numbers of points associated with each gridcell in the fishnet, and
#linking these numbers to image of the same number.
#Once linked, we can preform tasks such as picking at random,  a select number of images per grid cell
#and put them in another destination for review.


#calling the path to video segements, made in the Footage processing module. Reading the name of all
#files in this path and creating a data frame
full_image_list <- list.files(path = IMAGES, full.names = TRUE)
print(full_image_list)

#asks for a number of randomly selected points per cell
points_per_cell <- readline("How many points would you like, at max, to be selected at random per grid cell?")

#converts the string output to an integer, so we can do number stuff with it
PPSi <- strtoi(points_per_cell)

#determine what points are in what gridcell. This is going to require rov_counts_long from fishnets.
#We are going to group the ID columns by repeats, and keep the value in the X column. The rest can go
#column thinning
image_column_trim <- rov_counts_long[c("X","id")]

#Need to add 1 to each value of the X column to ensure that we start with image 1. Artifact of older steps
#This is a ducttape fix
image_column_trim <- image_column_trim + 1

#Sampling function. Using the sample function, we can select a defined number of points at random. 
#Takes a maximum of 5 images
sample_images_per_group <- function(X){
  
  if (length(X) > PPSi) 
  {return(sample(X, PPSi)) }
  
   else 
    
  {return(sample(X, length(X))) }
}

#Grouping and sampling
#This groups all of the items that have the same cell ID together, and then creates a list
#The first column is the ID of the cell
#The second column contains each point/ image contained in that cell
image_grouped <- image_column_trim %>%
  group_by(id) %>%
  summarize(X = list(sample_images_per_group(X))) %>%
  unnest(cols = c (X))

#Checking to see the total number of images (x) to see if the matching process worked
image_grouped_count <- count(image_grouped, "X")

#Now the fun part, associating these values in the X (image) column to the actual images
#turning that horrible mess of file names into a usable list
full_image_list <- as.list(full_image_list)
print(full_image_list)

#Extracting numbers from our image file. Gsub removes everything but those selected characters
number_extract <- as.numeric(gsub("[^0-9]", "", full_image_list))
print(number_extract)

#matching numbers from the extract, with the grouped image_grouped DF
matched_files <- full_image_list[match(image_grouped$X, number_extract)]
View(matched_files)

#Checking to see the total of matched images (X). First need to remove the unmatched images/ points

#Removing NULL entries in the list
#matched_thinned <- matched_files[!str_detect(matched_files,pattern="NULL")]

#Counting number of remaining entries in the list, telling us how many matches there are
#matched_total <- length(matched_thinned)
#print(matched_total)

#missmatch in numbers. Appears that there is more points in the nav data than there is images extracted



#Copying matched images to a new directory
#Creating the directory for the matched images to go to
sub_dir_FI <- "FISHNET_IMAGES"
FISHNET_IMAGES <- file.path(home_dir, sub_dir_FI, "/")


if (!dir.exists(FISHNET_IMAGES)){
  dir.create(FISHNET_IMAGES) & print("FISHNET_IMAGES Directory Created")
} else {
  print("FISHNET_IMAGES already exists!")
}

# Function to copy files to a specific directory
copy_files_dir <- function(files, destination_dir) {
  for (file in files) {
    file.copy(file, paste0(destination_dir, "fishnet_", basename(file)))
  }
}

# Copy matched files to the specified directory
copy_files_dir(matched_files, FISHNET_IMAGES) |>
  cat("Transfer complete")


