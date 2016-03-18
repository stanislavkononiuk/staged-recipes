#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
IMAGE_NAME="pelson/obvious-ci:latest_x64"

config=$(cat <<CONDARC

channels:
 - conda-forge
 - defaults

show_channel_urls: True

CONDARC
)

cat << EOF | docker run \
                        -v ${REPO_ROOT}/recipes:/conda-recipes \
                        -a stdin -a stdout -a stderr \
			-i -t \
                        $IMAGE_NAME \
                        bash || exit $?

if [ "${BINSTAR_TOKEN}" ];then
    export BINSTAR_TOKEN=${BINSTAR_TOKEN}
fi

# Unused, but needed by conda-build currently... :(
export CONDA_NPY='19'

export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artefacts.
conda clean --lock

conda update --yes conda conda-build
conda install --yes anaconda-client obvious-ci
conda install --yes conda-build-all

conda info
unset LANG

# These are some standard tools. But they aren't available to a recipe at this point (we need to figure out how a recipe should define OS level deps)
#yum install -y expat-devel git autoconf libtool texinfo check-devel

# These were specific to installing matplotlib. I really want to avoid doing this if possible, but in some cases it
# is inevitable (without re-implementing a full OS), so I also really want to ensure we can annotate our recipes to
# state the build dependencies at OS level, too.
yum install -y libXext libXrender libSM tk libX11-devel

# We don't need to build the example recipe.
rm -rf /conda-recipes/example

conda-build-all /conda-recipes --matrix-conditions "numpy >=1.8" "python >=2.7,<3|>=3.4"

EOF
