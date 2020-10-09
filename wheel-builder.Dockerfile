FROM python:3.8-alpine

COPY requirements.txt .
RUN apk --update --no-cache add openblas-dev freetype-dev
RUN apk --update --no-cache add --virtual .builddeps gcc build-base  g++ musl-dev  libpng-dev

RUN CFLAGS="-Os -g0 -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    FFLAGS="-shared" \
    LDFLAGS="-Wl,-shared" \
    pip wheel \
    --no-cache-dir \
    -w /root/wheels/ \
    --global-option=build_ext \
    --global-option="-j 4" \
    scipy


RUN apk --no-cache add  patchelf unzip
RUN pip install auditwheel

RUN find /root/wheels -name '*scipy*' | xargs auditwheel show
RUN find /root/wheels -name '*scipy*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN du -h /root/wheels
