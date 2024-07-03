# Load necessary libraries
library(stringr)
library(fs)  # For file copying

# Get the current working directory
directory <- getwd()

# Define the Backgrounds folder
backgrounds_folder <- file.path(directory, "Backgrounds")

# List all subfolders in the Backgrounds folder
subfolders <- list.dirs(backgrounds_folder, recursive = FALSE)

# Function to create .afi files based on R00X pattern
create_afi_files <- function(subfolder) {
  # List all TIFF files in the current subfolder, including those in sub-subfolders
  tif_files <- list.files(subfolder, pattern = "\\.tif$", recursive = TRUE, full.names = TRUE)
  
  # Filter out files containing "VHE"
  tif_files <- tif_files[!grepl("VHE", tif_files)]
  
  # Extract the R00X patterns from the filenames
  r_patterns <- unique(str_extract(basename(tif_files), "R00\\d"))
  
  # Iterate through each unique R00X pattern to create separate .afi files
  for (r_pattern in r_patterns) {
    # Filter files matching the current R00X pattern
    pattern_files <- tif_files[grepl(r_pattern, tif_files)]
    
    # Define the output .afi file path using the folder name and R00X pattern
    folder_name <- basename(subfolder)
    output_file_path <- file.path(subfolder, paste0(folder_name, "_", r_pattern, ".afi"))
    
    # Open a text file to write
    output_file <- file(output_file_path, "w")
    
    # Write the XML declaration and opening tags
    cat("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n", file = output_file)
    cat("<ImageList xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">\n", file = output_file)
    
    # Iterate through filtered TIFF files and write to output file
    for (file in pattern_files) {
      # Extract channel name from file name
      channelName <- gsub("^.*?wv (.*?)\\).*", "\\1", basename(file))
      
      # Trim leading and trailing spaces from channelName and file name
      channelName <- trimws(channelName)
      fileName <- trimws(basename(file))
      
      # Write to file in the desired format
      cat("  <Image>\n", file = output_file)
      cat(paste0("    <ChannelName>", channelName, "</ChannelName>\n"), file = output_file)
      cat(paste0("    <Path>", fileName, "</Path>\n"), file = output_file)
      cat("  </Image>\n", file = output_file)
    }
    
    # Write the closing tag
    cat("</ImageList>\n", file = output_file)
    
    # Close the output file
    close(output_file)
  }
}

# Iterate through each subfolder and create .afi files
for (subfolder in subfolders) {
  create_afi_files(subfolder)
}

# Print a message to indicate completion
print("background_afi.afi files have been created in each subfolder.")
