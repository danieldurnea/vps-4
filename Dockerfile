FROM ubuntu:22.04

# Hardcoded credentials
ENV USER=morningstar


# Install SSH and sudo, clean up after
RUN apt-get update -yq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    openssh-server \
    openssh-client \
    curl \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Prepare SSH configuration
RUN mkdir -p /run/sshd && \
    # Remove any existing PasswordAuthentication lines
    sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config

# Create user with password and give sudo access
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USER && \
    chown -R $USER:$USER /home/$USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy autoconnect/start script (if you have one)
COPY linux-ssh.sh /linux-ssh.sh
RUN chmod +x /linux-ssh.sh && chown $USER:$USER /linux-ssh.sh

# Expose SSH port
EXPOSE 22

# Start SSH daemon
CMD ["/linux-ssh.sh"]
