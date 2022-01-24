# Build tcplotter command-line utilities using cmake

# Configure to exit in the event of errors
set -e

# Change directories to source directory
cd $PKG_NAME

# Create build directory
cd src
mkdir build && cd build

# Build with cmake
cmake ..
cmake --build .

# Install executables to bin directory
cmake --install . --prefix=$PREFIX
