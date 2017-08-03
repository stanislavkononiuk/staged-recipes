#!/bin/bash

set -x -e 

export OPENSSL_PREFIX=${PREFIX}

export PERL_MM_USE_DEFAULT=1

if [ `uname -s` == "Darwin" ]; then
    # Force use of conda's OpenSSL instead of the system one
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    # Force use of conda's OpenSSL instead of the system one
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi


cpanm --installdeps .
# If it has Build.PL use that, otherwise use Makefile.PL
# Hostname tests fail
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    #./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
