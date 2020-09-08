FROM python:3.8-slim AS builder

RUN apt-get update && apt-get install -y build-essential gcc gfortran python3-dev libopenblas-dev liblapack-dev libfreetype6-dev libpng-dev pkg-config --no-install-recommends

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

RUN apt-get update && apt-get install -y unzip patchelf --no-install-recommends

RUN pip3 install auditwheel
#RUN find /root/wheels -name '*numpy*' | xargs auditwheel show
RUN find /root/wheels -name '*numpy*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
#RUN find /root/wheels -name '*matplotlib*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels

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

FROM python:3.8-slim AS runner
WORKDIR app
RUN apt-get update && apt-get install -y libfreetype6 --no-install-recommends && rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/.local /root/.local
ENV PYTHONDONTWRITEBYTECODE=True
COPY test.py .
RUN ["python3", "test.py"]

