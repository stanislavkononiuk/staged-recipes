#!/bin/bash

set -ex

# clean up an existing cmake build directory
rm -rf build

# uncomment to debug cmake build
export CMAKE_VERBOSE_MAKEFILE=1

export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,--as-needed//g')"
export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')"
export LDFLAGS_LD="$(echo $LDFLAGS_LD | sed 's/-dead_strip_dylibs//g')"
export CXXFLAGS="$CXXFLAGS -Wno-deprecated-declarations"
export CFLAGS="$CFLAGS -Wno-deprecated-declarations"

if [[ "$target_platform" == "osx-64" ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
  export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
fi

# Dynamic libraries need to be lazily loaded so that torch
# can be imported on system without a GPU
# ^ is this the case for mmcv+cuda as well?
LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

export CMAKE_GENERATOR=Ninja
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$PREFIX
for ARG in $CMAKE_ARGS; do
  if [[ "$ARG" == "-DCMAKE_"* ]]; then
    cmake_arg=$(echo $ARG | cut -d= -f1)
    cmake_arg=$(echo $cmake_arg| cut -dD -f2-)
    cmake_val=$(echo $ARG | cut -d= -f2-)
    printf -v $cmake_arg "$cmake_val"
    export ${cmake_arg}
  fi
done
unset CMAKE_INSTALL_PREFIX
export TH_BINARY_BUILD=1

export USE_NINJA=OFF
export INSTALL_TEST=0
export BUILD_TEST=0


# [pytorch-feedstock] I don't know where this folder comes from, but it's interfering with the build in osx-64
rm -rf $PREFIX/git

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    export COMPILER_WORKS_EXITCODE=0
    export COMPILER_WORKS_EXITCODE__TRYRUN_OUTPUT=""
fi

# MacOS build is simple, and will not be for CUDA
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Produce macOS builds with torch.distributed support.
    # This is enabled by default on Linux, but disabled by default on macOS,
    # because it requires an non-bundled compile-time dependency (libuv
    # through gloo). This dependency is made available through meta.yaml, so
    # we can override the default and set USE_DISTRIBUTED=1.

    if [[ "$target_platform" == "osx-arm64" ]]; then
        export BLAS=OpenBLAS
        export USE_MKLDNN=0
        # There is a problem with pkg-config
        # See https://github.com/conda-forge/pkg-config-feedstock/issues/38
    fi
    $PYTHON -m pip install . --no-deps -vv
    exit 0
fi

export MAX_JOBS=${CPU_COUNT}
export MMCV_WITH_OPS=1

if [[ ${cuda_compiler_version} != "None" ]]; then
    export USE_CUDA=1
    if [[ ${cuda_compiler_version} == 9.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;7.0+PTX"
    elif [[ ${cuda_compiler_version} == 9.2* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0+PTX"
    elif [[ ${cuda_compiler_version} == 10.* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5+PTX"
    elif [[ ${cuda_compiler_version} == 11.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0+PTX"
    elif [[ ${cuda_compiler_version} == 11.1 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    elif [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    else
        echo "unsupported cuda version. edit build_pytorch.sh"
        exit 1
    fi
    export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
    export NCCL_ROOT_DIR=$PREFIX
    export NCCL_INCLUDE_DIR=$PREFIX/include
    export USE_SYSTEM_NCCL=1
    export USE_STATIC_NCCL=0
    export USE_STATIC_CUDNN=0
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
    export MAGMA_HOME="${PREFIX}"
else
    if [[ "$target_platform" == *-64 ]]; then
      export BLAS="MKL"
    fi
    export USE_CUDA=0
    export USE_MKLDNN=1
    export CMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake"
fi

export CMAKE_BUILD_TYPE=Release

$PYTHON -m pip install . --no-deps -vvv --no-clean