# Base image
FROM debian:bullseye

# Set build arguments
ARG ARCH=arm64
ARG KERNEL_VERSION=6.6

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    bc \
    libncurses5-dev \
    bison \
    flex \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download and build the kernel
WORKDIR /usr/src
RUN wget https://github.com/raspberrypi/linux/archive/refs/tags/raspberrypi-kernel_$KERNEL_VERSION.tar.gz -O kernel.tar.gz && \
    tar -xf kernel.tar.gz && \
    cd linux-raspberrypi-kernel_$KERNEL_VERSION && \
    make ARCH=$ARCH bcm2711_defconfig && \
    make ARCH=$ARCH -j$(nproc)

# Copy the compiled kernel
RUN mkdir -p /output && cp arch/$ARCH/boot/Image /output/kernel.img

# Final image
FROM scratch
COPY --from=0 /output/kernel.img /
