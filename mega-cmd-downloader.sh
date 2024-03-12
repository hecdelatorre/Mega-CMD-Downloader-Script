#!/bin/bash

# Function to validate Mega.nz links
validate_mega_link() {
  local link=$1
  if [[ $link =~ ^https://mega\.nz ]]; then
    return 0
  else
    return 1
  fi
}

# Function to display elapsed time while downloads are in progress
display_elapsed_time() {
  local elapsed=0
  while [ "$(jobs -r | wc -l)" -gt 0 ]; do
    sleep 1
    elapsed=$((elapsed + 1))
    printf "\rElapsed time: %02d:%02d:%02d" $((elapsed/3600)) $((elapsed%3600/60)) $((elapsed%60))
  done
}

# Ask user for the download directory
read -p "Enter the download directory (default: $HOME/Downloads): " DOWNLOAD_DIR

# Set default download directory if nothing is entered
DOWNLOAD_DIR=${DOWNLOAD_DIR:-"$HOME/Downloads"}

# Validate if the download directory exists
if [[ ! -d $DOWNLOAD_DIR ]]; then
  echo "Error: The specified download directory does not exist."
  exit 1
fi

# Ask user if they want to create a subdirectory
read -p "Do you want to create a subdirectory for the downloads? (y/n): " CREATE_SUBDIR

# Check user's response and handle accordingly
case $CREATE_SUBDIR in
  y|Y)
    read -p "Enter the name of the subdirectory: " SUBDIR_NAME
    DOWNLOAD_DIR="$DOWNLOAD_DIR/$SUBDIR_NAME"
    mkdir -p "$DOWNLOAD_DIR"
    ;;
  n|N)
    # Keep original download directory
    ;;
  *)
    echo "Error: Please enter 'y' or 'n'."
    exit 1
    ;;
esac

# Ask user for the number of links to download
read -p "Enter the number of links to download: " NUM_LINKS

# Validate if the input is a positive integer
if ! [[ $NUM_LINKS =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: Please enter a positive integer for the number of links."
  exit 1
fi

# Initialize array to store links
LINKS=()

# Loop to input links based on the number provided
for ((i=1; i<=$NUM_LINKS; i++))
do
  # Ask user for link and validate
  while true; do
    read -p "Enter link $i: " LINK
    if validate_mega_link "$LINK"; then
      LINKS+=("$LINK")
      break
    else
      echo "Error: Invalid Mega.nz link. Please enter a valid Mega.nz link."
    fi
  done
done

# Download files
for LINK in "${LINKS[@]}"
do
  mega-get --ignore-quota-warn "$LINK" "$DOWNLOAD_DIR" > /dev/null 2>&1 &
done

# Display elapsed time while downloads are in progress
display_elapsed_time

# Wait for all background downloads to finish
wait

echo -e "\nEnd $(date +"%H:%M:%S - %d/%m/%Y")"
