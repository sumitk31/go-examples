FROM quay.io/centos/centos:stream10 as buildsrc


RUN dnf update -y && dnf groupinstall -y "Development Tools" && \
    dnf install -y rpm-build redhat-rpm-config attr libacl-devel libselinux-devel policycoreutils

RUN dnf --enablerepo=crb install -y texinfo


RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

FROM quay.io/centos/centos:stream10 as build
RUN dnf update -y && \
    dnf install -y --nobest bc vim git iproute tcpdump strace procps openssh-clients openssh-server iputils iptables \
    net-tools zstd lsof file hostname lz4 less libatomic libevent libicu boost openssl nmap python3-pip openssl-devel bzip2-devel \
    libffi-devel zlib zlib-devel cmake autoconf automake libtool gcc make  libpsl-devel && dnf clean all

RUN dnf --nogpgcheck --refresh --assumeyes --nodocs --setopt=install_weak_deps=False upgrade \
 && dnf --nogpgcheck --assumeyes --nodocs --setopt=install_weak_deps=False install createrepo_c dnf-utils gnupg \
 && dnf autoremove --assumeyes \
 && dnf clean all \
 && rm -rf /var/cache/dnf/* \
 && rm -rf /var/lib/dnf/yumdb/* \
 && rm -rf /var/lib/dnf/history/* \
 && rm -rf /tmp/* \
 && rm -rf /var/lib/rpm/__db.* \
 && rm -rf /usr/share/man/ /usr/share/cracklib /usr/share/doc /usr/share/locale/

 RUN dnf install -y  wget
 RUN wget https://yum.oracle.com/repo/OracleLinux/OL10/baseos/latest/x86_64/getPackage/libicu-74.2-5.el10_0.x86_64.rpm
 RUN rpm -Uvh libicu-74.2-5.el10_0.x86_64.rpm && rm -f libicu-74.2-5.el10_0.x86_64.rpm

# Build curl 8.16.0 from source for latest security fixes
 RUN curl -LO https://curl.se/download/curl-8.16.0.tar.gz
 RUN tar -xf curl-8.16.0.tar.gz
 RUN cd curl-8.16.0 && \
     ./configure --with-openssl --enable-ipv6 --disable-static --prefix=/usr && \
     make -j$(nproc) && \
     make install
 RUN rm -rf curl-8.16.0 curl-8.16.0.tar.gz
 RUN dnf remove -y wget


# Remove system python3-pip to eliminate old bundled packages (requests 2.31.0, certifi 2023.07.22)
RUN dnf remove -y python3-pip && dnf clean all
# Reinstall pip fresh and install required packages
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install --upgrade "pip>=25.1"

RUN pip3 install click hexdump networkx pyzmq tabulate zstd zstandard
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade "requests>=2.32.4"
RUN pip3 install --upgrade "certifi>=2024.7.4"
RUN rm  -rf /usr/share/python3-wheels/pip-23.3.2-py3-none-any.whl

# Build iperf3 with cjson integration
RUN git clone https://github.com/DaveGamble/cJSON.git
RUN git clone https://github.com/esnet/iperf.git
#copy cjson files to iperf src
RUN cp cJSON/cJSON.h iperf/src/
RUN cp cJSON/cJSON.c iperf/src/
#move cJSON.c/.h to cjson.c/h in iperf
RUN mv iperf/src/cJSON.c iperf/src/cjson.c
RUN mv iperf/src/cJSON.h iperf/src/cjson.h
#update cjson.c with include change
RUN sed -i 's/#include "cJSON.h"/#include "cjson.h"/' iperf/src/cjson.c
RUN cd iperf && \
    ./bootstrap.sh && \
    ./configure &&  \
    make -j$(nproc) && \
    make install

RUN rm -rf /cJSON /iperf
#copy iperf3 to /usr/bin
RUN ln -s /usr/local/bin/iperf3 /usr/bin/iperf3

# Clone and fix bunch manually
RUN git clone https://github.com/dsc/bunch.git
RUN dnf remove -y  git*
#RUN curl -L https://github.com/dsc/bunch/archive/refs/tags/1.0.1.tar.gz | tar xz && \
RUN    sed -i "s/'rU'/'r'/" bunch/setup.py && \
    pip3 install ./bunch

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#remove cmake,autoconf,automake,libtool,gcc,make (build dependencies)
RUN dnf remove -y cmake autoconf automake libtool gcc make  && dnf clean all
#clean up dnf cache again
RUN rm -rf /var/cache/dnf/* \
 && rm -rf /var/lib/dnf/yumdb/* \
 && rm -rf /var/lib/dnf/history/* \
 && rm -rf /tmp/* \
 && rm -rf /var/lib/rpm/__db.*

#Clear dnf log and keep backup file.
RUN mv /var/log/dnf.log /var/log/dnfbackup.log;

RUN  ln -sf /hostetc/localtime /etc/localtime
COPY netns.conf /usr/lib/tmpfiles.d/netns.conf
COPY sandbox_firstboot.service /lib/systemd/system/sandbox_firstboot.service
COPY sandbox_firstboot.sh /usr/bin/sandbox_firstboot.sh

COPY sandbox_refresh_available_pkgs.service /lib/systemd/system/sandbox_refresh_available_pkgs.service
COPY sandbox_refresh_available_pkgs.sh /usr/bin/sandbox_refresh_available_pkgs.sh

#rm any pycache
RUN rm -rf /usr/lib64/python3.12/__pycache__/ && rm -rf /root/.cache/pip
RUN  systemctl enable sandbox_firstboot
RUN  systemctl enable sandbox_refresh_available_pkgs

FROM scratch
COPY --from=build / /
ENV container docker

VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/usr/lib/systemd/systemd"]
