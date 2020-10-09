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
    -r requirements.txt scipy==1.5.2

RUN pip3 install auditwheel==3.1.0

RUN find /root/wheels -name '*numpy-1.19*.whl' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*pandas*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*matplotlib*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*kiwisolver*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN find /root/wheels -name '*scipy*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
RUN pip install --user --no-index --find-links=/root/wheels -r requirements.txt scipy==1.5.2

RUN pip install cython==0.29.21
RUN CFLAGS="-g0 -Os -DNDEBUG -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    FFLAGS="-shared" \
    LDFLAGS="-Wl,-shared" \
    pip wheel \
    --no-cache-dir \
    -w /root/wheels/ \
    --global-option=build_ext \
    --global-option="-j 4" \
     scikit-learn==0.22.1

# If we don't uninstall numpy here, the pip install later on will think it's already there. We don't want this numpy
# though, we want the one with the wheel we compiled ourselves
RUN pip uninstall -y cython==0.29.21
RUN find /root/wheels -name '*scikit_learn*' | xargs auditwheel repair --plat=linux_x86_64 -w /root/wheels
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
    && find /root/.local/ -name 'test_*.py' -delete \
    && find /usr/local/lib/python3.8 -name '__pycache__' | xargs rm -r

RUN cd /root/.local/lib/python3.8/site-packages/ && \
 rm kiwisolver.libs/ld-musl-x86_64-0273b534.so.1 kiwisolver.libs/libgcc_s-a04fdf82.so.1 kiwisolver.libs/libstdc++-a9383cce.so.6.0.28 && \
 rm matplotlib.libs/ld-musl-x86_64-0273b534.so.1 matplotlib.libs/libgcc_s-a04fdf82.so.1 matplotlib.libs/libstdc++-a9383cce.so.6.0.28 && \
 rm pandas.libs/ld-musl-x86_64-0273b534.so.1 pandas.libs/libgcc_s-a04fdf82.so.1 pandas.libs/libstdc++-a9383cce.so.6.0.28 && \
 rm scikit_learn.libs/ld-musl-x86_64-0273b534.so.1 scikit_learn.libs/libgcc_s-a04fdf82.so.1 scikit_learn.libs/libstdc++-a9383cce.so.6.0.28 && \
 rm numpy.libs/ld-musl-x86_64-0273b534.so.1 numpy.libs/libgcc_s-a04fdf82.so.1

RUN cd /root/.local/lib/python3.8/site-packages/ && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/ld-musl-x86_64-0273b534.so.1 /root/.local/lib/python3.8/site-packages/numpy.libs/ld-musl-x86_64-0273b534.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libgcc_s-a04fdf82.so.1 /root/.local/lib/python3.8/site-packages/numpy.libs/libgcc_s-a04fdf82.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/ld-musl-x86_64-0273b534.so.1 /root/.local/lib/python3.8/site-packages/scikit_learn.libs/ld-musl-x86_64-0273b534.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libgcc_s-a04fdf82.so.1 /root/.local/lib/python3.8/site-packages/scikit_learn.libs/libgcc_s-a04fdf82.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libstdc++-a9383cce.so.6.0.28 /root/.local/lib/python3.8/site-packages/scikit_learn.libs/libstdc++-a9383cce.so.6.0.28 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/ld-musl-x86_64-0273b534.so.1 /root/.local/lib/python3.8/site-packages/pandas.libs/ld-musl-x86_64-0273b534.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libgcc_s-a04fdf82.so.1 /root/.local/lib/python3.8/site-packages/pandas.libs/libgcc_s-a04fdf82.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libstdc++-a9383cce.so.6.0.28 /root/.local/lib/python3.8/site-packages/pandas.libs/libstdc++-a9383cce.so.6.0.28 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/ld-musl-x86_64-0273b534.so.1 /root/.local/lib/python3.8/site-packages/matplotlib.libs/ld-musl-x86_64-0273b534.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libgcc_s-a04fdf82.so.1 /root/.local/lib/python3.8/site-packages/matplotlib.libs/libgcc_s-a04fdf82.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libstdc++-a9383cce.so.6.0.28 /root/.local/lib/python3.8/site-packages/matplotlib.libs/libstdc++-a9383cce.so.6.0.28 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/ld-musl-x86_64-0273b534.so.1 /root/.local/lib/python3.8/site-packages/kiwisolver.libs/ld-musl-x86_64-0273b534.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libgcc_s-a04fdf82.so.1 /root/.local/lib/python3.8/site-packages/kiwisolver.libs/libgcc_s-a04fdf82.so.1 && \
    ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libstdc++-a9383cce.so.6.0.28 /root/.local/lib/python3.8/site-packages/kiwisolver.libs/libstdc++-a9383cce.so.6.0.28

RUN rm /root/.local/lib/python3.8/site-packages/numpy.libs/libopenblasp-r0-52d5fd6e.3.9.so
RUN ln -s /root/.local/lib/python3.8/site-packages/scipy.libs/libopenblasp-r0-52d5fd6e.3.9.so /root/.local/lib/python3.8/site-packages/numpy.libs/libopenblasp-r0-52d5fd6e.3.9.so
FROM python:3.8-alpine AS runner
WORKDIR app

COPY --from=builder /root/.local /root/.local
ENV PYTHONDONTWRITEBYTECODE=True
COPY test.py .
RUN ["python3", "test.py"]

