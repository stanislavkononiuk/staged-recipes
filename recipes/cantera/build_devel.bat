ECHO ************************
ECHO DEVEL BUILD STARTED
ECHO ************************

DEL /F cantera.conf

COPY "%RECIPE_DIR%\cantera_base.conf" cantera.conf
ECHO msvc_version='14.1' >> cantera.conf

SET "CANTERA_PATH_SEP=;"
CALL scons install

ECHO ************************
ECHO DEVEL BUILD COMPLETED SUCCESSFULLY
ECHO ************************
