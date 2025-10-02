#!/bin/bash

# --- Configuration Variables ---
# Recommended Kubernetes version stream (e.g., v1.28)
K8S_VERSION_STREAM="v1.28"
CONTAINERD_VERSION="containerd.io" # Use this for stable Docker/Containerd package

echo "--- Starting Kubernetes Pre-Installation Script ---"

# ==============================
# 1. System Setup and Kernel Modules
# ==============================
echo "1. Configuring System and Kernel Modules..."

# Turn off swap permanently and temporarily
# Note: /etc/fstab changes require a reboot to take full effect, but for immediate setup:
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab # Comment out swap entries in /etc/fstab

# Load necessary kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add the necessary sysctl parameters for Kubernetes networking
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply the new sysctl parameters immediately
sudo sysctl --system

echo "System configuration complete."
echo "------------------------------"

# ==============================
# 2. Install Containerd
# ==============================
echo "2. Installing and Configuring Containerd..."

# Install prerequisite packages for adding new repositories
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Containerd
sudo apt-get update
sudo apt-get install -y "${CONTAINERD_VERSION}"

# Configure containerd to use the systemd cgroup driver (required by Kubernetes)
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# Replace the SystemdCgroup setting
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart and enable containerd service
sudo systemctl restart containerd
sudo systemctl enable containerd --now

echo "Containerd installed and configured."
echo "------------------------------"

# ==============================
# 3. Install Kubeadm, Kubelet, and Kubectl
# ==============================
echo "3. Installing Kubernetes Tools (Kubelet, Kubeadm, Kubectl)..."

# Install necessary packages for Kubernetes repository
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download the official Kubernetes GPG key
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_VERSION_STREAM}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes repository to your system's package list
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION_STREAM}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# Install Kubelet, Kubeadm, and Kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Hold the packages to prevent accidental updates
sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes tools installed and held."
echo "------------------------------"

echo "--- Kubernetes Pre-Installation Complete ---"
echo "The system is now ready for 'sudo kubeadm init' or 'sudo kubeadm join'."
