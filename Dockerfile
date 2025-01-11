# ===========================================================================================
# Dockerfile for building yocto on an arm64 system like a macbook M*
#
# References:
# https://github.com/gmacario/easy-build/blob/main/build-yocto/Dockerfile
# ===========================================================================================

FROM arm64v8/ubuntu:22.04

RUN apt-get update && apt-get -y upgrade

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        vim \ 
        gawk \
        curl \
        wget \
        git-core \
        subversion \
        diffstat \
        unzip \
        sysstat \
        texinfo \
        build-essential \
        chrpath \
        socat \
        python3 \
        python3-pip \
        python3-pexpect \
        xz-utils  \
        locales \
        cpio \
        screen \
        tmux \
        sudo \
        iputils-ping \
        python3-git \
        python3-jinja2 \
        libegl1-mesa \
        libsdl1.2-dev \
        pylint \
        xterm \
        iproute2 \
        fluxbox \
        tightvncserver \
        lz4 \
        zstd \
        file && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            DEBIAN_FRONTEND=noninteractive apt-get install -y \
                gcc-multilib \
                g++-multilib \
            ;; \
    esac && \
    cp -af /etc/skel/ /etc/vncskel/ && \
    echo "export DISPLAY=1" >>/etc/vncskel/.bashrc && \
    mkdir  /etc/vncskel/.vnc && \
    echo "" | vncpasswd -f > /etc/vncskel/.vnc/passwd && \
    chmod 0600 /etc/vncskel/.vnc/passwd && \
    groupadd -g 1001 yoctouser && \
    useradd -m -u 1001 -g 1001 yoctouser && \
    /usr/sbin/locale-gen en_US.UTF-8 && \
    echo 'dash dash/sh boolean false' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

COPY build-install-dumb-init.sh /
RUN  bash /build-install-dumb-init.sh && \
     rm /build-install-dumb-init.sh && \
     apt-get clean

RUN curl -o /usr/local/bin/repo http://commondatastorage.googleapis.com/git-repo-downloads/repo
RUN chmod a+x /usr/local/bin/repo

USER yoctouser
WORKDIR /home/yoctouser

# this is not persisting ?
RUN git config --global user.email "tylernol@mac.com"
RUN git config --global user.name "Tyler Arnold"
# firewall issue workaround force to use https 
RUN git config --global url."https://github.com/".insteadOf git@github.com:
RUN git config --global url."https://".insteadOf git://

CMD /bin/bash

# EOF
