#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

python setup.py install --symengine-dir=$PREFIX --single-version-externally-managed --record record.txt
