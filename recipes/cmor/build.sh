export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"


./configure \
    --with-python=${PREFIX}   \
    --with-uuid=${PREFIX} \
    --with-udunits2=${PREFIX} \
    --with-netcdf=${PREFIX} \
    --with-libjson-c=${PREFIX} \
    --prefix=${PREFIX}
make
make install
## END BUILD

