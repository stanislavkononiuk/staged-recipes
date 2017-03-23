#!/bin/bash

set -x

# Point to the right pkgconfig
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
# Add the build-dir's lib dir to the linker flags
export LDFLAGS="-L$PREFIX/lib"
# Add the build-dir's incude dir to the compiler flags
export CFLAGS="-I$PREFIX/include"

case `uname` in
    Darwin)
	# Make the linker add the directory to which our libs are installed
	# to the binaries rpath. This is fixed later on by conda build, but
	# ./configure builds and runs binaries, which fail spuriously
	# due to linking issues (leading to failure of detecting GNU malloc
	# compatible malloc).
	export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
	;;
esac

./configure --prefix="$PREFIX" --disable-dependency-tracking

make -j$CPU_COUNT

make install
