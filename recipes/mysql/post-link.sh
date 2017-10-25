#!/bin/bash

# this script is based off the homebrew package:
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mysql.rb
# with lots of changes and additions to isolate database instances

echo "MySQL Installation Notes:

1. WARNING: MySQL has been installed without a root password. To secure the
   installation, run:

    mysql_secure_installation

2. By default, MySQL will only allow connections from localhost.

3. To start [stop] the server, run:

    mysql.server start [stop]

4. The MySQL data directory is located within your Conda environment. This
   means that if your Conda environment is deleted, any databases will be
   deleted too!" >> ${PREFIX}/.messages.txt

# the default port is generated by hasing the conda env name
prefix_hash=`echo ${PREFIX} | md5`
prefix_num=$((0x${prefix_hash%% *}))
prefix_port=$[$(echo ${prefix_num} | tr -d -) % 64510 + 1025]

# Initialize the server if needed.
if [ ! -e ${PREFIX}/mysql/datadir/mysql/user.frm ]
then
    mkdir -p ${PREFIX}/mysql/lc_messages_dir
    mkdir -p ${PREFIX}/mysql/charsets
    mkdir -p ${PREFIX}/mysql/plugin
    ${PREFIX}/bin/mysqld \
        --initialize-insecure \
        --user=${USER} \
        --basedir=${PREFIX} \
        --datadir=${PREFIX}/mysql/datadir \
        --lc-messages-dir=${PREFIX}/mysql/lc_messages_dir \
        --character-sets-dir=${PREFIX}/mysql/charsets \
        --plugin-dir=${PREFIX}/mysql/plugin \
        --port=${prefix_port} \
        --socket=${PREFIX}/mysql/mysql.sock
    echo "Initialized MySQL server data directory." >> ${PREFIX}/.messages.txt
else
    echo "MySQL server data directory already exists. No initialization was done." >> ${PREFIX}/.messages.txt
fi

# install a default config
if [ ! -e ${PREFIX}/etc/my.cnf ]
then
    echo "[mysqld]
bind-address = 127.0.0.1
port = ${prefix_port}
" > ${PREFIX}/etc/my.cnf
    echo "Initialized MySQL configuration file." >> ${PREFIX}/.messages.txt
else
    echo "MySQL configuration file already exists. No initialization was done." >> ${PREFIX}/.messages.txt
fi
