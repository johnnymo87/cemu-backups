# There's a problem with Breath of the Wild on macs where the workaround is to
# delete the shader cache everytime.
#
# https://github.com/cemu-project/Cemu/issues/396
function startCemuZelda {
  rm \
    ~/Code/Cemu/bin/shaderCache/driver/vk/00050000101c9400.bin \
    ~/Code/Cemu/bin/shaderCache/precompiled/00050000101c9400_spirv.bin
  ~/Code/Cemu/bin/Cemu_release
}

function backupJonathanZelda {
  BUCKET_PATH=jonathan-mohrbacher-cemu-01/breath-of-the-wild/jonathan \
    ARCHIVE_LIMIT=10 \
    ./backup.bash \
    ~/Documents/Cemu/mlc/usr/save/00050000/101c9400/user/
}

function backupLiviaZelda {
  BUCKET_PATH=jonathan-mohrbacher-cemu-01/breath-of-the-wild/livia \
    ARCHIVE_LIMIT=10 \
    ./backup.bash \
    ~/Documents/Cemu/mlc/usr/save/00050000/101c9400/user/
}

# param [$1] Name of the file in the s3 bucket
function restoreJonathanZelda {
  BUCKET_PATH=jonathan-mohrbacher-cemu-01/breath-of-the-wild/jonathan \
    ARCHIVE_NAME=$1 \
    ./restore.bash \
    ~/Documents/Cemu/mlc/usr/save/00050000/101c9400/user/
}

# param [$1] Name of the file in the s3 bucket
function restoreLiviaZelda {
  BUCKET_PATH=jonathan-mohrbacher-cemu-01/breath-of-the-wild/livia \
    ARCHIVE_NAME=$1 \
    ./restore.bash \
    ~/Documents/Cemu/mlc/usr/save/00050000/101c9400/user/
}

