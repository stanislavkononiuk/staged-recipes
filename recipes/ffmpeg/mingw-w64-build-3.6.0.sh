#!/bin/bash

script_ver='3.6.0'
################################################################################
# MingGW-w64 Build Script
################################################################################
# Copyright (C) 2011-2014  Kyle Schwarz
# 
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
#
# The GNU General Public License can be found at the end of this file.
#
# Written by Kyle Schwarz, report any bugs to <kyle.r.schwarz@gmail.com>
#
# This script will build MinGW-w64 for Win32 and Win64.
# 
# This version will build the following packages into the toolchain:
#   mingw-w64
#   gmp
#   mpfr
#   mpc
#   isl
#   cloog
#   binutils
#   gcc
################################################################################

about () {
clear
read -p \
"################################################################################
#                                                                              #
#                        MingGW-w64 Build Script $script_ver                         #
#                                                                              #
#                                                                              #
#            This script will build MinGW-w64 for Win32 and Win64.             #
#                                                                              #
#      This version will build the following packages into the toolchain       #
#                                                                              #
#          mingw-w64                        gmp                                #
#                                                                              #
#          mpfr                             mpc                                #
#                                                                              #
#          isl                              cloog                              #
#                                                                              #
#          binutils                         gcc                                #
#                                                                              #
#                                                                              #
#                            Press Enter to continue                           #
#                                                                              #
#                     Copyright (C) 2011-1013 Kyle Schwarz                     #
#                This program comes with ABSOLUTELY NO WARRANTY                #
#                                                                              #
################################################################################"
}

# Variables
working_dir="$(pwd)"
detected_cpu_count="$(grep -c processor /proc/cpuinfo)"
uname_m="$(uname -m)"
target_i686='i686-w64-mingw32'
target_x86_64='x86_64-w64-mingw32'

## Versions
mingw_w64_release_ver='3.1.0'
gcc_release_ver='4.9.0'
gcc_old_release_ver='4.8.3'
mpfr_release_ver='3.1.2'
mpc_release_ver='1.0.2'
binutils_release_ver='2.24'
gmp_release_ver='6.0.0a'
isl_release_ver='0.11.1'
cloog_release_ver='0.18.0'
pthreads_w32_release_ver='2-9-1'

## Locations
mingw_w64_source_dir="$working_dir/source"
mingw_w64_build_dir="$working_dir/build"
pkgs_dir="$working_dir/pkgs"

## Prefixes
mingw_w64_i686_prefix="$working_dir/mingw-w64-i686"
mingw_w64_x86_64_prefix="$working_dir/mingw-w64-x86_64"

display_help () {
cat <<EOF
Compile MinGW-w64 as a cross-toolchain for Win32 or Win64

Run options other than compiling (./mingw-w64-build-$script_ver OPTION):
  wipe    removes all MinGW-w64 files in the directory (build build.log 
          mingw-w64-i686 mingw-w64-x86_64 pkgs source)

Available options are specified in parentheses.

Defaults for the options are specified in brackets.

General:
  -h, --help     display this help and exit
  -a, --about    display the "About" page
  -V, --version  display version information and exit

Compile Options:
  --build-type=TYPE           compile for TYPE (win32, win64, multi)
  --default-configure         compile with default options for all unset options
  --allow-overwrite           allow overwrite if no updates are found
  --rebuild-all               rebuild all packages
  --mingw-w64-ver=NUMBER      compile with MinGW-w64 VERSION ($mingw_w64_release_ver, svn)
                              [$mingw_w64_release_ver]
  --cpu-count=NUMBER          use NUMBER of cores/threads to compile with (1-$detected_cpu_count,
                              max) [max]
  --binutils-ver=VERSION      compile with binutils VERSION (snapshot, $binutils_release_ver,
                              cvs) [$binutils_release_ver]
  --gcc-ver=VERSION           compile with GCC VERSION ($gcc_release_ver, $gcc_old_release_ver, svn)
                              [$gcc_old_release_ver]
  --pthreads-w32-ver=VERSION  compile with Pthreads-w32 VERSION ($pthreads_w32_release_ver, cvs)
                              [cvs]
  --gcc-langs=LANG1,LANG2     compile GCC with support for LANG (ada, c, c++,
                              fortran, go, java, objc, obj-c++, all) [c,c++,lto]
  --enable-nls                enable "Native Language Support"
  --disable-shared            compile a static only toolchain
  --threads=LIB               compile with support for thread LIB (winpthreads,
                              pthreads-w32, disable) [pthreads-w32]
  --clean-build               remove the unneeded directories after a successful
                              compile, leaving only the built toolchain. The 
                              'build', 'source', and 'packages' directories will
                              be removed. 
  --enable-gendef             compile the MinGW-w64 tools gendef.
  --verbose                   show raw build output

Report bugs to <kyle.r.schwarz@gmail.com>.
EOF
}

print_error ()
{
  printf '\n\nError. See build.log for more details\n\n'
  exit 1
}

yes_no_sel () {
local usr_input
local question="$1"
shift
while [[ "$usr_input" != [YyNn] ]]; do
  printf '%s [y/n]: ' "$question"
  read usr_input
  if [[ "$usr_input" != [YyNn] ]]; then
    printf '\nYour selection was not vaild, please try again.\n\n'
  fi
done
case "$usr_input" in
  [Yy] ) return 0 ;;
  [Nn] ) return 1 ;;
esac
}

var_in_array() {
local var=$1
local array
shift
for array; do
  [[ $var = "$array" ]] && return
done
return 1
}

create_pkg_dirs () {
local pkg_name="$1"
mkdir -p "$pkg_name"
cd "$pkg_name" || exit 1
mkdir -p 'build' 'source'
cd 'source' || exit 1
}

use_cpu_count () {
if [[ "$cpu_count" -ge '2' ]]; then
  while [[ "$select_cpu_count" != [1-$cpu_count] ]]; do
    printf '\nA total of %d cores/threads were found. How many would you like to use to compile MinGW-w64? You can set this option with: "--cpu-count=NUMBER", see --help for more information. [1-%d]: ' "$detected_cpu_count" "$detected_cpu_count"
    read select_cpu_count
  done
  cpu_count="$select_cpu_count"
fi

if [[ "$cpu_count" -lt '1' ]]; then
  if yes_no_sel 'The number of cores/threads could not be found, would you like to manually enter the number of cores/threads your CPU has? (If "n" is selected, one core/thread will be used).'; then
    printf '\nPlease enter the number of cores/threads your CPU has. (Make sure the number you enter is correct, trying to use more cores/threads than your CPU has can cause your system to crash).: '
    read cpu_count
  else
    cpu_count='1'
  fi
fi
}

pkg_touch_success () {
local pkg_name="$1"
local pkg_ver="$2"
local pkg_state="$3"
local pkg_arch="$4"
shift 4
mkdir -p "$pkgs_dir/touch-files/$pkg_name"
touch "$pkgs_dir/touch-files/$pkg_name/$pkg_name-$pkg_ver-$pkg_arch.$pkg_state"
}

check_pkg_touch_success () {
local pkg_name="$1"
local pkg_ver="$2"
local pkg_state="$3"
local pkg_arch="$4"
shift 4

if [[ -f "$pkgs_dir/touch-files/$pkg_name/$pkg_name-$pkg_ver-$pkg_arch.$pkg_state" ]]; then
  return 0
fi
return 1
}

build_progress ()
{
if [[ "$verbose" != 'yes' ]]; then
  if [[ "$1" = 'Done' ]]; then
    printf '%s\n' "$1"
    return 0
  fi

  local step_function="$1"
  local step_name="$2"
  shift 2
 
  printf '[%d/%d]: %s %s... ' "$current_step" "$total_steps" "$step_name" "$step_function"
  ((current_step++))
fi
}

build_log ()
{  
  if [[ "$verbose" = 'yes' ]]; then
    tee -a "$working_dir/build.log"
  else
    cat >>"$working_dir/build.log"
  fi
}

choose_mingw_w64_ver () {
while [[ "$mingw_w64_ver_select" != [1-2] ]]; do
cat <<EOF

Which MinGW-w64 version would you like to build? You can set this option with: '--mingw-w64-ver=NUMBER', see --help for more information.
  1. MinGW-w64 $mingw_w64_release_ver 
  2. MinGW-w64 SVN (default)
EOF
printf 'Choose which MinGW-w64 version would would like to build. [1-2]: '
read mingw_w64_ver_select
case "$mingw_w64_ver_select" in
  1 ) mingw_w64_ver="$mingw_w64_release_ver" ;;
  2 ) mingw_w64_ver='svn' ;;
  * ) printf '\nYour selection was not valid, please try again.\n\n' ;;
esac
done
}

choose_binutils_ver () {
while [[ "$binutils_ver_select" != [1-3] ]]; do
cat <<EOF

Which Binutils version would you like to build? You can set this option with: '--binutils-ver=VERSION', see --help for more information.
  1. Binutils snapshot
  2. Binutils $binutils_release_ver (default)
  3. Binutils cvs
EOF
printf 'Choose which Binutils version would would like to build. [1-2]: '
read binutils_ver_select
case "$binutils_ver_select" in
  1 ) binutils_ver="snapshot" ;;
  2 ) binutils_ver="$binutils_release_ver" ;;
  3 ) binutils_ver='cvs' ;;
  * ) printf '\nYour selection was not valid, please try again.\n\n' ;;
esac
done
}

choose_gcc_ver () {
while [[ "$gcc_ver_select" != [1-4] ]]; do
cat <<EOF

Which GCC version would you like to build? You can set this option with: '--gcc-ver=VERSION', see --help for more information.
  1. GCC $gcc_release_ver
  2. GCC $gcc_old_release_ver (default)
  3. GCC $svn
EOF
printf 'Choose which GCC version would would like to build. [1-3]: '
read gcc_ver_select
case "$gcc_ver_select" in
  1 ) gcc_ver="$gcc_release_ver" ;;
  2 ) gcc_ver="$gcc_old_release_ver" ;;
  3 ) gcc_ver='svn' ;;
  * ) printf '\nYour selection was not valid, please try again.\n\n' ;;
esac
done
}

configure_gcc () {
if [[ "$enabled_langs" != *,* ]]; then
  printf -v enabled_langs '%s,' "${enabled_langs[@]}"
  enabled_langs="${enabled_langs%,}"
fi

case "$gcc_ver" in
  * ) "../source/gcc-$gcc_ver/configure" --build="$system_type" --target="$mingw_w64_target"  "${static_build[@]}" "${disable_nls[@]}" --disable-multilib --prefix="$mingw_w64_prefix" --with-sysroot="$mingw_w64_prefix" --with-mpc="$mpc_prefix" --with-mpfr="$mpfr_prefix" --with-gmp="$gmp_prefix"  --with-host-libstdcxx="-lstdc++ ${gcc_stdcxx_flags[*]}" --with-cloog="$cloog_prefix" --with-isl="$isl_prefix" --enable-languages="$enabled_langs" --enable-threads=win32 --enable-fully-dynamic-string --enable-lto  > >(build_log) 2>&1 || exit 1 ;;
esac
}

choose_static_build () {
if yes_no_sel "Would you like to build a fully static build? You can set this option with: '--disable-shared', see --help for more information. (Select \"n\" if you are not sure, \"n\" is the default)."; then
  static_build=('--disable-shared' '--enable-static')
else
  static_build=('--enable-shared' '--disable-static')
fi
}

choose_disable_nls () {
if yes_no_sel "Would you like to disable NLS support? Native Language Support (NLS), which lets GCC/Binutils output diagnostics in languages other than American English. You can set this option with: '--disable-nls', see --help for more information. (Select \"y\" if you are not sure, \"y\" is the default)."; then
  disable_nls=('--disable-nls')
else
  disable_nls=('--enable-nls')
fi
}

choose_lang_sel () {
if yes_no_sel "Would you like to manualy configure which languages GCC will support? You can set this option with: '--gcc-langs=LANG1,LANG2', see --help for more information. (if \"n\" is input only C and C++ will be enabled)."; then
  set_langs
else
  enabled_langs=('c' 'c++')
fi
}

set_langs () {
all_langs=('ada' 'c' 'c++' 'fortran' 'go' 'java' 'objc' 'obj-c++')
formated_langs=('Ada' 'C' 'C++' 'Fortran' 'Go' 'Java' 'Objective-C' 'Objective-C++')

cat <<'EOF'
Choose which languages you would like GCC to support.
  1. C and C++ (default)
  2. All detected
  3. Manually choose for each language.
EOF
printf 'Input your choice [1-3]: '
read sel_set_langs
case "$sel_set_langs" in
  1 ) enabled_langs=('c' 'c++')
      clear
      confirm_langs ;;
  2 ) enabled_langs=('all')
      clear
      confirm_langs ;;
  3 ) custom_langs ;;
  * ) printf '\nYour selection was not vaild, please try again.\n\n'
      set_langs
esac
}

custom_langs () {
unset enabled_langs
local num='0'
for lang in "${formated_langs[@]}"; do
  if yes_no_sel "Would you like to build GCC with $lang support?"; then
    enabled_langs=("${enabled_langs[@]}" "${all_langs[$num]}")
  fi
  ((num++))
done
confirm_langs
}

confirm_langs () {
if [[ "$enabled_langs" = 'all' ]]; then
  printf 'GCC will attempt to detect and build all of the following languages. It will silently disable the languages it can not find. (A "*" indicates that GCC will attempt to support the language).\n'
else
  printf 'The following languages will be supported in GCC. If one of the selected languages can not be found on your system when GCC is built it will fail and you will need to rerun this script after you have installed the failed language. (A "*" indicates that GCC will support the language).\n'
fi

local num='0'
for lang in "${all_langs[@]}"; do
  if var_in_array "$lang" "${enabled_langs[@]}" || [[ "${enabled_langs}" = 'all' ]]; then
    printf '  [*] %s\n' "${formated_langs[$num]}"
  else
    printf '  [ ] %s\n' "${formated_langs[$num]}"
  fi
  ((num++))
done

printf 'Are the languages selected correct? (if "n" is selected, you will be allowed to reconfigure you language selection). [y/n]: '
read user_input
case "$user_input" in
  [Nn] ) clear
         unset enabled_langs
         set_langs ;;
  [Yy] ) ;;
  *    ) printf '\nYour selection was not valid, please try again.\n\n'
         confirm_langs ;;
esac
}

configure_build_fn () {
if yes_no_sel 'Would you like to manually choose which package versions to build into MinGW-w64 yourself, and configure the build?'; then
  if [[ -z "$mingw_w64_ver" ]]; then
    choose_mingw_w64_ver
  fi
  if [[ -z "$binutils_ver" ]]; then
    choose_binutils_ver
  fi
  if [[ -z "$gcc_ver" ]]; then
    choose_gcc_ver
  fi
  if [[ -z "$static_build" ]]; then
    choose_static_build
  fi
  if [[ -z "$disable_nls" ]]; then
    choose_disable_nls
  fi
  if [[ -z "$enabled_langs" ]]; then
    choose_lang_sel
  fi
  default_configure
else
  default_configure
fi
}

default_configure () {
default_config='yes'
if [[ -z "$mingw_w64_ver" ]]; then
  mingw_w64_ver="$mingw_w64_release_ver"
fi
if [[ -z "$binutils_ver" ]]; then
  binutils_ver="$binutils_release_ver"
fi
if [[ -z "$gcc_ver" ]]; then
  gcc_ver="$gcc_old_release_ver"
fi
if [[ -z "$disable_nls" ]]; then
  disable_nls=('--disable-nls')
fi
if [[ -z "$enabled_langs" ]]; then
  enabled_langs=('c' 'c++')
fi
if [[ -z "$thread_lib" ]]; then
  thread_lib='pthreads-w32'
fi
if [[ -z "$cpu_count" ]]; then
  cpu_count="$detected_cpu_count"
fi
}

download_extract () {
local download_urls=("$1" "$2")
shift 2 


for download_url in "${download_urls[@]}"; do
archive="${download_url##*/}"
package_name="${archive%.tar*}"
if [[ -d "$package_name" ]]; then
  return 0
fi

case "$archive" in
  *.tar.gz ) archive_type='gzip' ;;
  *.tar.bz2 ) archive_type='bzip2' ;;
  *.tar.xz ) archive_type='xz' ;;
esac
if [[ ! -f "$archive" ]]; then
  build_progress "$archive" 'Downloading'
  wget -nv -t 5 "$download_url" > >(build_log) 2>&1
  build_progress 'Done'
fi

if [[ ! -d "$package_name" ]]; then
  build_progress "$archive" 'Extracting'
  if "$archive_type" -d <"$archive" | pax -r ; then
    build_progress 'Done'
    return 0
  else
    rm -rf "$archive" "$package_name"
    build_progress "$archive" 'Downloading'
    wget -nv "$download_url" > >(build_log) 2>&1
    build_progress 'Done'
    build_progress "$archive" 'Extracting'
    "$archive_type" -d <"$archive" | pax -r
    build_progress 'Done'
  fi
fi
done

if [[ ! -d "$package_name" ]]; then
  exit 1
fi
}

clean_build () {
cd '..'
rm -fr 'build' || exit 1
mkdir -p 'build'
cd 'build' || exit 1
}

build_winpthreads () {
cd "$mingw_w64_build_dir" || exit 1
rm -fr 'winpthreads '
mkdir -p 'winpthreads'
cd 'winpthreads' || exit 1
local mingw_w64_target="$1"
local mingw_w64_prefix="$2"
shift 3
build_progress 'winpthreads' 'Configuring'
"../../source/mingw-w64-$mingw_w64_ver/mingw-w64-libraries/winpthreads/configure" --build="$system_type" --host="$mingw_w64_target" "${static_build[@]}" --prefix="$mingw_w64_prefix" > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'winpthreads' 'Building'
make > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'winpthreads' 'Installing'
make install > >(build_log) 2>&1 || exit 1
build_progress 'Done'
}

build_binutils () {
cd "$pkgs_dir" || exit 1
create_pkg_dirs 'binutils' || exit 1
if [[ "$binutils_ver" != 'cvs' ]]; then
  if [[ "$binutils_ver" = "snapshot" ]]; then
    download_extract "ftp://sourceware.org/pub/binutils/snapshots/binutils.tar.bz2"
    binutils_ver="$(find . -name binutils -type d)"; binutils_ver="${binutils_ver##*-}"; binutils_ver="${binutils_ver%%/*}"
  else
    download_extract "http://ftp.gnu.org/gnu/binutils/binutils-$binutils_ver.tar.bz2" "ftp://ftp.gnu.org/gnu/binutils/binutils-$binutils_ver.tar.bz2"
  fi
else
  if [[ -d 'binutils-cvs' ]]; then
    cd 'binutils-cvs' || exit 1
    read -r oldmd5 _ < <(md5sum './CVS/Entries')
    build_progress 'binutils-cvs' 'Updating'
    cvs update || exit 1
    build_progress 'Done'
    read -r newmd5 _ < <(md5sum './CVS/Entries')
    if [[ "$oldmd5" != "$newmd5" ]]; then
      rm -rf "$pkgs_dir/touch-files/binutils/binutils-cvs-$uname_m."*
    fi
    cd '..'
  else
    build_progress 'binutils-cvs' 'Downloading'
    cvs -d :pserver:anoncvs@sourceware.org:/cvs/src checkout binutils > >(build_log) 2>&1 || exit 1
    build_progress 'Done'    
    mv 'src' 'binutils-cvs'
  fi
fi

cd '../build' || exit 1

mkdir -p "$mingw_w64_target"
cd "$mingw_w64_target" || exit 1

if ! check_pkg_touch_success 'binutils' "$binutils_ver" 'configure' "$mingw_w64_target"; then
  cd '..'
  rm -rf "$mingw_w64_target" || exit 1
  mkdir "$mingw_w64_target"
  cd "$mingw_w64_target" || exit 1
  build_progress 'binutils' 'Configuring'
  CC=gcc "../../source/binutils-$binutils_ver/configure" --build="$system_type" --target="$mingw_w64_target" "${static_build[@]}" "${disable_nls[@]}" --disable-multilib --with-sysroot="$mingw_w64_prefix" --prefix="$mingw_w64_prefix" > >(build_log) 2>&1 || exit 1
  build_progress 'Done'
fi
pkg_touch_success 'binutils' "$binutils_ver" 'configure' "$mingw_w64_target"
if ! check_pkg_touch_success 'binutils' "$binutils_ver" 'compile' "$mingw_w64_target"; then
  build_progress 'binutils' 'Building'  
  make -j "$cpu_count" > >(build_log) 2>&1 || exit 1
  build_progress 'Done'
fi
pkg_touch_success 'binutils' "$binutils_ver" 'compile' "$mingw_w64_target"
build_progress 'binutils' 'Installing'  
make install > >(build_log) 2>&1 || exit 1
build_progress 'Done'
}

std_compile ()
{
  local pkg="$1"
  local ver="$2"
  local url="$3"
  shift 3

  if check_pkg_touch_success "$pkg" "$ver" 'install' "$uname_m"; then
    return
  fi

  cd "$pkgs_dir" || exit 1
  create_pkg_dirs "$pkg" || exit 1

  download_extract "$url"

  if ! check_pkg_touch_success "$pkg" "$ver" 'configure' "$uname_m"; then
    clean_build
    build_progress "$pkg" 'Configuring'
    $@ > >(build_log) 2>&1 || print_error
    build_progress 'Done'
  fi
  pkg_touch_success "$pkg" "$ver" 'configure' "$uname_m"

  if ! check_pkg_touch_success "$pkg" "$ver" 'compile' "$uname_m"; then
    build_progress "$pkg" 'Building'
    make -j "$cpu_count" > >(build_log) 2>&1 || print_error
    build_progress 'Done'
  fi
  pkg_touch_success "$pkg" "$ver" 'compile' "$uname_m"

  if ! check_pkg_touch_success "$pkg" "$ver" 'install' "$uname_m"; then
    build_progress "$pkg" 'Installing'
    make install > >(build_log) 2>&1 || print_error
    build_progress 'Done'
  fi
  pkg_touch_success "$pkg" "$ver" 'install' "$uname_m"
}

build_mingw_w64 () {
local mingw_w64_target="$1"
local mingw_w64_prefix="$2"
shift 2
if [[ "$rebuild" = 'yes' ]]; then
  rm -rf "$pkgs_dir/touch-files"
fi
cd "$working_dir" || exit 1
rm -fr "$mingw_w64_prefix"
cd 'pkgs' || exit 1
mkdir -p 'touch-files'

build_binutils

export PATH="$mingw_w64_prefix/bin:$PATH"
cd "$mingw_w64_build_dir" || exit 1
clean_build
mkdir -p 'headers' 'crt'
cd 'headers' || exit 1

build_progress 'mingw-w64 headers' 'Configuring'
"$mingw_w64_source_dir/mingw-w64-$mingw_w64_ver/mingw-w64-headers/configure" --enable-sdk=all --build="$system_type" --host="$mingw_w64_target" --prefix="$mingw_w64_prefix" > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'mingw-w64 headers' 'Installing'
make install > >(build_log) 2>&1 || exit 1
build_progress 'Done'

cd "$mingw_w64_prefix" || exit 1
ln -s "./$mingw_w64_target" './mingw'
if [[ ! -d "./$mingw_w64_target/include" ]]; then
  cd "./$mingw_w64_target" || exit 1
  ln -s '../include' './include'
  cd "$mingw_w64_prefix" || exit 1
fi

case "$gcc_ver" in
  $gcc_release_ver ) cloog_ver='0.18.1'; isl_ver='0.12.2' ;;
  $gcc_old_release_ver ) cloog_ver='0.18.0';  isl_ver='0.11.1' ;;
esac

mpfr_prefix="$pkgs_dir/mpfr/mpfr-$mpfr_release_ver-$uname_m"
mpc_prefix="$pkgs_dir/mpc/mpc-$mpc_release_ver-$uname_m"
cloog_prefix="$pkgs_dir/cloog/cloog-$cloog_ver-$uname_m"
isl_prefix="$pkgs_dir/isl/isl-$isl_ver-$uname_m"
gmp_prefix="$pkgs_dir/gmp/gmp-$gmp_release_ver-$uname_m"

if [[ -n $CC ]]; then
  old_cc="$CC"
  export CC=gcc
fi

# Build gmp
std_compile 'gmp' "$gmp_release_ver" "http://ftp.gnu.org/gnu/gmp/gmp-$gmp_release_ver.tar.xz" "../source/gmp-6.0.0/configure" --build="$system_type" --prefix="$gmp_prefix" --enable-fat --disable-shared --enable-static --enable-cxx CPPFLAGS='-fexceptions'

#build mpfr
std_compile 'mpfr' "$mpfr_release_ver" "http://ftp.gnu.org/gnu/mpfr/mpfr-$mpfr_release_ver.tar.xz" "../source/mpfr-$mpfr_release_ver/configure" --build="$system_type" --prefix="$mpfr_prefix" --disable-shared --enable-static --with-gmp="$gmp_prefix"

#build mpc
std_compile 'mpc' "$mpc_release_ver" "http://ftp.gnu.org/gnu/mpc/mpc-$mpc_release_ver.tar.gz" "../source/mpc-$mpc_release_ver/configure" --build="$system_type" --prefix="$mpc_prefix" --with-gmp="$gmp_prefix" --with-mpfr="$mpfr_prefix" --disable-shared --enable-static

#build isl
std_compile 'isl' "$isl_ver" "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$isl_ver.tar.bz2" "../source/isl-$isl_ver/configure" --prefix="$isl_prefix" --build="$system_type" --enable-static --disable-shared --with-gmp-prefix="$gmp_prefix" --with-piplib=no --with-clang=no

#build cloog
std_compile 'cloog' "$cloog_ver" "ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-$cloog_ver.tar.gz" "../source/cloog-$cloog_ver/configure" --prefix="$cloog_prefix" --build="$system_type" --enable-static --disable-shared --with-bits=gmp --with-isl=bundled --with-gmp-prefix="$gmp_prefix"

export CC="$old_cc"

# Build GCC (GCC only)
cd "$pkgs_dir" || exit 1
create_pkg_dirs 'gcc'
cd "$pkgs_dir/gcc/source" || exit 1
if [[ "$gcc_ver" != 'svn' ]]; then
  download_extract "http://ftp.gnu.org/gnu/gcc/gcc-$gcc_ver/gcc-$gcc_ver.tar.bz2" "ftp://ftp.gnu.org/gnu/gcc/gcc-$gcc_ver/gcc-$gcc_ver.tar.bz2"
else
  if [[ -d 'gcc-svn' ]]; then
    cd 'gcc-svn' || exit 1
    build_progress 'gcc-svn' 'Updating'
    svn update > >(build_log) 2>&1 || exit 1
    build_progress 'Done'
    cd '..'
  else
    build_progress 'gcc-svn' 'Downloading'
    svn checkout svn://gcc.gnu.org/svn/gcc/trunk gcc-svn > >(build_log) 2>&1 || exit 1
    build_progress 'Done'
  fi
fi

clean_build
build_progress 'gcc' 'Configuring'
configure_gcc "$gcc_ver" || exit 1
build_progress 'Done'

build_progress 'all-gcc' 'Building'
make -j "$cpu_count" all-gcc > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'gcc' 'Installing'
make install-gcc > >(build_log) 2>&1 || exit 1
build_progress 'Done'

# Build mingw-w64 CRT 
cd "$mingw_w64_build_dir/crt" || exit 1

build_progress 'mingw-w64 crt' 'Configuring'
"$mingw_w64_source_dir/mingw-w64-$mingw_w64_ver/mingw-w64-crt/configure" --build="$system_type" --host="$mingw_w64_target" --prefix="$mingw_w64_prefix" --with-sysroot="$mingw_w64_prefix" > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'mingw-w64 crt' 'Building'
make -j "$cpu_count" > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'mingw-w64 crt' 'Installing'
make install > >(build_log) 2>&1 || exit 1
build_progress 'Done'

cd "$mingw_w64_prefix" || exit 1
mv "./$mingw_w64_target/lib/"* './lib/'
rm -fr "./$mingw_w64_target/lib"
cd "./$mingw_w64_target"
ln -s '../lib' './lib'

# Build GCC
cd "$pkgs_dir/gcc/build" || exit 1
build_progress 'gcc target-libgcc' 'Building'
make -j "$cpu_count" all-target-libgcc > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'gcc target-libgcc' 'Installing'
make -j "$cpu_count" install-target-libgcc > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'gcc' 'Building'
make -j "$cpu_count" > >(build_log) 2>&1 || exit 1
build_progress 'Done'

build_progress 'gcc' 'Installing'
make install-strip > >(build_log) 2>&1 || exit 1
build_progress 'Done'

if [[ "$thread_lib" != 'disable' ]]; then
  build_thread_lib "$mingw_w64_target" "$mingw_w64_prefix" || exit 1
fi

if [[ "$enable_gendef" = 'yes' ]]; then
  cd "$mingw_w64_build_dir" || exit 1
  rm -fr 'gendef'
  mkdir 'gendef'
  cd 'gendef' || exit 1
  build_progress 'gendef' 'Configuring'
  "$mingw_w64_source_dir/mingw-w64-$mingw_w64_ver/mingw-w64-tools/gendef/configure" --build="$system_type" --prefix="$mingw_w64_prefix" > >(build_log) 2>&1 || exit 1
  build_progress 'Done'

  build_progress 'gendef' 'Building'
  make > >(build_log) 2>&1 || exit 1
  build_progress 'Done'

  build_progress 'gendef' 'Installing'
  make install > >(build_log) 2>&1 || exit 1
  build_progress 'Done'
fi

return 0
}

clean_build_fn () {
if [[ "$clean_build" = 'yes' ]]; then
  cd "$working_dir" && rm -fr 'build' 'pkgs' 'source'
  return
fi
if [[ "$default_config" = 'yes' ]]; then
  return
fi
unset user_input
printf '\n'
while [[ "$user_input" != [YyNn] ]]; do
  printf 'Would you like to clean the build, leaving only the built toolchain? You can set this option with: "--clean-build", see --help for more information. The "build", "pkgs", and "source" directories along with all files within them will be removed if "y" is selected. [y/n]: '
  read user_input
  if [[ "$user_input" = [Yy] ]]; then
    cd "$working_dir" && rm -fr 'build' 'pkgs' 'source' 'build.log'
  fi
  if [[ "$user_input" != [YyNn] ]]; then
    printf '\n\nYour selection was not vaild, please try again.\n\n'
  fi
done
}

download_source () {
case "$1" in
  'multi' ) if [[ -d "$mingw_w64_i686_prefix" && -d "$mingw_w64_x86_64_prefix" ]]; then  prefix_present='yes'; fi ;;
  'win32' ) if [[ -d "$mingw_w64_i686_prefix" ]]; then  prefix_present='yes'; fi ;;
  'win64' ) if [[ -d "$mingw_w64_x86_64_prefix" ]]; then  prefix_present='yes'; fi ;;
esac
shift

mkdir -p 'pkgs' 'source' 'build'
cd 'pkgs' || exit 1
rm -fr 'config.guess'
build_progress 'config.guess' 'Downloading'
wget -nv -O config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' > >(build_log) 2>&1 || { ping -c 1 git.savannah.gnu.org >/dev/null 2>&1 || printf '\nsavannah.gnu.org seems to be offline right now and is needed to download the file "config.guess", please try again later.\n\n'; rm -f 'config.guess' && exit 1; }
build_progress 'Done'
system_type="$(sh config.guess)"

cd "$mingw_w64_source_dir" || exit 1
if [[ "$mingw_w64_ver" = 'svn' ]]; then
  if [[ -d 'mingw-w64-svn' ]]; then
    cd 'mingw-w64-svn' || exit 1
    svn_ver_before=$(sed -n 4p '.svn/entries')
    svn update || exit 1
    svn_ver_after=$(sed -n 4p '.svn/entries')
    if [[ "$allow_overwrite" != 'yes' && "$svn_ver_before" = "$svn_ver_after" &&  "$prefix_present" = 'yes' ]]; then
      if ! yes_no_sel "MinGW-w64 is already the latest version, continue with the build anyway? You can set this option with: '--allow-overwrite', see '--help' for more information."; then
        exit 0
      fi
    fi
  else

    svn checkout  svn://svn.code.sf.net/p/mingw-w64/code/trunk mingw-w64-svn || exit 1
  fi
else
  if [[ -d "mingw-w64-$mingw_w64_release_ver" && "$allow_overwrite" != 'yes' &&  "$prefix_present" = 'yes' ]]; then
    if ! yes_no_sel "MinGW-w64 is already the latest version, continue with the build anyway? You can set this option with: '--allow-overwrite', see '--help' for more information."; then
      exit 0
    fi
  fi

  if [[ ! -d "mingw-w64-$mingw_w64_release_ver" || ! -f "mingw-w64-$mingw_w64_release_ver.tar.bz2" ]]; then
    rm -f "mingw-w64-$mingw_w64_release_ver.tar.bz2" "mingw-w64-$mingw_w64_release_ver"
    build_progress "mingw-w64-$mingw_w64_release_ver.tar.bz2" 'Downloading'
    wget -nv -O "mingw-w64-$mingw_w64_release_ver.tar.bz2" http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v${mingw_w64_release_ver}.tar.bz2 > >(build_log) 2>&1 || exit 1
    build_progress 'Done'
    build_progress "mingw-w64-$mingw_w64_release_ver.tar.bz2" 'Extracting'
    bzip2 -d <"mingw-w64-$mingw_w64_release_ver.tar.bz2" | pax -r
    build_progress 'Done'
    mv "mingw-w64-v$mingw_w64_release_ver" "mingw-w64-$mingw_w64_release_ver"
  fi
fi
}

check_missing_packages () {
local check_packages=('bison' 'm4' 'flex' 'git' 'svn' 'gcc' 'yasm' 'cvs' 'g++' 'make' 'xz' 'bzip2' 'pax' 'gunzip')
for package in "${check_packages[@]}"; do
  command -v "$package" >/dev/null || missing_packages=("$package" "${missing_packages[@]}")
done

if [[ -n "${missing_packages[@]}" ]]; then
  printf '\nCould not find the following packages: %s\n' "${missing_packages[*]}"
  printf 'Install the missing packages before running this script.\n\n'
 exit 1
fi
}

build_pthreads_w32 () {
if [[ -z "$pthreads_w32_ver" ]]; then
  pthreads_w32_ver='cvs'
fi

local target prefix
target="$1"
prefix="$2"

shift 2
cd "$pkgs_dir" || exit 1
create_pkg_dirs 'pthread-w32' || exit 1

if [[ "$pthreads_w32_ver" = "$pthreads_w32_release_ver" ]]; then
  download_extract "ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-$pthreads_w32_release_ver-release.tar.gz"
  if [[ ! -d "pthreads-w32-$pthreads_w32_release_ver" ]]; then
    mv "pthreads-w32-$pthreads_w32_release_ver-release" "pthreads-w32-$pthreads_w32_release_ver" || exit 1
  fi
else
  unset oldmd5 newmd5
  if [[ -d 'pthreads-w32-cvs' ]]; then
    cd 'pthreads-w32-cvs' || exit 1
    build_progress 'pthreads-w32 cvs' 'Updating'
    cvs update > >(build_log) 2>&1 || exit 1
    build_progress 'Done'
    cd '..'
  else
    build_progress 'pthreads-w32 cvs' 'Downloading'
    cvs -d :pserver:anonymous@sourceware.org:/cvs/pthreads-win32 checkout pthreads > >(build_log) 2>&1 || exit 1
    build_progress 'Done'
    mv 'pthreads' 'pthreads-w32-cvs'
  fi
fi

cd "pthreads-w32-$pthreads_w32_ver" || exit 1
make realclean > >(build_log) 2>&1 || exit 1
if [[ "${static_build[@]}" != *"disable-shared"* ]]; then
  build_progress 'pthreads-w32 shared' 'Building'
  make CROSS="$target-" realclean GC ARCH="$pthread_arch" > >(build_log) 2>&1 || exit 1
  build_progress 'Done'

  cp 'pthreadGC2.dll' "$prefix/lib/" || exit 1
  cd "$prefix/lib" || exit 1
  ln -s "./pthreadGC2.dll" "./libpthread.dll"
  cd "$pkgs_dir/pthread-w32/source/pthreads-w32-$pthreads_w32_ver" || exit 1
fi
build_progress 'pthreads-w32 static' 'Building'
make CROSS="$target-" realclean GC-static ARCH="$pthread_arch" > >(build_log) 2>&1 || exit 1
build_progress 'Done'

cp 'libpthreadGC2.a' "$prefix/lib/" || exit 1
cp 'pthread.h' 'sched.h' 'semaphore.h' "$prefix/include/" || exit 1
cd "$prefix/lib" || exit 1
ln -s "./libpthreadGC2.a" "./libpthread.a"
cd '../include' || exit 1

for file in 'pthread.h' 'sched.h' 'semaphore.h'; do
  if ! ed -s "$prefix/include/$file" <<< $',s/ __declspec (dllexport)//g\n,s/ __declspec (dllimport)//g\nw\nq' > >(build_log) 2>&1; then
    mv "$file" "$file".orig
    sed 's/ __declspec (dllexport)//g;s/ __declspec (dllimport)//g' "$file".orig > "$file"
    rm -f "$file".orig
  fi
done
}

build_thread_lib () {
local target prefix
target="$1"
prefix="$2"
shift 2
case "$thread_lib" in
  'winpthreads' ) build_winpthreads "$target" "$prefix" ;;
  'pthreads-w32' ) build_pthreads_w32 "$target" "$prefix" ;;
  * ) build_pthreads_w32 "$target" "$prefix" ;;
esac
}

completed_build () {
local arch="$1"
case "$arch" in
  'win32' ) mingw_w64_path_prefix="$mingw_w64_i686_prefix" ;;
  'win64' ) mingw_w64_path_prefix="$mingw_w64_x86_64_prefix" ;;
esac
printf 'The MinGW-w64 bin directory needs to be added to the PATH variable so the system can find it, for %s this can be done with: export PATH="%s/bin:$PATH"\n' "${arch^}" "$mingw_w64_path_prefix"
}

no_errors='MinGW-w64 has been built without errors.'

calculate_steps ()
{
case "$arch" in
  'multi' ) total_steps='68';;
  'win32' ) total_steps='50';;
  'win64' ) total_steps='50';;
esac

if [[ "$arch" = 'multi' ]]; then
  if [[ "${static_build[@]}" = *"disable-shared"* ]]; then
    total_steps=$((total_steps-2))
  fi

  if [[ "$enable_gendef" = 'yes' ]]; then
    total_steps=$((total_steps+6))
  fi
else
  if [[ "${static_build[@]}" = *"disable-shared"* ]]; then
    total_steps=$((total_steps-1))
  fi

  if [[ "$enable_gendef" = 'yes' ]]; then
    total_steps=$((total_steps+3))
  fi
fi
}

build_mingw_w64_toolchain () {
current_step='1'
local arch="$1"
calculate_steps "$arch"
check_missing_packages || exit 1
if [[ -z "$build_type" || -z "$mingw_w64_ver" || -z "$binutils_ver" || -z "$gcc_ver" || -z "$enabled_langs" ]]; then
  configure_build_fn || exit 1
fi
if [[ -z "$cpu_count" ]]; then
  use_cpu_count
fi
download_source "$arch" || exit 1
case "$arch" in
  'multi' ) build_mingw_w64 "$target_i686" "$mingw_w64_i686_prefix" && build_mingw_w64 "$target_x86_64" "$mingw_w64_x86_64_prefix" || exit 1 ;;
  'win32' ) build_mingw_w64 "$target_i686" "$mingw_w64_i686_prefix" || exit 1 ;;
  'win64' ) build_mingw_w64 "$target_x86_64" "$mingw_w64_x86_64_prefix" || exit 1 ;;
esac
clean_build_fn
printf '\n\n%s\n' "$no_errors"
if [[ "$arch" = "multi" ]]; then
  completed_build 'win32'
  completed_build 'win64'
else
  completed_build "$1"
fi
}

test_opt () {
test_valid_opt 'build_type' 'win32' 'win64' 'multi'
test_valid_opt 'mingw_w64_ver' "$mingw_w64_release_ver" 'svn'
test_valid_opt 'thread_lib' 'winpthreads' 'pthreads-w32' 'disable'
test_valid_opt 'pthreads_w32_ver' "$pthreads_w32_release_ver" 'cvs'
if [[ -n "$pthreads_w32_ver" ]]; then
 thread_lib='pthreads-w32'
fi
if [[ -n "$cpu_count_opt" ]]; then
  check_cpu_count_optarg
fi
test_valid_opt 'binutils_ver' "$binutils_release_ver" "snapshot" 'cvs'
if ! command -v makeinfo >/dev/null; then
  printf 'makeinfo is needed to compile binutils and will need be be installed. On Debian/Ubuntu it is part of the "texinfo" software package.\n'
  exit 1
fi
test_valid_opt 'gcc_ver' "$gcc_release_ver" "$gcc_old_release_ver" 'svn'
}

check_cpu_count_optarg () {
if [[ "$cpu_count_opt" = "max" ]]; then
  cpu_count="$(grep -c processor /proc/cpuinfo)"
  return 0
fi

if [[ "$cpu_count_opt" -gt "$(grep -c processor /proc/cpuinfo)" ]]; then
  if ! yes_no_sel "The input number of cores/threads was higher than the number detected ($(grep -c processor /proc/cpuinfo) were detected). Trying to use more cores/threads than your CPU has can cause your system to crash. Are you sure you want to continue?"; then
    exit 1
  fi
fi
cpu_count="$cpu_count_opt"
}

wipe () {
if yes_no_sel "Are you sure you want to remove all MinGW-w64 files? Files/directories: 'build' 'build.log' 'mingw-w64-i686' 'mingw-w64-x86_64' 'pkgs' 'source' will be removed."; then
  rm -fr 'build' 'build.log' 'mingw-w64-i686' 'mingw-w64-x86_64' 'pkgs' 'source'
fi

exit 0
}

test_valid_opt () {
if [[ -z "${!1}" ]]; then
  return
fi
local opt
local valid_arg
opt="$1"
shift

for args do
  if [[ "$args" = "${!opt}" ]]; then
    valid_arg='yes'
  fi
done

if [[ "$valid_arg" != 'yes' ]]; then
  clear
  printf 'Error, "%s" is not a valid option for --%s. The valid options are: %s\n' "${!opt}" "${opt//_/-}" "${*}"
  exit 1
fi
}

main_menu () {
if [[ "$build_type" != '' ]]; then
  build_mingw_w64_toolchain "$build_type" 2>&1 | tee "$working_dir/build.log"
  exit 0
fi
clear
while [[ "$build_choice" != [1-3] ]]; do
if [[ -n "${unknown_opts[@]}" ]]; then
  printf 'Unknown option(s)'
  for unknown_opt in "${unknown_opts[@]}"; do
    printf ' "%s"' "$unknown_opt"
  done
  printf ', ignored.\n\n'
fi
cat <<EOF
What version of MinGW-w64 would you like to build or update?
  1. Both Win32 and Win64
  2. Win32 (32-bit only)
  3. Win64 (64-bit only)
  4. About
  5. Exit

For a list of all available options, exit and run: 'bash ./mingw-w64-build-$script_ver --help'

EOF
printf 'Input your choice [1-5]: '
read build_choice
case "$build_choice" in
  1 ) build_mingw_w64_toolchain 'multi';;
  2 ) build_mingw_w64_toolchain 'win32';;
  3 ) build_mingw_w64_toolchain 'win64';;
  4 ) about; clear ;;
  5 ) exit 0 ;;
  * ) printf '\nYour choice was not valid, please try again.\n\n' ;;
esac
done
}

while true; do
  case $1 in
    -h | --help ) display_help; exit 0 ;;
    -a | --about ) about; exit 0 ;;
    -V | --version ) printf '%s\n' "$script_ver"; exit 0 ;;
    --build-type=* ) build_type="${1#*=}"; shift ;;
    --default-configure ) default_configure; shift ;;
    --rebuild-all ) rebuild='yes'; shift ;;
    --allow-overwrite ) allow_overwrite='yes'; shift ;;
    --mingw-w64-ver=* ) mingw_w64_ver="${1#*=}"; shift ;;
    --cpu-count=* ) cpu_count_opt="${1#*=}"; shift ;;
    --binutils-ver=* ) binutils_ver="${1#*=}"; shift ;;
    --gcc-ver=* ) gcc_ver="${1#*=}"; shift ;;
    --pthreads-w32-ver=* ) pthreads_w32_ver="${1#*=}" ; shift ;;
    --gcc-langs=* ) enabled_langs="${1#*=}"; shift ;;
    --enable-nls ) disable_nls=('--enable-nls'); shift ;;
    --disable-shared ) static_build=('--disable-shared' '--enable-static'); shift ;;
    --threads=* ) thread_lib="${1#*=}"; shift ;;
    --clean-build ) clean_build='yes'; shift ;;
    --enable-gendef ) enable_gendef='yes';  shift ;;
    --verbose ) verbose='yes'; shift ;;
    wipe ) wipe; shift ;;
    -- ) shift; break ;;
    -* ) printf 'Error, unknown option: "%s".\n' "$1"; exit 1 ;;
    * ) break ;;
  esac
done

test_opt

main_menu

exit 0

#                     GNU GENERAL PUBLIC LICENSE
#                        Version 3, 29 June 2007
# 
#  Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
#  Everyone is permitted to copy and distribute verbatim copies
#  of this license document, but changing it is not allowed.
# 
#                             Preamble
# 
#   The GNU General Public License is a free, copyleft license for
# software and other kinds of works.
# 
#   The licenses for most software and other practical works are designed
# to take away your freedom to share and change the works.  By contrast,
# the GNU General Public License is intended to guarantee your freedom to
# share and change all versions of a program--to make sure it remains free
# software for all its users.  We, the Free Software Foundation, use the
# GNU General Public License for most of our software; it applies also to
# any other work released this way by its authors.  You can apply it to
# your programs, too.
# 
#   When we speak of free software, we are referring to freedom, not
# price.  Our General Public Licenses are designed to make sure that you
# have the freedom to distribute copies of free software (and charge for
# them if you wish), that you receive source code or can get it if you
# want it, that you can change the software or use pieces of it in new
# free programs, and that you know you can do these things.
# 
#   To protect your rights, we need to prevent others from denying you
# these rights or asking you to surrender the rights.  Therefore, you have
# certain responsibilities if you distribute copies of the software, or if
# you modify it: responsibilities to respect the freedom of others.
# 
#   For example, if you distribute copies of such a program, whether
# gratis or for a fee, you must pass on to the recipients the same
# freedoms that you received.  You must make sure that they, too, receive
# or can get the source code.  And you must show them these terms so they
# know their rights.
# 
#   Developers that use the GNU GPL protect your rights with two steps:
# (1) assert copyright on the software, and (2) offer you this License
# giving you legal permission to copy, distribute and/or modify it.
# 
#   For the developers' and authors' protection, the GPL clearly explains
# that there is no warranty for this free software.  For both users' and
# authors' sake, the GPL requires that modified versions be marked as
# changed, so that their problems will not be attributed erroneously to
# authors of previous versions.
# 
#   Some devices are designed to deny users access to install or run
# modified versions of the software inside them, although the manufacturer
# can do so.  This is fundamentally incompatible with the aim of
# protecting users' freedom to change the software.  The systematic
# pattern of such abuse occurs in the area of products for individuals to
# use, which is precisely where it is most unacceptable.  Therefore, we
# have designed this version of the GPL to prohibit the practice for those
# products.  If such problems arise substantially in other domains, we
# stand ready to extend this provision to those domains in future versions
# of the GPL, as needed to protect the freedom of users.
# 
#   Finally, every program is threatened constantly by software patents.
# States should not allow patents to restrict development and use of
# software on general-purpose computers, but in those that do, we wish to
# avoid the special danger that patents applied to a free program could
# make it effectively proprietary.  To prevent this, the GPL assures that
# patents cannot be used to render the program non-free.
# 
#   The precise terms and conditions for copying, distribution and
# modification follow.
# 
#                        TERMS AND CONDITIONS
# 
#   0. Definitions.
# 
#   "This License" refers to version 3 of the GNU General Public License.
# 
#   "Copyright" also means copyright-like laws that apply to other kinds of
# works, such as semiconductor masks.
# 
#   "The Program" refers to any copyrightable work licensed under this
# License.  Each licensee is addressed as "you".  "Licensees" and
# "recipients" may be individuals or organizations.
# 
#   To "modify" a work means to copy from or adapt all or part of the work
# in a fashion requiring copyright permission, other than the making of an
# exact copy.  The resulting work is called a "modified version" of the
# earlier work or a work "based on" the earlier work.
# 
#   A "covered work" means either the unmodified Program or a work based
# on the Program.
# 
#   To "propagate" a work means to do anything with it that, without
# permission, would make you directly or secondarily liable for
# infringement under applicable copyright law, except executing it on a
# computer or modifying a private copy.  Propagation includes copying,
# distribution (with or without modification), making available to the
# public, and in some countries other activities as well.
# 
#   To "convey" a work means any kind of propagation that enables other
# parties to make or receive copies.  Mere interaction with a user through
# a computer network, with no transfer of a copy, is not conveying.
# 
#   An interactive user interface displays "Appropriate Legal Notices"
# to the extent that it includes a convenient and prominently visible
# feature that (1) displays an appropriate copyright notice, and (2)
# tells the user that there is no warranty for the work (except to the
# extent that warranties are provided), that licensees may convey the
# work under this License, and how to view a copy of this License.  If
# the interface presents a list of user commands or options, such as a
# menu, a prominent item in the list meets this criterion.
# 
#   1. Source Code.
# 
#   The "source code" for a work means the preferred form of the work
# for making modifications to it.  "Object code" means any non-source
# form of a work.
# 
#   A "Standard Interface" means an interface that either is an official
# standard defined by a recognized standards body, or, in the case of
# interfaces specified for a particular programming language, one that
# is widely used among developers working in that language.
# 
#   The "System Libraries" of an executable work include anything, other
# than the work as a whole, that (a) is included in the normal form of
# packaging a Major Component, but which is not part of that Major
# Component, and (b) serves only to enable use of the work with that
# Major Component, or to implement a Standard Interface for which an
# implementation is available to the public in source code form.  A
# "Major Component", in this context, means a major essential component
# (kernel, window system, and so on) of the specific operating system
# (if any) on which the executable work runs, or a compiler used to
# produce the work, or an object code interpreter used to run it.
# 
#   The "Corresponding Source" for a work in object code form means all
# the source code needed to generate, install, and (for an executable
# work) run the object code and to modify the work, including scripts to
# control those activities.  However, it does not include the work's
# System Libraries, or general-purpose tools or generally available free
# programs which are used unmodified in performing those activities but
# which are not part of the work.  For example, Corresponding Source
# includes interface definition files associated with source files for
# the work, and the source code for shared libraries and dynamically
# linked subprograms that the work is specifically designed to require,
# such as by intimate data communication or control flow between those
# subprograms and other parts of the work.
# 
#   The Corresponding Source need not include anything that users
# can regenerate automatically from other parts of the Corresponding
# Source.
# 
#   The Corresponding Source for a work in source code form is that
# same work.
# 
#   2. Basic Permissions.
# 
#   All rights granted under this License are granted for the term of
# copyright on the Program, and are irrevocable provided the stated
# conditions are met.  This License explicitly affirms your unlimited
# permission to run the unmodified Program.  The output from running a
# covered work is covered by this License only if the output, given its
# content, constitutes a covered work.  This License acknowledges your
# rights of fair use or other equivalent, as provided by copyright law.
# 
#   You may make, run and propagate covered works that you do not
# convey, without conditions so long as your license otherwise remains
# in force.  You may convey covered works to others for the sole purpose
# of having them make modifications exclusively for you, or provide you
# with facilities for running those works, provided that you comply with
# the terms of this License in conveying all material for which you do
# not control copyright.  Those thus making or running the covered works
# for you must do so exclusively on your behalf, under your direction
# and control, on terms that prohibit them from making any copies of
# your copyrighted material outside their relationship with you.
# 
#   Conveying under any other circumstances is permitted solely under
# the conditions stated below.  Sublicensing is not allowed; section 10
# makes it unnecessary.
# 
#   3. Protecting Users' Legal Rights From Anti-Circumvention Law.
# 
#   No covered work shall be deemed part of an effective technological
# measure under any applicable law fulfilling obligations under article
# 11 of the WIPO copyright treaty adopted on 20 December 1996, or
# similar laws prohibiting or restricting circumvention of such
# measures.
# 
#   When you convey a covered work, you waive any legal power to forbid
# circumvention of technological measures to the extent such circumvention
# is effected by exercising rights under this License with respect to
# the covered work, and you disclaim any intention to limit operation or
# modification of the work as a means of enforcing, against the work's
# users, your or third parties' legal rights to forbid circumvention of
# technological measures.
# 
#   4. Conveying Verbatim Copies.
# 
#   You may convey verbatim copies of the Program's source code as you
# receive it, in any medium, provided that you conspicuously and
# appropriately publish on each copy an appropriate copyright notice;
# keep intact all notices stating that this License and any
# non-permissive terms added in accord with section 7 apply to the code;
# keep intact all notices of the absence of any warranty; and give all
# recipients a copy of this License along with the Program.
# 
#   You may charge any price or no price for each copy that you convey,
# and you may offer support or warranty protection for a fee.
# 
#   5. Conveying Modified Source Versions.
# 
#   You may convey a work based on the Program, or the modifications to
# produce it from the Program, in the form of source code under the
# terms of section 4, provided that you also meet all of these conditions:
# 
#     a) The work must carry prominent notices stating that you modified
#     it, and giving a relevant date.
# 
#     b) The work must carry prominent notices stating that it is
#     released under this License and any conditions added under section
#     7.  This requirement modifies the requirement in section 4 to
#     "keep intact all notices".
# 
#     c) You must license the entire work, as a whole, under this
#     License to anyone who comes into possession of a copy.  This
#     License will therefore apply, along with any applicable section 7
#     additional terms, to the whole of the work, and all its parts,
#     regardless of how they are packaged.  This License gives no
#     permission to license the work in any other way, but it does not
#     invalidate such permission if you have separately received it.
# 
#     d) If the work has interactive user interfaces, each must display
#     Appropriate Legal Notices; however, if the Program has interactive
#     interfaces that do not display Appropriate Legal Notices, your
#     work need not make them do so.
# 
#   A compilation of a covered work with other separate and independent
# works, which are not by their nature extensions of the covered work,
# and which are not combined with it such as to form a larger program,
# in or on a volume of a storage or distribution medium, is called an
# "aggregate" if the compilation and its resulting copyright are not
# used to limit the access or legal rights of the compilation's users
# beyond what the individual works permit.  Inclusion of a covered work
# in an aggregate does not cause this License to apply to the other
# parts of the aggregate.
# 
#   6. Conveying Non-Source Forms.
# 
#   You may convey a covered work in object code form under the terms
# of sections 4 and 5, provided that you also convey the
# machine-readable Corresponding Source under the terms of this License,
# in one of these ways:
# 
#     a) Convey the object code in, or embodied in, a physical product
#     (including a physical distribution medium), accompanied by the
#     Corresponding Source fixed on a durable physical medium
#     customarily used for software interchange.
# 
#     b) Convey the object code in, or embodied in, a physical product
#     (including a physical distribution medium), accompanied by a
#     written offer, valid for at least three years and valid for as
#     long as you offer spare parts or customer support for that product
#     model, to give anyone who possesses the object code either (1) a
#     copy of the Corresponding Source for all the software in the
#     product that is covered by this License, on a durable physical
#     medium customarily used for software interchange, for a price no
#     more than your reasonable cost of physically performing this
#     conveying of source, or (2) access to copy the
#     Corresponding Source from a network server at no charge.
# 
#     c) Convey individual copies of the object code with a copy of the
#     written offer to provide the Corresponding Source.  This
#     alternative is allowed only occasionally and noncommercially, and
#     only if you received the object code with such an offer, in accord
#     with subsection 6b.
# 
#     d) Convey the object code by offering access from a designated
#     place (gratis or for a charge), and offer equivalent access to the
#     Corresponding Source in the same way through the same place at no
#     further charge.  You need not require recipients to copy the
#     Corresponding Source along with the object code.  If the place to
#     copy the object code is a network server, the Corresponding Source
#     may be on a different server (operated by you or a third party)
#     that supports equivalent copying facilities, provided you maintain
#     clear directions next to the object code saying where to find the
#     Corresponding Source.  Regardless of what server hosts the
#     Corresponding Source, you remain obligated to ensure that it is
#     available for as long as needed to satisfy these requirements.
# 
#     e) Convey the object code using peer-to-peer transmission, provided
#     you inform other peers where the object code and Corresponding
#     Source of the work are being offered to the general public at no
#     charge under subsection 6d.
# 
#   A separable portion of the object code, whose source code is excluded
# from the Corresponding Source as a System Library, need not be
# included in conveying the object code work.
# 
#   A "User Product" is either (1) a "consumer product", which means any
# tangible personal property which is normally used for personal, family,
# or household purposes, or (2) anything designed or sold for incorporation
# into a dwelling.  In determining whether a product is a consumer product,
# doubtful cases shall be resolved in favor of coverage.  For a particular
# product received by a particular user, "normally used" refers to a
# typical or common use of that class of product, regardless of the status
# of the particular user or of the way in which the particular user
# actually uses, or expects or is expected to use, the product.  A product
# is a consumer product regardless of whether the product has substantial
# commercial, industrial or non-consumer uses, unless such uses represent
# the only significant mode of use of the product.
# 
#   "Installation Information" for a User Product means any methods,
# procedures, authorization keys, or other information required to install
# and execute modified versions of a covered work in that User Product from
# a modified version of its Corresponding Source.  The information must
# suffice to ensure that the continued functioning of the modified object
# code is in no case prevented or interfered with solely because
# modification has been made.
# 
#   If you convey an object code work under this section in, or with, or
# specifically for use in, a User Product, and the conveying occurs as
# part of a transaction in which the right of possession and use of the
# User Product is transferred to the recipient in perpetuity or for a
# fixed term (regardless of how the transaction is characterized), the
# Corresponding Source conveyed under this section must be accompanied
# by the Installation Information.  But this requirement does not apply
# if neither you nor any third party retains the ability to install
# modified object code on the User Product (for example, the work has
# been installed in ROM).
# 
#   The requirement to provide Installation Information does not include a
# requirement to continue to provide support service, warranty, or updates
# for a work that has been modified or installed by the recipient, or for
# the User Product in which it has been modified or installed.  Access to a
# network may be denied when the modification itself materially and
# adversely affects the operation of the network or violates the rules and
# protocols for communication across the network.
# 
#   Corresponding Source conveyed, and Installation Information provided,
# in accord with this section must be in a format that is publicly
# documented (and with an implementation available to the public in
# source code form), and must require no special password or key for
# unpacking, reading or copying.
# 
#   7. Additional Terms.
# 
#   "Additional permissions" are terms that supplement the terms of this
# License by making exceptions from one or more of its conditions.
# Additional permissions that are applicable to the entire Program shall
# be treated as though they were included in this License, to the extent
# that they are valid under applicable law.  If additional permissions
# apply only to part of the Program, that part may be used separately
# under those permissions, but the entire Program remains governed by
# this License without regard to the additional permissions.
# 
#   When you convey a copy of a covered work, you may at your option
# remove any additional permissions from that copy, or from any part of
# it.  (Additional permissions may be written to require their own
# removal in certain cases when you modify the work.)  You may place
# additional permissions on material, added by you to a covered work,
# for which you have or can give appropriate copyright permission.
# 
#   Notwithstanding any other provision of this License, for material you
# add to a covered work, you may (if authorized by the copyright holders of
# that material) supplement the terms of this License with terms:
# 
#     a) Disclaiming warranty or limiting liability differently from the
#     terms of sections 15 and 16 of this License; or
# 
#     b) Requiring preservation of specified reasonable legal notices or
#     author attributions in that material or in the Appropriate Legal
#     Notices displayed by works containing it; or
# 
#     c) Prohibiting misrepresentation of the origin of that material, or
#     requiring that modified versions of such material be marked in
#     reasonable ways as different from the original version; or
# 
#     d) Limiting the use for publicity purposes of names of licensors or
#     authors of the material; or
# 
#     e) Declining to grant rights under trademark law for use of some
#     trade names, trademarks, or service marks; or
# 
#     f) Requiring indemnification of licensors and authors of that
#     material by anyone who conveys the material (or modified versions of
#     it) with contractual assumptions of liability to the recipient, for
#     any liability that these contractual assumptions directly impose on
#     those licensors and authors.
# 
#   All other non-permissive additional terms are considered "further
# restrictions" within the meaning of section 10.  If the Program as you
# received it, or any part of it, contains a notice stating that it is
# governed by this License along with a term that is a further
# restriction, you may remove that term.  If a license document contains
# a further restriction but permits relicensing or conveying under this
# License, you may add to a covered work material governed by the terms
# of that license document, provided that the further restriction does
# not survive such relicensing or conveying.
# 
#   If you add terms to a covered work in accord with this section, you
# must place, in the relevant source files, a statement of the
# additional terms that apply to those files, or a notice indicating
# where to find the applicable terms.
# 
#   Additional terms, permissive or non-permissive, may be stated in the
# form of a separately written license, or stated as exceptions;
# the above requirements apply either way.
# 
#   8. Termination.
# 
#   You may not propagate or modify a covered work except as expressly
# provided under this License.  Any attempt otherwise to propagate or
# modify it is void, and will automatically terminate your rights under
# this License (including any patent licenses granted under the third
# paragraph of section 11).
# 
#   However, if you cease all violation of this License, then your
# license from a particular copyright holder is reinstated (a)
# provisionally, unless and until the copyright holder explicitly and
# finally terminates your license, and (b) permanently, if the copyright
# holder fails to notify you of the violation by some reasonable means
# prior to 60 days after the cessation.
# 
#   Moreover, your license from a particular copyright holder is
# reinstated permanently if the copyright holder notifies you of the
# violation by some reasonable means, this is the first time you have
# received notice of violation of this License (for any work) from that
# copyright holder, and you cure the violation prior to 30 days after
# your receipt of the notice.
# 
#   Termination of your rights under this section does not terminate the
# licenses of parties who have received copies or rights from you under
# this License.  If your rights have been terminated and not permanently
# reinstated, you do not qualify to receive new licenses for the same
# material under section 10.
# 
#   9. Acceptance Not Required for Having Copies.
# 
#   You are not required to accept this License in order to receive or
# run a copy of the Program.  Ancillary propagation of a covered work
# occurring solely as a consequence of using peer-to-peer transmission
# to receive a copy likewise does not require acceptance.  However,
# nothing other than this License grants you permission to propagate or
# modify any covered work.  These actions infringe copyright if you do
# not accept this License.  Therefore, by modifying or propagating a
# covered work, you indicate your acceptance of this License to do so.
# 
#   10. Automatic Licensing of Downstream Recipients.
# 
#   Each time you convey a covered work, the recipient automatically
# receives a license from the original licensors, to run, modify and
# propagate that work, subject to this License.  You are not responsible
# for enforcing compliance by third parties with this License.
# 
#   An "entity transaction" is a transaction transferring control of an
# organization, or substantially all assets of one, or subdividing an
# organization, or merging organizations.  If propagation of a covered
# work results from an entity transaction, each party to that
# transaction who receives a copy of the work also receives whatever
# licenses to the work the party's predecessor in interest had or could
# give under the previous paragraph, plus a right to possession of the
# Corresponding Source of the work from the predecessor in interest, if
# the predecessor has it or can get it with reasonable efforts.
# 
#   You may not impose any further restrictions on the exercise of the
# rights granted or affirmed under this License.  For example, you may
# not impose a license fee, royalty, or other charge for exercise of
# rights granted under this License, and you may not initiate litigation
# (including a cross-claim or counterclaim in a lawsuit) alleging that
# any patent claim is infringed by making, using, selling, offering for
# sale, or importing the Program or any portion of it.
# 
#   11. Patents.
# 
#   A "contributor" is a copyright holder who authorizes use under this
# License of the Program or a work on which the Program is based.  The
# work thus licensed is called the contributor's "contributor version".
# 
#   A contributor's "essential patent claims" are all patent claims
# owned or controlled by the contributor, whether already acquired or
# hereafter acquired, that would be infringed by some manner, permitted
# by this License, of making, using, or selling its contributor version,
# but do not include claims that would be infringed only as a
# consequence of further modification of the contributor version.  For
# purposes of this definition, "control" includes the right to grant
# patent sublicenses in a manner consistent with the requirements of
# this License.
# 
#   Each contributor grants you a non-exclusive, worldwide, royalty-free
# patent license under the contributor's essential patent claims, to
# make, use, sell, offer for sale, import and otherwise run, modify and
# propagate the contents of its contributor version.
# 
#   In the following three paragraphs, a "patent license" is any express
# agreement or commitment, however denominated, not to enforce a patent
# (such as an express permission to practice a patent or covenant not to
# sue for patent infringement).  To "grant" such a patent license to a
# party means to make such an agreement or commitment not to enforce a
# patent against the party.
# 
#   If you convey a covered work, knowingly relying on a patent license,
# and the Corresponding Source of the work is not available for anyone
# to copy, free of charge and under the terms of this License, through a
# publicly available network server or other readily accessible means,
# then you must either (1) cause the Corresponding Source to be so
# available, or (2) arrange to deprive yourself of the benefit of the
# patent license for this particular work, or (3) arrange, in a manner
# consistent with the requirements of this License, to extend the patent
# license to downstream recipients.  "Knowingly relying" means you have
# actual knowledge that, but for the patent license, your conveying the
# covered work in a country, or your recipient's use of the covered work
# in a country, would infringe one or more identifiable patents in that
# country that you have reason to believe are valid.
# 
#   If, pursuant to or in connection with a single transaction or
# arrangement, you convey, or propagate by procuring conveyance of, a
# covered work, and grant a patent license to some of the parties
# receiving the covered work authorizing them to use, propagate, modify
# or convey a specific copy of the covered work, then the patent license
# you grant is automatically extended to all recipients of the covered
# work and works based on it.
# 
#   A patent license is "discriminatory" if it does not include within
# the scope of its coverage, prohibits the exercise of, or is
# conditioned on the non-exercise of one or more of the rights that are
# specifically granted under this License.  You may not convey a covered
# work if you are a party to an arrangement with a third party that is
# in the business of distributing software, under which you make payment
# to the third party based on the extent of your activity of conveying
# the work, and under which the third party grants, to any of the
# parties who would receive the covered work from you, a discriminatory
# patent license (a) in connection with copies of the covered work
# conveyed by you (or copies made from those copies), or (b) primarily
# for and in connection with specific products or compilations that
# contain the covered work, unless you entered into that arrangement,
# or that patent license was granted, prior to 28 March 2007.
# 
#   Nothing in this License shall be construed as excluding or limiting
# any implied license or other defenses to infringement that may
# otherwise be available to you under applicable patent law.
# 
#   12. No Surrender of Others' Freedom.
# 
#   If conditions are imposed on you (whether by court order, agreement or
# otherwise) that contradict the conditions of this License, they do not
# excuse you from the conditions of this License.  If you cannot convey a
# covered work so as to satisfy simultaneously your obligations under this
# License and any other pertinent obligations, then as a consequence you may
# not convey it at all.  For example, if you agree to terms that obligate you
# to collect a royalty for further conveying from those to whom you convey
# the Program, the only way you could satisfy both those terms and this
# License would be to refrain entirely from conveying the Program.
# 
#   13. Use with the GNU Affero General Public License.
# 
#   Notwithstanding any other provision of this License, you have
# permission to link or combine any covered work with a work licensed
# under version 3 of the GNU Affero General Public License into a single
# combined work, and to convey the resulting work.  The terms of this
# License will continue to apply to the part which is the covered work,
# but the special requirements of the GNU Affero General Public License,
# section 13, concerning interaction through a network will apply to the
# combination as such.
# 
#   14. Revised Versions of this License.
# 
#   The Free Software Foundation may publish revised and/or new versions of
# the GNU General Public License from time to time.  Such new versions will
# be similar in spirit to the present version, but may differ in detail to
# address new problems or concerns.
# 
#   Each version is given a distinguishing version number.  If the
# Program specifies that a certain numbered version of the GNU General
# Public License "or any later version" applies to it, you have the
# option of following the terms and conditions either of that numbered
# version or of any later version published by the Free Software
# Foundation.  If the Program does not specify a version number of the
# GNU General Public License, you may choose any version ever published
# by the Free Software Foundation.
# 
#   If the Program specifies that a proxy can decide which future
# versions of the GNU General Public License can be used, that proxy's
# public statement of acceptance of a version permanently authorizes you
# to choose that version for the Program.
# 
#   Later license versions may give you additional or different
# permissions.  However, no additional obligations are imposed on any
# author or copyright holder as a result of your choosing to follow a
# later version.
# 
#   15. Disclaimer of Warranty.
# 
#   THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
# APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
# HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
# OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
# IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
# ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
# 
#   16. Limitation of Liability.
# 
#   IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
# WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
# THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
# GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
# USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
# DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
# PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
# EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGES.
# 
#   17. Interpretation of Sections 15 and 16.
# 
#   If the disclaimer of warranty and limitation of liability provided
# above cannot be given local legal effect according to their terms,
# reviewing courts shall apply local law that most closely approximates
# an absolute waiver of all civil liability in connection with the
# Program, unless a warranty or assumption of liability accompanies a
# copy of the Program in return for a fee.
# 
#                      END OF TERMS AND CONDITIONS
# 
#             How to Apply These Terms to Your New Programs
# 
#   If you develop a new program, and you want it to be of the greatest
# possible use to the public, the best way to achieve this is to make it
# free software which everyone can redistribute and change under these terms.
# 
#   To do so, attach the following notices to the program.  It is safest
# to attach them to the start of each source file to most effectively
# state the exclusion of warranty; and each file should have at least
# the "copyright" line and a pointer to where the full notice is found.
# 
#     <one line to give the program's name and a brief idea of what it does.>
#     Copyright (C) <year>  <name of author>
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# Also add information on how to contact you by electronic and paper mail.
# 
#   If the program does terminal interaction, make it output a short
# notice like this when it starts in an interactive mode:
# 
#     <program>  Copyright (C) <year>  <name of author>
#     This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
#     This is free software, and you are welcome to redistribute it
#     under certain conditions; type `show c' for details.
# 
# The hypothetical commands `show w' and `show c' should show the appropriate
# parts of the General Public License.  Of course, your program's commands
# might be different; for a GUI interface, you would use an "about box".
# 
#   You should also get your employer (if you work as a programmer) or school,
# if any, to sign a "copyright disclaimer" for the program, if necessary.
# For more information on this, and how to apply and follow the GNU GPL, see
# <http://www.gnu.org/licenses/>.
# 
#   The GNU General Public License does not permit incorporating your program
# into proprietary programs.  If your program is a subroutine library, you
# may consider it more useful to permit linking proprietary applications with
# the library.  If this is what you want to do, use the GNU Lesser General
# Public License instead of this License.  But first, please read
# <http://www.gnu.org/philosophy/why-not-lgpl.html>.
