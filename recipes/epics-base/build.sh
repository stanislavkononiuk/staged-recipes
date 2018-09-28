#!/bin/bash
install -d $PREFIX/bin
install -d $PREFIX/lib
install -d $PREFIX/epics

# export EPICS_HOST_ARCH as determined
EPICS_HOST_ARCH=$(perl src/tools/EpicsHostArch.pl)
export EPICS_HOST_ARCH

# EPICS assumes gcc suit has /usr/bin prefix.
# If non-system gcc is used, e.g. rh-devtoolset,
# find out its location /opt/rh/devtoolset-2/root/usr/bin.
# GNG_DIR has "bin" stripped.
GNU_DIR=$(dirname $(dirname $(which gcc)))
if [ "$GNU_DIR" != "/usr" ]; then
    echo "GNU_DIR="$GNU_DIR >> configure/CONFIG_COMMON
fi

make -j$(getconf _NPROCESSORS_ONLN)

EPICS_BASE=$PREFIX/epics

# Copy libraries into $PREFIX/lib
cp -av $PREFIX/epics/lib/$EPICS_HOST_ARCH/lib*so* $PREFIX/lib 2>/dev/null || : # linux
cp -av $PREFIX/epics/lib/$EPICS_HOST_ARCH/lib*dylib* $PREFIX/lib 2>/dev/null || :  # osx

# deal with env export
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

ACTIVATE=$PREFIX/etc/conda/activate.d/epics_base.sh
DEACTIVATE=$PREFIX/etc/conda/deactivate.d/epics_base.sh
ETC=$PREFIX/etc

# set up
echo "export EPICS_BASE="$EPICS_BASE >> $ACTIVATE
echo "export EPICS_HOST_ARCH="$EPICS_HOST_ARCH >> $ACTIVATE

# tear down
echo "unset EPICS_BASE" >> $DEACTIVATE
echo "unset EPICS_HOST_ARCH" >> $DEACTIVATE

# clean up after self
unset ACTIVATE
unset DEACTIVATE
unset ETC
