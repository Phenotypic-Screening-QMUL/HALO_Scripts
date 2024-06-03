# Get the current working directory
directory <- getwd()

# List TIFF files
tif_files <- list.files(directory, pattern = "\\.tif$", full.names = TRUE)

# Extract well and fld patterns
patterns <- unique(gsub(".*([A-Z] - \\d+).*fld (\\d+).*", "\\1_fld\\2", tif_files))

# Iterate through each unique well and fld pattern
for (pattern in patterns) {
  # Open a text file to write
  output_file <- file(paste0("output_", pattern, ".afi"), "w")
  
  # Write the XML declaration and opening tags
  cat("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n", file = output_file)
  cat("<ImageList xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">\n", file = output_file)
  
  # Filter TIFF files for the current pattern
  pattern_files <- tif_files[grep(gsub("_fld", ".*fld ", pattern), tif_files)]
  
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

