# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install any required dependencies
RUN apt-get update && apt-get install -y tar && apt-get clean

# Create a directory for the kernel build
WORKDIR /kernel

# Copy the kernel build artifact into the image
COPY kernel_build.tar.gz /kernel/

# Extract the kernel build artifact
RUN tar -xzvf kernel_build.tar.gz -C /kernel

# Set the entry point or command (optional)
# This example just keeps the container running
CMD ["bash"]
