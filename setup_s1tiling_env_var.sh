#!/bin/bash
export LANG=en_US.utf8
source ${OTB_INSTALL_DIRPATH}/otbenv.profile
source ${S1TILING_VENV}/bin/activate
# run the command:
$@
