set "_bash_dir=%LIBRARY_PREFIX%\git-bash"
mkdir "%_bash_dir%" || exit 1
7za x PortableGit-%PKG_VERSION%-%ARCH%-bit.7z.exe -o"%_bash_dir%" -aoa || exit 1

copy "%_bash_dir%\LICENSE.txt" .\ || exit 1
set "_post=%_bash_dir%\etc\post-install"
patch -i "%RECIPE_DIR%\01-devices.post.patch" "%_post%\01-devices.post" || exit 1
patch -i "%RECIPE_DIR%\post-install.bat.patch" "%_bash_dir%\post-install.bat" || exit 1

set "_temp_post=%CD%\post-install"
mkdir "%_temp_post%" || exit 1
move "%_post%\06-windows-files.post" "%_temp_post%\" || exit 1
move "%_post%\99-post-install-cleanup.post" "%_temp_post%\" || exit 1

:: post-install:
set "_CWD=%CD%"
cd /d "%_bash_dir%" || exit 1
.\git-bash.exe --no-needs-console --hide --no-cd --command=post-install.bat || exit 1
cd /d "%_CWD%" || exit 1
::

rmdir /s "%_post%" || exit 1
move "%_temp_post%" "%_bash_dir%\etc\" || exit 1

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin" || exit 1
copy "%RECIPE_DIR%\bash.bat" "%PREFIX%\bin\" || exit 1
copy "%RECIPE_DIR%\git-bash.bat" "%PREFIX%\bin\" || exit 1
