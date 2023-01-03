#!/usr/bin/env bash

set -e

TMP_PATH="/tmp"
DEST_PATH="output"
TOOLKIT_VER="7.1"

mkdir -p "${DEST_PATH}"

if [ -f ./PLATFORMS ]; then
  #cp ./PLATFORMS PLATFORMS
  #cat ./PLATFROMS
  ls
else
  curl -sLO "https://github.com/fbelavenuto/arpl/raw/main/PLATFORMS"
fi

function compileLkm() {
  PLATFORM=$1
  KVER=$2
  OUT_PATH="${TMP_PATH}/${PLATFORM}"
  mkdir -p "${OUT_PATH}"
  sudo chmod 1777 "${OUT_PATH}"
  # Compile using docker
#  docker run --rm -t -v "${OUT_PATH}":/output -v "${PWD}":/input \
#    fbelavenuto/syno-toolkit:${PLATFORM}-${TOOLKIT_VER} compile-lkm
  docker run -u 1000 --rm -t -v "${OUT_PATH}":/output -v "${PWD}":/input \
    fbelavenuto/syno-compiler:${TOOLKIT_VER} compile-lkm ${PLATFORM}
  mv "${OUT_PATH}/redpill-dev.ko" "${DEST_PATH}/rp-${PLATFORM}-${KVER}-dev.ko"
  rm -f "${DEST_PATH}/rp-${PLATFORM}-${KVER}-dev.ko.gz"
  gzip "${DEST_PATH}/rp-${PLATFORM}-${KVER}-dev.ko"
  mv "${OUT_PATH}/redpill-prod.ko" "${DEST_PATH}/rp-${PLATFORM}-${KVER}-prod.ko"
  rm -f "${DEST_PATH}/rp-${PLATFORM}-${KVER}-prod.ko.gz"
  gzip "${DEST_PATH}/rp-${PLATFORM}-${KVER}-prod.ko"
  rm -rf "${OUT_PATH}"
}

# Main
docker pull fbelavenuto/syno-compiler:${TOOLKIT_VER}
while read PLATFORM KVER; do
#  docker pull fbelavenuto/syno-toolkit:${PLATFORM}-${TOOLKIT_VER}
  compileLkm "${PLATFORM}" "${KVER}" &
done < PLATFORMS
wait
