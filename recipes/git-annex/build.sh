#!/bin/sh

set -e -o pipefail -x

echo BUILDING GIT ANNEX

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

export CPPFLAGS=-I${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib64 -L${PREFIX}/lib"

echo prefix is $PREFIX
echo env is
env

export STACK_ROOT=$PACKAGE_HOME/stackroot
mkdir -p $STACK_ROOT
#install_cabal_package --constraint 'fingertree<0.1.2.0' --constraint 'aws<0.17' --allow-newer=aws:time

echo >> stack.yaml
echo "local-bin-path: $PREFIX" >> stack.yaml
echo "extra-include-dirs:" >> stack.yaml
echo "- $PREFIX/include" >> stack.yaml
echo "extra-lib-dirs:" >> stack.yaml
echo "- $PREFIX/lib64" >> stack.yaml
echo "- $PREFIX/lib" >> stack.yaml

echo "STACK YAML IS"
cat stack.yaml

stack setup
stack path
stack install --cabal-verbose
