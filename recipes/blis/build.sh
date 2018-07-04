case `uname` in
    Darwin)
        ln -s $CC $BUILD_PREFIX/clang
        export CC=$BUILD_PREFIX/clang
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX x86_64
        make CC_VENDOR=clang -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    Linux)
        ln -s $CC $BUILD_PREFIX/gcc
        export CC=$BUILD_PREFIX/gcc
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX x86_64
        make CC_VENDOR=gcc -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    MINGW*)
        export CC="$PREFIX/Library/bin/clang"
        export PATH="$PREFIX/Library/bin:$PATH"
        export RANLIB=echo
        export LIBPTHREAD=-lpthreads
        export AS=llvm-as
        export CFLAGS="-MD -I$PREFIX/Library/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/Library/lib"
        clang --version
        llvm-as --version
        llvm-ar --version
        ./configure --disable-shared --prefix=$PREFIX/Library x86_64
        make CPICFLAGS= LIBPTHREAD=-lpthreads AR=llvm-ar LIBM= -j${CPU_COUNT}
        make install
        make check CPICFLAGS= LIBPTHREAD=-lpthreads AR=llvm-ar LIBM= -j${CPU_COUNT}
        mv $PREFIX/Library/lib/libblis.a $PREFIX/Library/lib/blis.lib
        ;;
esac
