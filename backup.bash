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
  printf "E.g. BUCKET_PATH=ryujinx-00\n"
  exit 1
fi

if [[ -z ${ARCHIVE_LIMIT} ]]; then
  printf "Please set the env variable ${RED}ARCHIVE_LIMIT${NC} to limit the number of archives to keep.\n"
  printf "E.g. ARCHIVE_LIMIT=10\n"
  exit 1
fi

if [[ $# -eq 0 ]]; then
  printf "Please pass one or more positional arguments containing the absolute paths to the game user data.\n"
  printf "E.g. ~/Library/Application Support/Ryujinx/bis/user/\n"
  exit 1
fi

bucket_path=${BUCKET_PATH}
archive_limit=${ARCHIVE_LIMIT}
temp_dir=$(mktemp -d)

function cleanup {
  printf "Cleaning up temporary files.\n"
  rm -rf "$temp_dir"
}
trap cleanup EXIT

archive_name="game-data-$(date +"%Y-%m-%d-%H-%M-%S").zip"

# Copy all directories to a temporary directory and create a single archive
for dir in "$@"; do
  if [[ -d $dir ]]; then
    printf "Copying ${RED}${dir}${NC} to temporary directory.\n"
    dir_basename=$(basename "$dir")
    cp -a "$dir" "$temp_dir/$dir_basename"
  else
    printf "${RED}Warning:${NC} Directory ${RED}${dir}${NC} does not exist. Skipping.\n"
  fi
done

printf "Creating archive of the directories.\n"
pushd "$temp_dir" > /dev/null
zip -r "$archive_name" .
popd > /dev/null

printf "Checking if the s3 bucket has more than ${RED}${archive_limit}${NC} files already.\n"
content=( $(aws s3 ls "s3://${bucket_path}/" | awk '{print $4}') )

if [[ ${#content[@]} -ge $archive_limit ]]; then
  echo "There are too many archives. Deleting oldest one."
  oldest_archive=${content[0]}
  printf "${RED}s3://${bucket_path}/${oldest_archive}${NC}\n"
  aws s3 rm "s3://${bucket_path}/${oldest_archive}"
fi

printf "Uploading ${RED}${archive_name}${NC} to the s3 bucket.\n"
state=$(aws s3 cp "$temp_dir/$archive_name" "s3://${bucket_path}/")

if [[ "$state" =~ "upload:" ]]; then
  printf "Backup ${LIGHT_GREEN}successful${NC}.\n"
else
  printf "${RED}Error${NC} occurred while uploading archive. Please investigate.\n"
fi
