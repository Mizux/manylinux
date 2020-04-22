# Create a virtual environment with all tools installed
FROM quay.io/pypa/manylinux2010_x86_64:latest AS env
LABEL maintainer="mizux.dev@gmail.com"

RUN yum -y update \
&& yum -y install git wget \
&& yum -y groupinstall "Development Tools" \
&& yum clean all \
&& rm -rf /var/cache/yum

# Install CMake 3.16.4
RUN wget "https://cmake.org/files/v3.16/cmake-3.16.4-Linux-x86_64.sh" \
&& chmod a+x cmake-3.16.4-Linux-x86_64.sh \
&& ./cmake-3.16.4-Linux-x86_64.sh --prefix=/usr --skip-license \
&& rm cmake-3.16.4-Linux-x86_64.sh

RUN cmake -version

FROM env AS devel
WORKDIR /home/project
# Copy the CMake project snippet
COPY CMakeLists.txt .
# Copy the build script
COPY build_manylinux.sh .
RUN chmod a+x build_manylinux.sh

FROM devel AS build
RUN ./build_manylinux.sh
