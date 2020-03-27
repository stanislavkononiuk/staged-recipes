#!/bin/bash

set -o errexit -o pipefail

mkdir -p "${PREFIX}"/aarch64-conda_cos7-linux-gnu/sysroot
if [[ -d usr/lib ]]; then
  if [[ ! -d lib ]]; then
    ln -s usr/lib lib
  fi
fi
if [[ -d usr/lib64 ]]; then
  if [[ ! -d lib64 ]]; then
    ln -s usr/lib64 lib64
  fi
fi
pushd "${PREFIX}"/aarch64-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .

pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/usr/share/java-utils/
  rm -f abs2rel.sh
  ln -s ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/usr/bin/abs2rel abs2rel.sh
popd
