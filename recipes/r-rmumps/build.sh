#!/bin/bash
set -o errexit -o pipefail
if [[ ${target_platform} =~ linux.* ]] || [[ ${target_platform} == win-32 ]] || [[ ${target_platform} == win-64 ]] || [[ ${target_platform} == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  ${R} CMD INSTALL --build .
else
  mkdir -p "${PREFIX}"/lib/R/library/rmumps
  mv ./* "${PREFIX}"/lib/R/library/rmumps
fi
