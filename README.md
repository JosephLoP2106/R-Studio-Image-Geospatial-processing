# R-Studio-Image-Geospatial-processing
A R-studio script which uses ffmpeg and R-Bridge (for ArcGIS access) to processes footage, and assign spatial positions to generated the images using GIS

USAGE:

Footage processing (1st): Splicing footage together, taking out frames

    -Directory creation for image manipulation (based on a home directory of your choice)
    -Video segments is where the footage clips go
    -Concat output is where the "sitched" video will be outputed to
    -Images is where the frames extracted will be stored    
    -Options for hardware accleration
    -Concatanation and frame selection (based on images per second)
    *This requires FFMPEG, please ensure that it is installed on your system!



Fishnets (2nd step): Creation of fishnet, figures of the datapoints

    -Options for data ingestion via ArcGIS shape file via GIS bridge package (This requires additional setup, see here:https://www.esri.com/en-us/arcgis/products/r-arcgis-bridge/get-started)
        *This option is still in development, use with caution!
    -Option to ingest position data from the raw Nav Data CSV
    -Selection of fishnet grid cell size (In meters)
    -Generates a figure with points mapped out with cordinates to show ROV pathing in R
    -Generates fishnet, with a heat map to show the density of points 
    -Report generation
        -For release 1.1.0:
        -Spatial thinning of the points (with desired distancing) prior to point plotting
        -ensuring that each image is assoicted with nav point
              -(If nav points are generated at 3 second intervals, ensure that the interval for images extracted from the footage per second is a multiple of 3)



Image selection (3rd step): Selecting images from each gridcell at random, up to a certian value of images

    -Option to select a specific number of images to be extracted from each gridcell
          -done based on grouping of a matching gridcell ID
    -Creation of a new directory within the home directory to put these images inside of
          -renmaed "fishnet_(name of orignal image)

    
