from distutils.cmd import Command
from distutils import sysconfig
from distutils.errors import DistutilsExecError
from commands.util import configure_error
from commands.util import is_osx
from commands.util import is_windows
from commands.link_util import link_native_lib
from commands.python import get_libpython
from commands.java import get_java_home
import os
import os.path
import sys


def run():
    build_base = 'build'
    java_build = os.path.join('build', 'java')

    # setup java classpath
    version = '3.9.0'
    classpath = os.path.join(java_build, 'jep-' + version + '.jar')
    classpath += os.pathsep + os.path.join(java_build, 'jep-' + version + '-test.jar')
    classpath += os.pathsep + 'src/test/python/lib/sqlitejdbc-v056.jar'
    classpath += os.pathsep + 'stc/test/python/lib/fakenetty.jar'

    # setup environment variables
    environment = {}
    '''
    if not is_osx() and not is_windows():
        environment['LD_LIBRARY_PATH'] = sysconfig.get_config_var('LIBDIR')
    # http://bugs.python.org/issue20614
    if is_windows():
        environment['SYSTEMROOT'] = os.environ['SYSTEMROOT']

    java_path = os.path.join(get_java_home(), 'bin')
    # if multiple versions of python are installed, this helps ensure the right
    # version is used
    executable = sys.executable
    if executable:
        py_path = os.path.dirname(executable)
        # java_path before python_path because py_path might point to a
        # default system path, like /usr/bin, which can contain other java
        # executables. Since all the subprocesses are Java running jep it
        # is very important to get the right java.
        environment['PATH'] = java_path + os.pathsep + py_path + os.pathsep + os.environ['PATH']
    else:
        environment['PATH'] = java_path + os.pathsep + os.environ['PATH']
    prefix = sysconfig.get_config_var('prefix')
    exec_prefix = sysconfig.get_config_var('exec_prefix')
    if prefix == exec_prefix:
        environment['PYTHONHOME'] = prefix
    else:
        environment['PYTHONHOME'] = prefix + ':' + exec_prefix


    # find the jep library and makes sure it's named correctly
    build_ext = get_finalized_command('build_ext')
    jep_lib = build_ext.get_outputs()[0]
    built_dir = os.path.dirname(jep_lib)
    link_native_lib(built_dir, jep_lib)
    
    environment['PYTHONPATH'] = get_finalized_command('build').build_lib
    '''

    # actually kick off the tests
    import subprocess
    args = ['java',
            '-classpath', '{0}'.format(classpath),
            'jep.Run', 'src/test/python/runtests.py']
    p = subprocess.Popen(args, env=environment)
    rc = p.wait()
    if rc != 0:
        raise DistutilsExecError("Unit tests failed with exit status %d" % (rc))

run()
