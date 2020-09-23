FROM python:3.8-alpine

COPY requirements.txt .
RUN apk --update --no-cache add openblas-dev freetype-dev
RUN apk --update --no-cache add --virtual .builddeps gcc build-base  g++ musl-dev  libpng-dev

RUN pip wheel -w /root/wheels/ pandas


RUN pip install auditwheel
RUN apk --no-cache add  unzip patchelf
RUN find /root/wheels -name '*pandas*' | xargs auditwheel show
RUN find /root/wheels -name '*pandas*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
