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
FROM centos:centos7.9.2009
LABEL maintainer="CS GROUP France"
LABEL version="1.0"
LABEL description="This docker allow to run S1Tiling processing chain."

WORKDIR /tmp

RUN yum update -y && yum upgrade -y && yum install -y python36 python3-devel file gcc-c++
RUN yum install -y centos-release-scl \
      && yum-config-manager --enable rhel-server-rhscl-7-rpms \
      && yum install -y devtoolset-7
SHELL ["/usr/bin/scl", "enable", "devtoolset-7"]
RUN yum install -y freeglut mesa-libEGL-devel mesa-libGL-devel

ADD cmake-3.18.4-Linux-x86_64.tar.gz /opt/

RUN python3 -m pip install --upgrade pip \
      && python3 -m pip install virtualenv \
      && python3 -m pip install numpy

ADD OTB-7.2.0-Linux64.run /tmp
ENV OTB_INSTALL_DIRPATH=/opt/otb-7.2.0
RUN chmod +x OTB-7.2.0-Linux64.run \
      && ./OTB-7.2.0-Linux64.run --target ${OTB_INSTALL_DIRPATH} \
      && cd ${OTB_INSTALL_DIRPATH}  \
      && . ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && /opt/cmake-3.18.4-Linux-x86_64/bin/ctest -S ${OTB_INSTALL_DIRPATH}/share/otb/swig/build_wrapping.cmake -VV

ADD gdal-config ${OTB_INSTALL_DIRPATH}/bin
RUN chmod +x ${OTB_INSTALL_DIRPATH}/bin/gdal-config

RUN echo "# Patching for s1tiling" >> ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && echo 'LD_LIBRARY_PATH=$(cat_path "${CMAKE_PREFIX_PATH}/lib" "$LD_LIBRARY_PATH")' >> ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && echo "export LD_LIBRARY_PATH" >> ${OTB_INSTALL_DIRPATH}/otbenv.profile

ARG S1TILING_VERSION=0.2.0rc2
ENV S1TILING_VENV=/opt/s1tiling-venv
RUN python3 -m virtualenv ${S1TILING_VENV} \
      && . ${OTB_INSTALL_DIRPATH}/otbenv.profile \
      && source ${S1TILING_VENV}/bin/activate \
      && pip install numpy \
      && pip install S1Tiling==${S1TILING_VERSION} \
      && pip install pipdeptree




ADD entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "-h" ]