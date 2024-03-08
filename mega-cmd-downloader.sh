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

# Ask user for the download directory
read -p "Enter the download directory (default: $HOME/Downloads): " DOWNLOAD_DIR

# Set default download directory if nothing is entered
DOWNLOAD_DIR=${DOWNLOAD_DIR:-"$HOME/Downloads"}

# Validate if the download directory exists
if [[ ! -d $DOWNLOAD_DIR ]]; then
  echo "Error: The specified download directory does not exist."
  exit 1
fi

# Change to the download directory
cd "$DOWNLOAD_DIR" || exit 1

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
COUNT=0
for LINK in "${LINKS[@]}"
do
  echo "File $((COUNT+=1))"
  mega-get --ignore-quota-warn "$LINK"
  echo "End $(date +"%H:%M:%S - %d/%m/%Y")"
done
