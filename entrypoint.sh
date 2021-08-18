#!/bin/bash
export LANG=en_US.utf8
source ${OTB_INSTALL_DIRPATH}/otbenv.profile
source ${EWOC_S1_VENV}/bin/activate
exec "$@"
#ewoc_generate_s1_ard_pid $@
