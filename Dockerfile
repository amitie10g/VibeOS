FROM ubuntu:noble AS downloader
ADD https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip /root

WORKDIR /root
RUN apt-get update && apt-get install -y git unzip
RUN unzip freedoom-0.13.0.zip && \
    git clone https://github.com/kaansenol5/tlse

FROM ubuntu:noble AS builder
ARG DOOM1_WAD=/root/freedoom-0.13.0/freedoom1.wad

RUN apt-get update && apt-get install -y \
        dosfstools \
        gcc-aarch64-linux-gnu \
        git \
        make \
        python3 \
        qemu-system-aarch64 \
        rsync \
        sudo

WORKDIR /root/vibeos
COPY --from=downloader $DOOM1_WAD ./vibeos_root/games/doom1.wad
COPY --from=downloader /root/tlse vendor/tlse
COPY . .

RUN make && make user

EXPOSE 5900

ENTRYPOINT ["/bin/sh", "-c", "make sync-disk && exec \"$@\"", "--"]
CMD ["make", "run-vnc"]
