# Base image
FROM debian:bullseye

# Set build arguments
ARG ARCH=arm64
ARG KERNEL_VERSION=rpi-6.12.y_20241206_2

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    bc \
    libncurses5-dev \
    bison \
    flex \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository and build the kernel
WORKDIR /usr/src
RUN git clone --depth 1 --branch $KERNEL_VERSION https://github.com/raspberrypi/linux.git kernel && \
    cd kernel && \
    make ARCH=$ARCH bcm2711_defconfig && \
    make ARCH=$ARCH -j$(nproc)

# Copy the compiled kernel
RUN mkdir -p /output && cp kernel/arch/$ARCH/boot/Image /output/kernel.img

# Final image
FROM scratch
COPY --from=0 /output/kernel.img /kernel.img
