FROM ubuntu:latest as builder

# Install dependencies

RUN apt update && apt install -y \
    build-essential \
    libc6 \
    cmake \
    libglfw3-dev \
    libsuitesparse-dev \
    liblapacke-dev \
    povray \
    libfreetype6-dev \
    libunistring-dev \
    wget \
    && apt clean

# Get the source code from GitHub
WORKDIR /tmp

RUN wget https://github.com/Morpho-lang/morpho/archive/refs/tags/v0.6.0.tar.gz && \
    tar -xf v0.6.0.tar.gz && \
    wget https://github.com/Morpho-lang/morpho-cli/archive/refs/tags/v0.6.0-alpha4.tar.gz && \
    tar -xf v0.6.0-alpha4.tar.gz && \
    wget https://github.com/Morpho-lang/morpho-morphoview/archive/refs/tags/v0.6.0-alpha2.tar.gz && \
    tar -xf v0.6.0-alpha2.tar.gz
    
# Build the source code

WORKDIR /tmp/morpho-0.6.0
RUN mkdir build
WORKDIR /tmp/morpho-0.6.0/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make install

# Build the CLI

WORKDIR /tmp/morpho-cli-0.6.0-alpha4
RUN mkdir build
WORKDIR /tmp/morpho-cli-0.6.0-alpha4/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make install

# Build Morphoview

WORKDIR /tmp/morpho-morphoview-0.6.0-alpha2
RUN mkdir build
WORKDIR /tmp/morpho-morphoview-0.6.0-alpha2/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make install

# Now create the final image
FROM ubuntu:latest

# Copy over the dependencies and installation from the builder image

COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/bin/povray /usr/bin/povray
# The following line somehow doesn't work, so we have to copy the libraries manually
# --> Doesn't work: COPY --from=builder /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu

# Manual copying of libraries
# libblas
COPY --from=builder /usr/lib/x86_64-linux-gnu/libblas.so.3 /usr/lib/x86_64-linux-gnu/libblas.so.3
# # libglfw
COPY --from=builder /usr/lib/x86_64-linux-gnu/libglfw.so /usr/lib/x86_64-linux-gnu/libglfw.so
# # libsuitesparse
COPY --from=builder /usr/lib/x86_64-linux-gnu/libsuitesparseconfig.so /usr/lib/x86_64-linux-gnu/libsuitesparseconfig.so
# # liblapack
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblapack.so /usr/lib/x86_64-linux-gnu/liblapack.so
# # liblapacke
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblapacke.so /usr/lib/x86_64-linux-gnu/liblapacke.so
# # libfreetype
COPY --from=builder /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/x86_64-linux-gnu/libfreetype.so
# # libunistring
COPY --from=builder /usr/lib/x86_64-linux-gnu/libunistring.so  /usr/lib/x86_64-linux-gnu/libunistring.so
# # libcxsparse
COPY --from=builder /usr/lib/x86_64-linux-gnu/libcxsparse.so /usr/lib/x86_64-linux-gnu/libcxsparse.so
# # libtmglib
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtmglib.so /usr/lib/x86_64-linux-gnu/libtmglib.so
# # libgfortran
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgfortran.so.5 /usr/lib/x86_64-linux-gnu/libgfortran.so.5

## For Morphoview
# libpng
COPY --from=builder /usr/lib/x86_64-linux-gnu/libpng16.so.16 /usr/lib/x86_64-linux-gnu/libpng16.so.16
# libbrotlidec
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1 /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1
# libx11
COPY --from=builder /usr/lib/x86_64-linux-gnu/libX11.so.6 /usr/lib/x86_64-linux-gnu/libX11.so.6
# libbrotlicommon
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1 /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1
# libxcb
COPY --from=builder /usr/lib/x86_64-linux-gnu/libxcb.so.1 /usr/lib/x86_64-linux-gnu/libxcb.so.1
# libxau
COPY --from=builder /usr/lib/x86_64-linux-gnu/libXau.so.6 /usr/lib/x86_64-linux-gnu/libXau.so.6
# libxdmcp
COPY --from=builder /usr/lib/x86_64-linux-gnu/libXdmcp.so.6 /usr/lib/x86_64-linux-gnu/libXdmcp.so.6

## For POVRay
# libbsd
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbsd.so.0 /usr/lib/x86_64-linux-gnu/libbsd.so.0
# libsdl
COPY --from=builder /usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0 /usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0
# libopenexr
COPY --from=builder /usr/lib/x86_64-linux-gnu/libOpenEXR-3_1.so.30 /usr/lib/x86_64-linux-gnu/libOpenEXR-3_1.so.30
# libImath-3_1.so.29
COPY --from=builder /usr/lib/x86_64-linux-gnu/libImath-3_1.so.29 /usr/lib/x86_64-linux-gnu/libImath-3_1.so.29
# libtiff.so.6
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtiff.so.6 /usr/lib/x86_64-linux-gnu/libtiff.so.6
# libjpeg.so.8
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjpeg.so.8 /usr/lib/x86_64-linux-gnu/libjpeg.so.8
# libboost_thread.so.1.83.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libboost_thread.so.1.83.0 /usr/lib/x86_64-linux-gnu/libboost_thread.so.1.83.0
# libIlmThread-3_1.so.30
COPY --from=builder /usr/lib/x86_64-linux-gnu/libIlmThread-3_1.so.30 /usr/lib/x86_64-linux-gnu/libIlmThread-3_1.so.30
# libIex-3_1.so.30
COPY --from=builder /usr/lib/x86_64-linux-gnu/libIex-3_1.so.30 /usr/lib/x86_64-linux-gnu/libIex-3_1.so.30
# libwebp.so.7
COPY --from=builder /usr/lib/x86_64-linux-gnu/libwebp.so.7 /usr/lib/x86_64-linux-gnu/libwebp.so.7
# libLerc.so.4
COPY --from=builder /usr/lib/x86_64-linux-gnu/libLerc.so.4 /usr/lib/x86_64-linux-gnu/libLerc.so.4
# libjbig.so.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjbig.so.0 /usr/lib/x86_64-linux-gnu/libjbig.so.0
# libdeflate.so.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libdeflate.so.0 /usr/lib/x86_64-linux-gnu/libdeflate.so.0
# libsharpyuv.so.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libsharpyuv.so.0 /usr/lib/x86_64-linux-gnu/libsharpyuv.so.0

# Regenerate the shared-library cache.
RUN ldconfig

# Define the entry point

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
