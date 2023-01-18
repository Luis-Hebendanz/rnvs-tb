#!/bin/bash

set -e
set -x

python3 -m pip install --upgrade build
python3 -m build
