#!/bin/bash
unset MACOSX_DEPLOYMENT_TARGET
${PYTHON} setup.py install;
${PYTHON} setup.py test;
