#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
IMAGE_NAME="condaforge/linux-anvil"

config=$(cat <<CONDARC

channels:
 - conda-forge
 - defaults

always_yes: true
show_channel_urls: true

CONDARC
)

cat << EOF | docker run -i \
                        -v ${REPO_ROOT}/recipes:/conda-recipes \
                        -a stdin -a stdout -a stderr \
                        $IMAGE_NAME \
                        bash || exit $?

if [ "${BINSTAR_TOKEN}" ];then
    export BINSTAR_TOKEN=${BINSTAR_TOKEN}
fi

# Unused, but needed by conda-build currently... :(
export CONDA_NPY='19'

# MAKEFLAGS is passed through conda build: https://github.com/conda/conda-build/pull/917
# 2 cores are available: https://discuss.circleci.com/t/what-runs-on-the-node-container-by-default/1443
export MAKEFLAGS="-j2 ${MAKEFLAGS}"

export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artefacts.
conda clean --lock

conda update conda conda-build
conda install anaconda-client conda-build-all
conda info

# We don't need to build the example recipe.
rm -rf /conda-recipes/example

# yum installs anything from a "yum_requirements.txt" file that isn't a blank line or comment.
find conda-recipes -mindepth 2 -maxdepth 2 -type f -name "yum_requirements.txt" \
    | xargs -n1 cat | grep -v -e "^#" -e "^$" | \
    xargs -r yum install -y

conda-build-all /conda-recipes --matrix-conditions "numpy >=1.9" "python >=2.7,<3|>=3.4"

EOF
