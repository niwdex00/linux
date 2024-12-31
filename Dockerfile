# Base image
FROM debian:bullseye

# Set build arguments
ARG ARCH=arm64
ARG KERNEL_TAG=rpi-6.12.y_20241206_2
ARG OUTPUT_DIR=/output

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

# Set working directory
WORKDIR /usr/src

# Clone the repository
RUN git clone https://github.com/raspberrypi/linux.git kernel

# Checkout the specified tag and build the kernel
WORKDIR /usr/src/kernel
RUN git checkout tags/${KERNEL_TAG} -b build && \
    make ARCH=${ARCH} bcm2711_defconfig && \
    make ARCH=${ARCH} -j$(nproc)

# Copy the built kernel to the output directory
RUN mkdir -p ${OUTPUT_DIR} && cp arch/${ARCH}/boot/Image ${OUTPUT_DIR}/kernel.img

# Final image with the kernel
FROM scratch
COPY --from=0 /output/kernel.img /kernel.img
