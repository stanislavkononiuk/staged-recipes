./bootstrap.sh
./configure --datadir=$PREFIX/lib/libpostal_data --prefix=$PREFIX

make -j${CPU_COUNT}
make install
