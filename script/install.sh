#!/bin/sh
# This script installs Kuzco on Linux.
# It detects the current operating system architecture and installs the appropriate version of Kuzco.

BUCKET_URL=${BUCKET_URL:-"https://sg.kuzco.xyz"}
WEB_URL=${WEB_URL:-"https://kuzco.xyz"}

set -eu

status() { echo ">>> $*" >&2; }
error() { echo "ERROR $*"; exit 1; }
warning() { echo "WARNING: $*"; }

TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf $TEMP_DIR; }
trap cleanup EXIT

available() { command -v $1 >/dev/null; }
require() {
    local MISSING=''
    for TOOL in $*; do
        if ! available $TOOL; then
            MISSING="$MISSING $TOOL"
        fi
    done

    echo $MISSING
}

[ "$(uname -s)" = "Linux" ] || error 'This script is intended to run on Linux only.'

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

KERN=$(uname -r)
case "$KERN" in
    *icrosoft*WSL2 | *icrosoft*wsl2) ;;
    *icrosoft) error "Microsoft WSL1 is not currently supported. Please upgrade to WSL2 with 'wsl --set-version <distro> 2'" ;;
    *) ;;
esac


SUDO=
if [ "$(id -u)" -ne 0 ]; then
    # Running as root, no need for sudo
    if ! available sudo; then
        error "This script requires superuser permissions. Please re-run as root."
    fi

    SUDO="sudo"
fi

NEEDS=$(require curl awk grep sed tee xargs)
if [ -n "$NEEDS" ]; then
    status "ERROR: The following tools are required but missing:"
    for NEED in $NEEDS; do
        echo "  - $NEED"
    done
    exit 1
fi

# Download versions.json for versioning (production kuzco.xyz)
download_versions_json() {
    # include timestamp to cache-bust
    local TIMESTAMP=$(date +%s)
    local VERSIONS_URL="$BUCKET_URL/cli-versions.json?t=$TIMESTAMP"
    curl --fail --show-error --location --progress-bar -o $TEMP_DIR/versions.json "$VERSIONS_URL"
}

status "Getting versions.json..."
download_versions_json

# Extract cli-latest version information
CLI_VERSION=$(awk -F'"' '/cli-latest/ {print $4}' $TEMP_DIR/versions.json)
echo "CLI_VERSION: $CLI_VERSION"

status "Downloading kuzco..."
curl --fail --show-error --location --progress-bar -o $TEMP_DIR/kuzco "$BUCKET_URL/cli/release/$ARCH/kuzco-linux-$ARCH-$CLI_VERSION"
curl --fail --show-error --location --progress-bar -o $TEMP_DIR/kuzco-runtime "$BUCKET_URL/cli/runtime/$ARCH/kuzco-runtime-linux-$ARCH-$CLI_VERSION"

for BINDIR in /usr/local/bin /usr/bin /bin; do
    echo $PATH | grep -q $BINDIR && break || continue
done

status "Installing kuzco to $BINDIR..."
$SUDO install -o0 -g0 -m755 -d $BINDIR
$SUDO install -o0 -g0 -m755 $TEMP_DIR/kuzco $BINDIR/kuzco
$SUDO install -o0 -g0 -m755 $TEMP_DIR/kuzco-runtime $BINDIR/kuzco-runtime

install_success() { 
    status 'Install complete. Run "kuzco init" from the command line.'
}
trap install_success EXIT

###########################################################
# The rest of this file trys to install NVIDIA CUDA drivers
# which is not strictly necessary but can be useful.
##########################################################

# if ! available lspci && ! available lshw; then
#     warning "Unable to detect NVIDIA GPU. Install lspci or lshw to automatically detect and install NVIDIA CUDA drivers."
#     exit 0
# fi

# check_gpu() {
#     # Look for devices based on vendor ID for NVIDIA and AMD
#     case $1 in
#         lspci) 
#             case $2 in
#                 nvidia) available lspci && lspci -d '10de:' | grep -q 'NVIDIA' || return 1 ;;
#                 amdgpu) available lspci && lspci -d '1002:' | grep -q 'AMD' || return 1 ;;
#             esac ;;
#         lshw) 
#             case $2 in
#                 nvidia) available lshw && $SUDO lshw -c display -numeric | grep -q 'vendor: .* \[10DE\]' || return 1 ;;
#                 amdgpu) available lshw && $SUDO lshw -c display -numeric | grep -q 'vendor: .* \[1002\]' || return 1 ;;
#             esac ;;
#         nvidia-smi) available nvidia-smi || return 1 ;;
#     esac
# }

# if check_gpu nvidia-smi; then
#     status "NVIDIA GPU installed."
#     exit 0
# fi

# if ! check_gpu lspci && ! check_gpu lshw; then
#     warning "No NVIDIA GPU detected. Kuzco will run in CPU-only mode."
#     exit 0
# fi

# if check_gpu lspci amdgpu || check_gpu lshw amdgpu; then
#     # Look for pre-existing ROCm v6 before downloading the dependencies
#     for search in "${HIP_PATH:-''}" "${ROCM_PATH:-''}" "/opt/rocm"; do
#         if [ -n "${search}" ] && [ -e "${search}/lib/libhipblas.so.2" ]; then
#             status "Compatible AMD GPU ROCm library detected at ${search}"
#             install_success
#             exit 0
#         fi
#     done

#     status "Downloading AMD GPU dependencies..."
#     curl --fail --show-error --location --progress-bar -o $TEMP_DIR/ "$BUCKET_URL/cli/runtime/amd64/kuzco-runtime-linux-amd64-rocm-$CLI_VERSION.tgz" \
#         | $SUDO tar zx -C $TEMP_DIR/rocm .

#     status "Installing AMD GPU dependencies to /opt/rocm..."
#     $SUDO install -o0 -g0 -m755 -d /opt/rocm
#     $SUDO cp -r $TEMP_DIR/rocm/* /opt/rocm/

#     install_success
#     status "AMD GPU dependencies installed."
#     exit 0
# fi

# # ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#rhel-7-centos-7
# # ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#rhel-8-rocky-8
# # ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#rhel-9-rocky-9
# # ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#fedora
# install_cuda_driver_yum() {
#     status 'Installing NVIDIA repository...'
#     case $PACKAGE_MANAGER in
#         yum)
#             $SUDO $PACKAGE_MANAGER -y install yum-utils
#             $SUDO $PACKAGE_MANAGER-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m)/cuda-$1$2.repo
#             ;;
#         dnf)
#             $SUDO $PACKAGE_MANAGER config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m)/cuda-$1$2.repo
#             ;;
#     esac

#     case $1 in
#         rhel)
#             status 'Installing EPEL repository...'
#             # EPEL is required for third-party dependencies such as dkms and libvdpau
#             $SUDO $PACKAGE_MANAGER -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$2.noarch.rpm || true
#             ;;
#     esac

#     status 'Installing CUDA driver...'

#     if [ "$1" = 'centos' ] || [ "$1$2" = 'rhel7' ]; then
#         $SUDO $PACKAGE_MANAGER -y install nvidia-driver-latest-dkms
#     fi

#     $SUDO $PACKAGE_MANAGER -y install cuda-drivers
# }

# # ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu
# # ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#debian
# install_cuda_driver_apt() {
#     status 'Installing NVIDIA repository...'
#     curl -fsSL -o $TEMP_DIR/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m)/cuda-keyring_1.1-1_all.deb

#     case $1 in
#         debian)
#             status 'Enabling contrib sources...'
#             $SUDO sed 's/main/contrib/' < /etc/apt/sources.list | $SUDO tee /etc/apt/sources.list.d/contrib.list > /dev/null
#             if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
#                 $SUDO sed 's/main/contrib/' < /etc/apt/sources.list.d/debian.sources | $SUDO tee /etc/apt/sources.list.d/contrib.sources > /dev/null
#             fi
#             ;;
#     esac

#     status 'Installing CUDA driver...'
#     $SUDO dpkg -i $TEMP_DIR/cuda-keyring.deb
#     $SUDO apt-get update

#     [ -n "$SUDO" ] && SUDO_E="$SUDO -E" || SUDO_E=
#     DEBIAN_FRONTEND=noninteractive $SUDO_E apt-get -y install cuda-drivers -q
# }

# if [ ! -f "/etc/os-release" ]; then
#     error "Unknown distribution. Skipping CUDA installation."
# fi

# . /etc/os-release

# OS_NAME=$ID
# OS_VERSION=$VERSION_ID

# PACKAGE_MANAGER=
# for PACKAGE_MANAGER in dnf yum apt-get; do
#     if available $PACKAGE_MANAGER; then
#         break
#     fi
# done

# if [ -z "$PACKAGE_MANAGER" ]; then
#     error "Unknown package manager. Skipping CUDA installation."
# fi

# if ! check_gpu nvidia-smi || [ -z "$(nvidia-smi | grep -o "CUDA Version: [0-9]*\.[0-9]*")" ]; then
#     case $OS_NAME in
#         centos|rhel) install_cuda_driver_yum 'rhel' $(echo $OS_VERSION | cut -d '.' -f 1) ;;
#         rocky) install_cuda_driver_yum 'rhel' $(echo $OS_VERSION | cut -c1) ;;
#         fedora) [ $OS_VERSION -lt '37' ] && install_cuda_driver_yum $OS_NAME $OS_VERSION || install_cuda_driver_yum $OS_NAME '37';;
#         amzn) install_cuda_driver_yum 'fedora' '37' ;;
#         debian) install_cuda_driver_apt $OS_NAME $OS_VERSION ;;
#         ubuntu) install_cuda_driver_apt $OS_NAME $(echo $OS_VERSION | sed 's/\.//') ;;
#         *) exit ;;
#     esac
# fi

# if ! lsmod | grep -q nvidia; then
#     KERNEL_RELEASE="$(uname -r)"
#     case $OS_NAME in
#         rocky) $SUDO $PACKAGE_MANAGER -y install kernel-devel kernel-headers ;;
#         centos|rhel|amzn) $SUDO $PACKAGE_MANAGER -y install kernel-devel-$KERNEL_RELEASE kernel-headers-$KERNEL_RELEASE ;;
#         fedora) $SUDO $PACKAGE_MANAGER -y install kernel-devel-$KERNEL_RELEASE ;;
#         debian|ubuntu) $SUDO apt-get -y install linux-headers-$KERNEL_RELEASE ;;
#         *) exit ;;
#     esac

#     NVIDIA_CUDA_VERSION=$($SUDO dkms status | awk -F: '/added/ { print $1 }')
#     if [ -n "$NVIDIA_CUDA_VERSION" ]; then
#         $SUDO dkms install $NVIDIA_CUDA_VERSION
#     fi

#     if lsmod | grep -q nouveau; then
#         status 'Reboot to complete NVIDIA CUDA driver install.'
#         exit 0
#     fi

#     $SUDO modprobe nvidia
# fi


# status "NVIDIA CUDA drivers installed."