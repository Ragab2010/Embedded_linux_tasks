
SUMMARY = "Secure IoT Gateway image"

# Use core-image-minimal as the base
require recipes-core/images/core-image-minimal.bb

# Add necessary packages for the IoT gateway functionality
IMAGE_INSTALL:append = " \
    htop \
    iotop \
    collectd \
    nano \
    openssh \
    networkmanager \
    qtbase \
    pulseaudio \
    alsa-utils \
    openssl \
    vsomeip \
"


# Add Wi-Fi related packages for network management
IMAGE_INSTALL:append = " \
    linux-firmware \
    iw \
    wpa-supplicant \
    crda \
"

# Customize DISTRO_FEATURES to include necessary system capabilities
DISTRO_FEATURES:append = " \
    wifi \
    systemd \
    opengl \
    wayland \
    qt5 \
    alsa \
    pulseaudio \
    x11 \
    remote-server \
"



# Enable OpenSSH for SSH access
IMAGE_INSTALL:append = " \
    openssh-sftp-server \
    openssh-keygen \
"

# Optionally, specify IMAGE_FEATURES for additional functionalities
IMAGE_FEATURES:append = " \
    package-management \
    ssh-server-openssh \
    tools-debug \
    debug-tweaks \
"

# Ensure systemd is the default init system
IMAGE_INSTALL:append = " \
    systemd \
    systemd-analyze \
    systemd-compat-units \
"


# Ensure add helloiotapp to Image
IMAGE_INSTALL:append = " helloiotapp"


# Enable SSH access by ensuring SSH server is enabled at startup
SYSTEMD_AUTO_ENABLE = "enable"