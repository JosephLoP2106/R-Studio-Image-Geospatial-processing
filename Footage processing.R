#ask for the location of the directory that segments, concat_output and Images will be made
#along with the list of images to be concatenated
home_dir <- readline("Pathway to processing directory:")


#DIRECTORY CREATION

#Checks for the SEGMENTS folder within the directory, if not, makes it
sub_dir_VS <- "VIDEO_SEGMENTS"
VIDEO_SEGMENTS <- file.path(home_dir, sub_dir_VS)


if (!dir.exists(VIDEO_SEGMENTS)){
  dir.create(VIDEO_SEGMENTS) & print("VIDEO_SEGMENT Directory Created")
} else {
  print("VIDEO_SEGMENTS Directory already exists!")
}


#Checks for CONCAT_OUTPUT folder within the directory, if not, makes it
sub_dir_CO <- "CONCAT_OUTPUT"
CONCAT_OUTPUT <- file.path(home_dir, sub_dir_CO)

if (!dir.exists(CONCAT_OUTPUT)){
  dir.create(CONCAT_OUTPUT) & print("CONCAT_OUTPUT Directory Created")
} else {
  print("CONCAT_OUTPUT Directory already exists!")
}


#Checks for IMAGES folder within the directory, if not, makes it
sub_dir_I <- "IMAGES"
IMAGES <- file.path(home_dir, sub_dir_I)

if (!dir.exists(IMAGES)){
  dir.create(IMAGES) & print("IMAGES Directory Created")
} else {
  print("IMAGES Directory already exists!")
}








#Generate list of files in VIDEO_SEGMENTS, adds formatting for ffmpeg

VS_FILES <- list.files(VIDEO_SEGMENTS, full.names = TRUE)
VS_FILES_PREFIX <- paste("file", VS_FILES, sep= " ")
print(VS_FILES_PREFIX)

#Creates path to video_list.txt, which will be used in ffmpeg down the line.
#This is also set up to work in the home directory 100% of the time
video_list_txt_ext <- "video_list.txt"
path_to_segment_list <- file.path(home_dir, sub_dir_VS, video_list_txt_ext)

#Creates text document for file list
file.create(path_to_segment_list)

#Writes the file list with the correct prefixes into the previously created txt doc
writeLines(c(paste(VS_FILES_PREFIX)), path_to_segment_list)










#ask for which file extension the output will be in
output_extension <- readline("Output Video Extension:")

#ask for the name of the concat output
output_name <- readline("Output Video Name:")






#Prompts how many frames per second will be extracted from the post concat video
#includes edge cases, such as non numeric answers, and values <= zero
get_images_per_second <- function(prompt_in){
  while(TRUE) {
    
    input <- readline(prompt = prompt_in)
    numeric_input <- as.numeric(input)
    if(!is.na(numeric_input) && numeric_input > 0) {
      return(as.numeric(input))
    } else {
      cat("Invalid input. Enter a valid non zero number. \n")
      
      }
    }
  }
    
#envokes the get_images_per_second function, stores as images_per_second to be used in image extraction post concatenation
images_per_second <- get_images_per_second("Please enter the number of images/frames you want extracted per second of footage: ")
  




#command to concatenate footage in the SEGMENTS folder, without hardware acceleration
concatanate_normal <- paste0("ffmpeg -f concat -safe 0 -i ", path_to_segment_list, " -c:v copy ", CONCAT_OUTPUT, "/",output_name,".", output_extension)
print(concatanate_normal)

#command to concatenate footage in the SEGMENTS folder, with hardware acceleration
concatanate_hardware_accelerated <- paste0("ffmpeg -hwaccel auto -f concat -safe 0 -i ", path_to_segment_list, " -c:v h264_nvenc -b:v 50 ", CONCAT_OUTPUT,"/",output_name,".",output_extension)
print(concatanate_hardware_accelerated)

#Processes that removes frames from the concatenated video, without  HWA. Need to work in the frames per second
image_extraction_normal <- paste0("ffmpeg -i ",CONCAT_OUTPUT, "/", output_name, ".",output_extension, " -vf fps=" , images_per_second, " ", IMAGES, "/%06d.png")
print(image_extraction_normal)           
                                     
#Processes that removes frames from the concatenated video, with HWA. Need to work in the frames per second
image_extraction_hardware_accelerated <- paste0("ffmpeg -hwaccel auto -c:v h264_cuvid -i ",CONCAT_OUTPUT, "/", output_name, ".",output_extension, " -vf fps=", images_per_second, " ", IMAGES, "/%06d.png")
print(image_extraction_hardware_accelerated)



#Asks if want to use hardware accel (for nvidia) for concatenation
repeat{
  
  #prompts inputd
  concat_flavor <- readline("Hardware Accleration for Concatanation (true/false):")
  
  
  #Triggers concatenation_hardware_accelerated, if true 
  if(tolower(concat_flavor) == "true" ) {
    system(concatanate_hardware_accelerated)
    cat("Concatnation Sucessful!")
    system(image_extraction_hardware_accelerated)
    cat("Frame extraction complete!")
    
    break 
}
  #Triggers concatenation_normal if false    
  else if(tolower(concat_flavor) == "false") {
  system(concatanate_normal)
  cat("Concatnation Sucessful!")
  system(image_extraction_normal)
  cat("Frame extraction complete!")
  
  break
}
  #Repeats prompt if neither of the options above are triggered, allows for re-input
  else {
  cat("Invalid input, Please enter true or false")
  }
  
}








































