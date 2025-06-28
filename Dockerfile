FROM maven:3.9.6-eclipse-temurin-17

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    awscli \
    docker.io \
    gnupg2 \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl (pinned version)
RUN curl -LO "https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Add Jenkins user
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins
WORKDIR /home/jenkins
USER jenkins

ENTRYPOINT ["cat"]
