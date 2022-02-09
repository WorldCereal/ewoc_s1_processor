# =========================================================================
#
#   Copyright 2021 (c) CS Group France. All rights reserved.
#
#   This file is part of S1Tiling project
#       https://gitlab.orfeo-toolbox.org/s1-tiling/s1tiling
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# =========================================================================
#
# Authors: Aurélien BRICIER (CS Group France)
#          Mickaël SAVINAUD (CS Group France)
#
# =========================================================================
FROM ubuntu:20.04
LABEL maintainer="CS GROUP France"
LABEL description="This docker allow to run ewoc_s1 processing chain."

WORKDIR /tmp

ENV LANG=en_US.utf8

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    virtualenv \
    apt-utils file \
    g++ cmake make freeglut3-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --upgrade pip \
      && python3 -m pip install --no-cache-dir virtualenv \
      && python3 -m pip install --no-cache-dir 'numpy<1.19'

#------------------------------------------------------------------------
# Install and configure OTB for ewoc_s1

ARG OTB_VERSION=7.4.0
LABEL OTB="${OTB_VERSION}"
ADD https://www.orfeo-toolbox.org/packages/archives/OTB/OTB-${OTB_VERSION}-Linux64.run /tmp
ENV OTB_INSTALL_DIRPATH=/opt/otb-${OTB_VERSION}
RUN chmod +x OTB-${OTB_VERSION}-Linux64.run \
      && ./OTB-${OTB_VERSION}-Linux64.run --target ${OTB_INSTALL_DIRPATH} \
      && cd ${OTB_INSTALL_DIRPATH}  \
      && . ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && ctest -S ${OTB_INSTALL_DIRPATH}/share/otb/swig/build_wrapping.cmake -V \
      && echo "# Patching for s1tiling" >> ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && echo 'LD_LIBRARY_PATH=$(cat_path "${CMAKE_PREFIX_PATH}/lib" "$LD_LIBRARY_PATH")' >> ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && echo "export LD_LIBRARY_PATH" >> ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && rm -r "${OTB_INSTALL_DIRPATH}/share/otb/swig/build" \
      && rm -r "${OTB_INSTALL_DIRPATH}/bin/otbgui"* \
        "${OTB_INSTALL_DIRPATH}/bin/monteverdi" \
        "${OTB_INSTALL_DIRPATH}/lib/lib"*Qt* \
        "${OTB_INSTALL_DIRPATH}/lib/libOTBMonteverdi"* \
        "${OTB_INSTALL_DIRPATH}/lib/fonts" \
      && rm /tmp/OTB-${OTB_VERSION}-Linux64.run

ADD gdal-config ${OTB_INSTALL_DIRPATH}/bin
RUN chmod +x ${OTB_INSTALL_DIRPATH}/bin/gdal-config

#------------------------------------------------------------------------
## Install python packages

ARG EWOC_S1_VERSION=0.7.0
LABEL EWOC_S1="${EWOC_S1_VERSION}"
ARG EWOC_DATASHIP_VERSION=0.6.3
LABEL EWOC_DATASHIP="${EWOC_DATASHIP_VERSION}"

# Copy private python packages
COPY dataship-${EWOC_DATASHIP_VERSION}.tar.gz /tmp
COPY ewoc_s1-${EWOC_S1_VERSION}.tar.gz /tmp

SHELL ["/bin/bash", "-c"]

ENV EWOC_S1_VENV=/opt/ewoc_s1_venv
RUN python3 -m virtualenv ${EWOC_S1_VENV} \
      && . ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && source ${EWOC_S1_VENV}/bin/activate \
      && pip install --no-cache-dir 'numpy<1.19' \
      && pip install --no-cache-dir /tmp/dataship-${EWOC_DATASHIP_VERSION}.tar.gz \
      && pip install --no-cache-dir /tmp/ewoc_s1-${EWOC_S1_VERSION}.tar.gz \
      && pip install --no-cache-dir psycopg2-binary
# Last package useful for AGU script

ARG EWOC_S1_DOCKER_VERSION='dev'
ENV EWOC_S1_DOCKER_VERSION=${EWOC_S1_DOCKER_VERSION}
LABEL version=${EWOC_S1_DOCKER_VERSION}

ADD entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
#CMD [ "-h" ]
