@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

rustc --version

cd %SRC_DIR%\wikibase

cargo build --release --verbose || exit 1

copy %SRC_DIR%\target\release\oxigraph_wikibase %SCRIPTS% || exit 1
