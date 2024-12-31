# Base image
FROM debian:bullseye as builder

# Set build arguments
ARG ARCH=arm64
ARG KERNEL_BRANCH=rpi-5.13.y
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
    wget \
    curl \
    gcc \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src

# Clone the Raspberry Pi kernel repository
RUN git clone --branch ${KERNEL_BRANCH} --depth 1 https://github.com/raspberrypi/linux.git kernel

# Change to the kernel directory
WORKDIR /usr/src/kernel

# Check if the defconfig file exists
RUN if [ ! -f "arch/${ARCH}/configs/bcm2711_defconfig" ]; then \
    echo "Error: bcm2711_defconfig not found for ARCH=${ARCH}"; \
    exit 1; \
    fi

# Build the kernel
RUN make ARCH=${ARCH} bcm2711_defconfig && \
    make ARCH=${ARCH} -j$(nproc || echo 1)

# Copy the built kernel image to the output directory
RUN mkdir -p ${OUTPUT_DIR} && cp arch/${ARCH}/boot/Image ${OUTPUT_DIR}/kernel.img

# Final image with the kernel
FROM scratch
COPY --from=builder /output/kernel.img /kernel.img
