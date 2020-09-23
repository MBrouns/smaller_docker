FROM python:3.8-alpine AS builder

ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on

RUN apk --update add gcc build-base freetype-dev libpng-dev openblas-dev
RUN apk --no-cache add  unzip patchelf

WORKDIR app
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

RUN pip install cython==0.29.21
RUN pip install numpy==1.19.2
RUN pip install scipy==1.5.2
RUN CFLAGS="-g0 -Os -DNDEBUG -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    FFLAGS="-shared" \
    LDFLAGS="-Wl,-shared" \
    pip wheel \
    --no-cache-dir \
    -w /root/wheels/ \
    --global-option=build_ext \
    --global-option="-j 4" \
     scipy==1.5.2 scikit-learn==0.22.1

# If we don't uninstall numpy here, the pip install later on will think it's already there. We don't want this numpy
# though, we want the one with the wheel we compiled ourselves
RUN pip uninstall -y numpy==1.19.2 scipy==1.5.2 cython==0.29.21

RUN pip3 install auditwheel==3.1.0

RUN find /root/wheels -name '*numpy-1.19*.whl' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*pandas*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*matplotlib*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*kiwisolver*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*scikit_learn*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*scipy*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels

RUN pip install --user --no-index --find-links=/root/wheels -r requirements.txt
RUN pip install --user --no-index --find-links=/root/wheels scikit-learn

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

COPY --from=builder /root/.local /root/.local
ENV PYTHONDONTWRITEBYTECODE=True
COPY test.py .
RUN ["python3", "test.py"]

