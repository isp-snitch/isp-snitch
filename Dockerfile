# Use Ubuntu 20.04 (same as GitHub Actions ubuntu-latest)
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SWIFT_VERSION=5.6

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    libssl-dev \
    libsqlite3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Swift 5.6
RUN wget -q https://download.swift.org/swift-5.6-release/ubuntu2004/swift-5.6-RELEASE/swift-5.6-RELEASE-ubuntu20.04.tar.gz && \
    tar xzf swift-5.6-RELEASE-ubuntu20.04.tar.gz && \
    mv swift-5.6-RELEASE-ubuntu20.04 /opt/swift && \
    rm swift-5.6-RELEASE-ubuntu20.04.tar.gz

# Add Swift to PATH
ENV PATH="/opt/swift/usr/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Build and test
RUN swift package resolve
RUN swift build --configuration debug -Xswiftc -parse-as-library
RUN swift test --parallel -Xswiftc -parse-as-library
