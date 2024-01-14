function backup {
  BUCKET_PATH=ryujinx-00 \
    ARCHIVE_LIMIT=10 \
    ./backup.bash \
    ~/Library/Application\ Support/Ryujinx/bis/user/ \
    ~/Library/Application\ Support/Ryujinx/bis/system/save/
}

# param [$1] Name of the file in the s3 bucket, e.g.
#   game-data-2023-09-04-16-35-59.zip
function restore {
  BUCKET_PATH=ryujinx-00 \
    ARCHIVE_NAME=$1 \
    ./restore.bash \
    ~/Library/Application\ Support/Ryujinx/bis/user/ \
    ~/Library/Application\ Support/Ryujinx/bis/system/save/
}
