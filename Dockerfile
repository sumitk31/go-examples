#------------------------------------------------------------------
# Dockerfile - Dockerfile of NOSi environment
#
# Copyright (c) 2021-2025 by Cisco Systems, Inc., and/or its affiliates.
# All rights reserved.
#------------------------------------------------------------------


# ---------- Build Stage ----------
FROM alpine:3.22 as builder

ENV REDIS_TIMESERIES_VERSION=1.10.13

RUN apk add --no-cache \
    bash \
    coreutils \
    git \
    cmake \
    automake \
    autoconf \
    libtool \
    build-base \
    openssl-dev \
    make \
    python3 \
    py3-pip \
    py3-virtualenv

# Clone and build RedisTimeSeries
WORKDIR /build
RUN git clone --branch v${REDIS_TIMESERIES_VERSION} https://github.com/RedisTimeSeries/RedisTimeSeries.git \
    && cd RedisTimeSeries \
    && git submodule update --init --recursive \
    && make \
    && mkdir -p /build/artifacts \
    && cp bin/linux-x64-release/redistimeseries.so /build/artifacts/

# ---------- Runtime Stage ----------
FROM redis:7.2.12-alpine as build_alp
#RUN apk add py3-setuptools
RUN apk add --no-cache python3 py3-pip
#RUN apk add  py3-virtualenv
COPY --from=builder /build/artifacts/redistimeseries.so /usr/lib/redis/modules/redistimeseries.so

#FROM python:3.12.9-alpine3.21 as python3
#FROM alpine:3.22 as python3
#FROM redislabs/redistimeseries:1.10.12 as build
#COPY --from=python3 / /
RUN mkdir -p /data1
ARG PLATFORM
ARG USE_CASES
ARG FILE_DIR
ARG SUPERD_CONF

COPY redis/redis.primary.conf /usr/local/etc/redis/redis.conf
RUN ls -l .
############## To be used in future if we need to patch a fix in the image.####################
#RUN apk add alpine-sdk
# Create a group and user
#RUN adduser -S packager -G abuild
#COPY libgcrypt_build /abuild
#RUN  chown packager /abuild
# Tell docker that all future commands should run as the appuser user
#USER packager
#RUN abuild-keygen -a -n
#RUN cd /abuild && abuild -r || true
#USER root
############## To be used in future if we need to patch a fix in the image.####################

RUN mkdir -p /var/log/nos-i
COPY $SUPERD_CONF /etc/supervisor/conf.d/supervisord.conf
COPY strip_all.py /usr/bin
RUN ls -l /usr/bin/strip_all.py
COPY requirements.txt /data1/
RUN ls -l /data1/requirements.txt
#COPY ./requirements.txt .
RUN echo " requirements.txt is:" && ls -l /data1/requirements.txt && cat /data1/requirements.txt
RUN sed -i 's/https/http/' /etc/apk/repositories
RUN   apk update \
      && apk upgrade \
      && apk add  file \
      && apk add  git \
      && apk add  -u c-ares \
      && apk add  -u pcre \
      && apk add  -u zlib \
      && apk add  -u py3-pycares \
      && apk add  -u grpc \
      && apk add  -u py3-grpcio \
      && apk add  -u make \
      && apk add  -u bash \
      && apk add  -u libgcrypt \
      && apk add  supervisor \
      && apk add  --no-cache logrotate

# Debug / Development mode utilities
RUN if [ "$FILE_DIR" = "src" ]; then \
    apk add vim; \
    pip3 install --break-system-packages  pytest; \
    pip3 install --break-system-packages  pytest-cov; \
    pip3 install --break-system-packages  pytest-ordering; \
    fi
RUN pip install --break-system-packages setuptools>=75.6.0
RUN pip install --break-system-packages 'grpcio-tools>=1.65.4'\
    && pip install --break-system-packages six\
    && pip install --break-system-packages 'cryptography>=42.0.0'
RUN apk add --no-cache ca-certificates && update-ca-certificates
RUN ls -l /data1
RUN pip3 install --break-system-packages -r /data1/requirements.txt
RUN rm -f /usr/bin/python \
    && rm -rf /root/.cache \
    && rm -f /usr/bin/pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip

# CVE-2025-8194 Official Patch
# (https://gist.github.com/sethmlarson/1716ac5b82b73dbcbf23ad2eff8b33e1)
COPY cve_2025_8194_official.py /data1/
COPY sitecustomize.py /data1/
RUN chmod +x /data1/cve_2025_8194_official.py

RUN cp /data1/sitecustomize.py /usr/lib/python3.12/site-packages/sitecustomize.py && \
    echo "✓ CVE-2025-8194 official patch installed for automatic loading"

WORKDIR /root
RUN mkdir cisco-gnmi-python
RUN git -c http.sslVerify=false clone http://github.com/cisco-ie/cisco-gnmi-python.git cisco-gnmi-python\
    && cd cisco-gnmi-python\
    && git submodule init\
    && git submodule update\
    && python setup.py sdist bdist_wheel\
    && sed -i 's/pipenv run python/python/g' update_protos.sh\
    && ./update_protos.sh\
    && cp -r src/cisco_gnmi/ /usr/lib/python3.12/site-packages/
    #&& cp src/cisco_gnmi/proto/*.py /usr/local/lib/python3.13/site-packages/cisco_gnmi/proto/

RUN rm -rf /root/cisco-gnmi-python

COPY csv_logs.logrotate /etc/logrotate.d/csv_logs


WORKDIR /data
#RUN apt-get update
#RUN apt-get upgrade -y libc6
#RUN apt-get purge -y vim vim-common vim-runtime  build-essential *-dev-* *-dev* perl-modules-5.32 gcc gcc-10 cpp cpp-10 g++ g++-10 libgcc-10-dev libgcc-8-dev
#RUN apt-get purge -y file
RUN apk del git xz xz-libs krb5 krb5-libs
RUN  rm -rf /usr/share/man/ /usr/share/cracklib /usr/share/doc /usr/share/locale/ \
     && rm -rf /var/cache/apk/ \
     && rm -rf /var/cache/apt \
     && rm -rf /var/lib/apt \
     && rm -rf /usr/lib/python3.12/__pycache__/ \
     && rm -rf /root/.cache/pip\
     && rm -rf /lib/x86_64-linux-gnu/libz.so.1.2.11

RUN ln -sf /hostetc/localtime /etc/localtime
COPY sorted_set_purge/$FILE_DIR/ sorted_set_purge/
COPY data_services/$FILE_DIR/ data_services/
COPY pipeline_monitor/$FILE_DIR/ pipeline_monitor/
COPY collector/$FILE_DIR/ collector/
COPY metric_analyzer/$FILE_DIR/ metric_analyzer/
COPY correlator/$FILE_DIR/ correlator/
COPY action/$FILE_DIR/ action/
COPY config/$FILE_DIR/ config/
# To be removed after migrating all usecases
#COPY config/src/usecases/ config/usecases/
COPY common/$FILE_DIR/ common/
COPY common/src/protos/ common/protos/
WORKDIR /data1
COPY tmp/ .

RUN /usr/bin/strip_all.py
ENV PYTHONPATH "${PYTHONPATH}:/data"
ENV PLATFORM $PLATFORM
ENV USE_CASES $USE_CASES

# Start with bash prompt in Debug / Development mode
COPY ./start_services.sh /
#CMD /start_services.sh

#this basically flattens all the layers to single layer reducing the image size
#FROM scratch

ARG PLATFORM
ARG USE_CASES
ARG FILE_DIR
ARG SUPERD_CONF

ENV PYTHONPATH "${PYTHONPATH}:/data"
ENV PLATFORM $PLATFORM
ENV USE_CASES $USE_CASES

# Suppress pkg_resources deprecation warning related to setuptools
ENV PYTHONWARNINGS "ignore:pkg_resources is deprecated:UserWarning"

RUN rm -rf /etc/ssl/certs/* /usr/local/bin/gosu /usr/lib/x86_64-linux-gnu/libgcrypt.so.*
RUN rm -rf /usr/share/ca-certificates/mozilla/
RUN find /usr/local/lib/python3.12/ -name *.pem | xargs rm -f
RUN find /usr/local/lib/python3.9/ -name *.pem | xargs rm -f
RUN find /usr/lib/python3.12/ -name *.pem | xargs rm -f
RUN rm -f /usr/lib/python3.12/ensurepip/_bundled/pip-*.whl || true
RUN rm -f /usr/local/lib/python3.12/ensurepip/_bundled/pip-*.whl || true
RUN rm -f /bin/tar
# CVE-2025-8194 Final Check: Verify official patch is working
RUN echo "=== CVE Security Status ===" && \
    python3 --version && \
    python3 -c "import sys; print(f'Python version: {sys.version_info}')" && \
    echo "CVE-2025-8194: Testing official patch (Seth Larson's implementation)..." && \
    cd /data1 && python3 cve_2025_8194_official.py && \
    echo "✓ CVE-2025-8194 official patch verified" && \
    echo "======================="

# In production change path of starting supervisord without debug shell
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
