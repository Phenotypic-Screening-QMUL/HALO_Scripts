# Load necessary library
library(stringr)
library(fs)  # For file copying

# Get the current working directory
directory <- getwd()

# List all items in the current working directory
all_items <- list.files(directory, full.names = TRUE)

# Filter items to find directories named "CD02019"
cd02019_folders <- all_items[file.info(all_items)$isdir & grepl("CD02019", basename(all_items))]

# Initialize a list to hold the matching subfolders
matching_subfolders <- list()

# Find subfolders with the naming pattern within each "CD02019" folder
for (folder in cd02019_folders) {
  subfolders <- list.files(folder, pattern = "^[0-9]+\\.0\\.1(\\.\\d+)?$", full.names = TRUE)
  matching_subfolders <- c(matching_subfolders, subfolders)
}

# Create the "Backgrounds" folder in the current working directory
backgrounds_folder <- file.path(directory, "Backgrounds")
dir.create(backgrounds_folder, showWarnings = FALSE)

# Create new subfolders in "Backgrounds" corresponding to the found subfolders
for (subfolder in matching_subfolders) {
  new_subfolder_name <- basename(subfolder)
  new_subfolder_path <- file.path(backgrounds_folder, new_subfolder_name)
  dir.create(new_subfolder_path, showWarnings = FALSE)
  
  # Copy TIF files from the subfolder to the new subfolder, excluding those in "raw"
  tif_files <- list.files(subfolder, pattern = "\\.tif$", recursive = TRUE, full.names = TRUE)
  tif_files <- tif_files[!grepl("/raw/", tif_files)]  # Exclude files in "raw" subfolders
  
  # Copy each TIF file to the new subfolder
  for (tif_file in tif_files) {
    file.copy(tif_file, new_subfolder_path)
  }
}

# Print the structure of the "Backgrounds" folder
print(list.files(backgrounds_folder, recursive = TRUE))
