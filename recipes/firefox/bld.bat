if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1

:: https://support.mozilla.org/en-US/kb/deploy-firefox-msi-installers
start "Install Firefox MSI" /wait msiexec.exe /i firefox.msi INSTALL_DIRECTORY_PATH=%LIBRARY_BIN% TASKBAR_SHORTCUT=false DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false /quiet || exit 1
