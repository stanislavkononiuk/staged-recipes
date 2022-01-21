mkdir build
cd ./build

cmake .. -LAH -G "Ninja" \
-Wno-dev \
-DCMAKE_BUILD_TYPE:STRING="Release" \
-DUSE_SYSTEM_VTK:BOOL=ON \
-DUSE_SYSTEM_ITK:BOOL=ON \
-DVMTK_BUILD_TESTING:BOOL=ON \
-DSUPERBUILD_INSTALL_PREFIX:STRING=${PREFIX} \
-DPython3_FIND_STRATEGY=LOCATION \
-DPython3_ROOT_DIR=${PREFIX} \
-DPython3_EXECUTABLE=${PREFIX}/bin/python \
-DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
-DCMAKE_CXX_STANDARD=11 \
-DCMAKE_CXX_STANDARD_REQUIRED=ON \
-DCMAKE_CXX_EXTENSIONS=OFF \
-DVMTK_MODULE_INSTALL_LIB_DIR:STRING="${PREFIX}/vmtk" \
-DINSTALL_PKGCONFIG_DIR:STRING="${PREFIX}/lib/pkgconfig" \
-DGIT_PROTOCOL_HTTPS:BOOL=ON \
-DVMTK_USE_RENDERING:BOOL=ON \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DVMTK_MINIMAL_INSTALL:BOOL=OFF \
-DVMTK_USE_VTK9:BOOL:BOOL=ON \
-DVMTK_CONTRIB_SCRIPTS:BOOL=ON \
-DVMTK_SCRIPTS_ENABLED:BOOL=ON \
-DVMTK_ENABLE_DISTRIBUTION:BOOL=OFF \
-DVMTK_WITH_LIBRARY_VERSION:BOOL=OFF \
-DVMTK_USE_SUPERBUILD:BOOL=OFF \
-DVTK_VMTK_WRAP_PYTHON:BOOL=ON \
-DVMTK_PYTHON_VERSION:STRING="python${PY_VER}" \
-DITK_LEGACY_SILENT:BOOL=ON \
-DVTK_LEGACY_SILENT:BOOL=ON \
-DCMAKE_CXX_STANDARD=11 \
-DCMAKE_CXX_STANDARD_REQUIRED=ON \
-DBUILD_DOCUMENTATION:BOOL=OFF 

ninja install 