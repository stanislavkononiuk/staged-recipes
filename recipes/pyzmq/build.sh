#!/bin/bash

export DYLD_LIBRARY_PATH="$PREFIX/lib:$DYLD_LIBRARY_PATH"

"$PYTHON" setup.py configure --zmq "$PREFIX"

"$PYTHON" setup.py install
