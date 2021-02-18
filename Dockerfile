FROM archlinux:latest

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"

RUN tee -a /etc/pacman.conf <<< '[community-testing]'; \
    tee -a /etc/pacman.conf <<< 'Include = /etc/pacman.d/mirrorlist'; \
    #
    # install packages
    pacman -Syu sudo git make automake gcc python go autoconf cmake pkgconf alsa-utils fakeroot \
    tigervnc xterm xorg-xhost xdotool ufw --noconfirm; \
    #
    # add user
    useradd arch; \
    echo 'arch ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers; \
    mkdir /home/arch; \
    chown arch:arch /home/arch;

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"


WORKDIR /home/arch/yay
RUN git clone https://aur.archlinux.org/yay.git .; \
    makepkg -si --noconfirm; \
    #
    # install packages
    pacman -Syu qemu libvirt dnsmasq virt-manager bridge-utils flex bison ebtables edk2-ovmf \
    netctl libvirt-dbus libguestfs --noconfirm;

WORKDIR /home/arch
ARG DOWNLOAD_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio"
RUN FILE_NAME="$(curl -s -N -L "$DOWNLOAD_URL" | grep -Po -m 1 '(?<=\")(?=(virtio-win-)).*?(?<=.iso)')"; \
    echo "Downloading $DOWNLOAD_URL/$FILE_NAME"; \
    curl -sSL -o virtio-win.iso "$DOWNLOAD_URL/$FILE_NAME";

ENV DISPLAY :0.0
ENV USER arch

COPY boot.sh boot.sh
ENTRYPOINT ./boot.sh
