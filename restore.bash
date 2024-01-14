#! /usr/bin/env bash

set -euo pipefail

if [[ -t 1 ]]; then
    colors=$(tput colors)
    if [[ $colors ]]; then
        RED='\033[0;31m'
        LIGHT_GREEN='\033[1;32m'
        NC='\033[0m'
    fi
fi

if [[ -z ${BUCKET_PATH} ]]; then
  printf "Please set the env variable ${RED}BUCKET_PATH${NC} to the s3 bucket name.\n"
  printf "E.g. BUCKET_PATH=my-bucket/breath-of-the-wild/jonathan\n"
  exit 1
fi

if [[ -z ${ARCHIVE_NAME} ]]; then
  printf "Please set the env variable ${RED}ARCHIVE_NAME${NC} to the file in the s3 bucket.\n"
  printf "E.g. game-data-2023-01-08-13-50-20.zip\n"
  exit 1
fi

if [[ $# -eq 0 ]]; then
  printf "Please pass one or more positional arguments containing the absolute paths to restore the game user data to.\n"
  printf "E.g. ~/Library/Application Support/Ryujinx/bis/user/\n"
  exit 1
fi

bucket_path=${BUCKET_PATH}
archive_name=${ARCHIVE_NAME}
temp_dir=$(mktemp -d)

function cleanup {
  printf "Cleaning up temporary files.\n"
  rm -rf "$temp_dir"
}
trap cleanup EXIT

printf "Downloading ${RED}${archive_name}${NC} from the s3 bucket.\n"
aws s3 cp "s3://${bucket_path}/${archive_name}" "$temp_dir/${archive_name}"

printf "Extracting ${RED}${archive_name}${NC} to temporary directory.\n"
unzip "$temp_dir/${archive_name}" -d "$temp_dir"

# Move each directory from the temporary location to the target location
for target_dir in "$@"; do
  dir_basename=$(basename "$target_dir")
  if [[ -d "$temp_dir/$dir_basename" ]]; then
    printf "Restoring ${RED}${dir_basename}${NC} to ${RED}${target_dir}${NC}.\n"
    rsync -a --delete "$temp_dir/$dir_basename/" "$target_dir/"
  else
    printf "${RED}Warning:${NC} Directory ${RED}${dir_basename}${NC} not found in archive. Skipping.\n"
  fi
done

printf "Restore ${LIGHT_GREEN}successful${NC}.\n"
