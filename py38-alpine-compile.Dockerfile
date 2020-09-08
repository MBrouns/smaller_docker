FROM python:3.8-alpine AS builder

ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on

RUN apk --update add gcc build-base freetype-dev libpng-dev openblas-dev
RUN apk --no-cache add  unzip patchelf
#apk add --no-cache cmake gcc libxml2 \
#       automake g++ subversion python3-dev \
#       libxml2-dev libxslt-dev lapack-dev gfortran

WORKDIR app
RUN pip install cython
COPY requirements.txt .

RUN CFLAGS="-g0 -Os -DNDEBUG -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    FFLAGS="-shared" \
    LDFLAGS="-Wl,-shared" \
    pip wheel \
    --no-cache-dir \
    -w /root/wheels/ \
    --global-option=build_ext \
    --global-option="-j 4" \
    -r requirements.txt

RUN pip install --user --no-index --find-links=/root/wheels -r requirements.txt

RUN pip3 install auditwheel
RUN find /root/wheels -name '*numpy*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*pandas*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*matplotlib*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*kiwisolver*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*scikit-learn*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels

RUN pip install --user --no-index --find-links=/root/wheels -r requirements.txt

RUN find /root/.local/ -follow -type f -name '*.a' -delete \
    && find /root/.local/ -follow -type f -name '*.pyc' -delete \
    && find /root/.local/ -follow -type f -name '*.txt' -delete \
    && find /root/.local/ -follow -type f -name '*.mc' -delete \
    && find /root/.local/ -follow -type f -name '*.js.map' -delete \
    && find /root/.local/ -name '*.c' -delete \
    && find /root/.local/ -name '*.pxd' -delete \
    && find /root/.local/ -follow -type f -name '*.md' -delete \
    && find /root/.local/ -follow -type f -name '*.png' -delete \
    && find /root/.local/ -follow -type f -name '*.jpg' -delete \
    && find /root/.local/ -follow -type f -name '*.jpeg' -delete \
    && find /root/.local/ -name '*.pyd' -delete \
    && find /usr/local/lib/python3.8 -name '__pycache__' | xargs rm -r

FROM python:3.8-alpine AS runner
WORKDIR app
RUN apk --no-cache --update-cache add freetype
COPY --from=builder /root/.local /root/.local
ENV PYTHONDONTWRITEBYTECODE=True
COPY test.py .
RUN ["python3", "test.py"]

