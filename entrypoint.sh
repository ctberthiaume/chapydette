#!/bin/bash
set -e
. /opt/conda/etc/profile.d/conda.sh
conda activate chpy
exec "$@"