FROM archlinux:latest

RUN pacman -Syu qemu --noconfirm;

WORKDIR /data

ENTRYPOINT ["qemu-img", "create", "-f", "raw", "win10_hdd.img"]

CMD [ "32G" ]
