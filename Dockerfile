FROM ubuntu:latest as builder

# Install dependencies

RUN apt update && apt install -y \
    build-essential \
    cmake \
    libglfw3-dev \
    libsuitesparse-dev \
    liblapacke-dev \
    povray \
    libfreetype6-dev \
    libunistring-dev \
    && apt clean

# Get the source code from GitHub
WORKDIR /tmp

RUN wget https://github.com/Morpho-lang/morpho/archive/refs/tags/v0.6.0.tar.gz && \
    tar -vxjf v0.6.0.tar.gz && \
RUN git clone https://github.com/Morpho-lang/morpho.git

# Build the source code

WORKDIR /morpho
RUN mkdir build
WORKDIR /morpho/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make install

# Now, get the CLI

WORKDIR /
RUN git clone https://github.com/Morpho-lang/morpho-cli.git
WORKDIR /morpho-cli
RUN mkdir build
WORKDIR /morpho-cli/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make install

# Get Morphoview

WORKDIR /
RUN git clone https://github.com/Morpho-lang/morpho-morphoview.git
WORKDIR /morpho-morphoview
RUN mkdir build
WORKDIR /morpho-morphoview/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make install

# Define the entry point

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["morpho6"]
