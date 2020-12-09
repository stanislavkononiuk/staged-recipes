echo "****************************"
echo "PYTHON ${PY_VER} BUILD STARTED"
echo "****************************"

set -x

# Remove old Python build files, if they're present
if [ -d "build/python" ]; then
    rm -r build/python
    rm -r build/temp-py
    rm interfaces/cython/setup.py
    rm -r interfaces/cython/build
    rm -r interfaces/cython/dist
    rm -r interfaces/cython/Cantera.egg-info
fi

test -f cantera.conf

scons build python_package='y' python_cmd="${PYTHON}"

echo "****************************"
echo "PYTHON ${PY_VER} BUILD COMPLETED SUCCESSFULLY"
echo "****************************"

cd interfaces/cython
$PYTHON setup.py build --build-lib=../../build/python install
