if [[ $processor == "gpu" ]]; then
	enable_gpu=1
else
	enable_gpu=0
fi

mkdir build_gui && cd build_gui 

cmake -D PRISMATIC_ENABLE_GUI=1 \
	-D PRISMATIC_ENABLE_CLI=0 \
	-D PRISMATIC_ENABLE_GPU=$enable_gpu \
	-D PRISMATIC_ENABLE_PYPRISMATIC=0 \
	-D CMAKE_INSTALL_PREFIX=$PREFIX \
	-D CMAKE_PREFIX_PATH=${PREFIX} \
	../ 

make  -j${CPU_COUNT}

make install


