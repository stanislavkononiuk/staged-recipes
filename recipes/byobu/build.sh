set -euf 

./autogen.sh
./configure \
  --prefix=$PREFIX \

make 
make check
make install
