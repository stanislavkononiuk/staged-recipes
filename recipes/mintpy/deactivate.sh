if [[ -n "${_CONDA_RESTORE_PATH}" ]]; then
  export PATH=${_CONDA_RESTORE_PATH}
  unset _CONDA_RESTORE_PATH
fi

if [[ -n "${_CONDA_RESTORE_MINTPY_HOME}"]]; then
  export MINTPY_HOME=${_CONDA_RESTORE_MINTPY_HOME}
  unset _CONDA_RESTORE_MINTPY_HOME
fi