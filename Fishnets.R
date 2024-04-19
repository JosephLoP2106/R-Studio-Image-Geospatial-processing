#NOTE: the ARCGIS-R bridge can only read shapefiles, and you must specify which one. I am going to include an option
#that gives you the choice to use the raw nav file, or a shape file.

#Package requirements
install.packages("arcgisbinding", repos="https://r.esri.com", type="win.binary")
install.packages("dplyr")
install.packages("sf")
install.packages("ggplot2")
install.packages("st")
install.packages("tmap")

library(arcgisbinding)
library(dplyr)
library(sf)
library(ggplot2)
library(st)
library(tmap)



#This section allows for switching between GIS and CSV input
repeat {

  #Prompting data input method
  Input_method <- readline("Data input via ArcGIS shape file? (true/false):")
  
  #Locating GIS .shp, opening it, grabbing data
if(tolower(Input_method) == "true" ) {
  GIS_project_path <- readline("What is the name of the shape file you wish to open?")
  rov_pathing <- arc.open(GIS_project_path)

  #Grabbing relevant information (cords) from GIS imported datasheet. Will be used for fishnet later
  rov_pathing_df <- arc.select(object = rov_pathing, fields = c("Latitude", "Longitude"))
  print(rov_pathing_df)

  break
  
 }

else if(tolower(Input_method) == "false") {
  
  #Raw Nav file
  CSV_Input <- readline("Pathway to raw data (.CSV)")  
  rov_pathing_df <- read.csv(CSV_Input)
  print(rov_pathing_df)
  break
  
  }

  else {
    
    #If invalid input
    cat("Invalid input, Please enter true or false")
       }

  }


#Due to the nature of the heatmap using cordinates for point position, so does the axis of the figure
#In order to get the size of the fishnet in meters, it must be converted to degrees prior.
# meters= degrees * 111,139, therefor degrees = meters/ 111,139
string_net_size <- readline("What would you like the size of the gridcells to be? (In meters)?")
int_net_size <- strtoi(string_net_size)
net_size <- int_net_size/111139

#fishnet phase
#converting from df to sf so coords work :P
rov_pathing_sf <- rov_pathing_df |>
  st_as_sf(
    coords = c("Longitude", "Latitude"),
    crs = 4326)

#Setup for fishnet
#Calls "net_size" to determine how big the cells are going to be
grid <- st_make_grid(rov_pathing_sf, cellsize = net_size)
index <- which(lengths(st_intersects(grid, rov_pathing_sf)) > 0)

#creation of fishnet list that contains individual points, to be used for image selection l8r
fnet_long <- grid[index] |>
  st_as_sf()

#fishnet creation
fnet <- grid[index] |>
  st_as_sf()|>
  mutate(id = row_number())

#Creates ID's for each point
rov_counts <- st_join(rov_pathing_sf, fnet) |>
  st_drop_geometry() |>
  count(id)
print(rov_counts)

#creation of gridcells with point ID's for image identification
rov_counts_long <- st_join(rov_pathing_sf, fnet) |>
  st_drop_geometry()

fnet_counts <- left_join(fnet, rov_counts)

#Pre heatmap diagrams
rov_pathing_cords <- rov_pathing_df[c("Latitude", "Longitude")]
ggplot(rov_pathing_cords, aes(x=Latitude, y=Longitude))+
  geom_point()+
  theme_bw() +
  labs(title = "Rov pathing")

#Heatmap
fnet_counts |>
  ggplot(aes(fill = n)) +
  geom_sf(color = "black", lwd = 0.15) +
  theme_bw() +
  scale_fill_viridis_c(option = "C") +
  labs(title = "Rov position density")
     
#Report generation:
#How many points were mapped
#Points per gridcell
print("Number of points")
point_count <- nrow(rov_pathing_df)
print(point_count)

print("Number of Filled gridcells")
cell_count <- nrow(rov_counts)
print(cell_count)

print("Average number of points per cell")
cell_average <- mean(rov_counts$n)
print(cell_average)



