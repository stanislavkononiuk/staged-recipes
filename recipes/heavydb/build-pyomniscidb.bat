dir
pushd python
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt
popd