#!/usr/bin/env bash
# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"

# Needed to get appropriate response to g_get_system_data_dirs():
export CFLAGS="-DCONDA_SYSTEM_DATA_DIRS=\\\"${PREFIX}/share\\\""

if [ "$(uname)" == "Darwin" ] ; then
  # for Mac OSX
  export CC=clang
  export CXX=clang++
  # Cf. the discussion in meta.yaml -- we require 10.7.
  export MACOSX_DEPLOYMENT_TARGET="10.7"
  sdk=/
  export CFLAGS="${CFLAGS} -isysroot ${sdk}"
  export LDFLAGS="${LDFLAGS} -Wl,-syslibroot,${sdk}"

  # Pick up the Conda version of gettext/libintl:
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
else
  # for linux
  export CC=
  export CXX=
fi

./configure --prefix=${PREFIX} || { cat config.log ; exit 1 ; }
make
make install
