FROM archlinux:latest

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

USER arch

WORKDIR /home/arch/yay
RUN git clone https://aur.archlinux.org/yay.git .; \
    makepkg -si --noconfirm; \
    #
    # install packages
    sudo pacman -Syu qemu libvirt dnsmasq virt-manager bridge-utils flex bison ebtables edk2-ovmf \
    netctl libvirt-dbus libguestfs --noconfirm;

WORKDIR /home/arch
ARG DOWNLOAD_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio"
RUN FILE_NAME="$(curl -s -N -L "$DOWNLOAD_URL" | grep -Po -m 1 '(?<=\")(?=(virtio-win-)).*?(?<=.iso)')"; \
    echo "Downloading $DOWNLOAD_URL/$FILE_NAME"; \
    curl -sSL -o virtio-win.iso "$DOWNLOAD_URL/$FILE_NAME";

ENV DISPLAY :0.0
ENV USER arch

USER root

COPY boot.sh boot.sh
ENTRYPOINT ./boot.sh
