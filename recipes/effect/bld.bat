DEL effect/_test_do_py3.py
%PYTHON% setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
