#!/bin/bash
export LANG=en_US.utf8
source ${OTB_INSTALL_DIRPATH}/otbenv.profile
source ${EWOC_S1_VENV}/bin/activate
S1Processor $@
