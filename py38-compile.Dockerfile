FROM python:3.8-slim

COPY ./requirements.txt .

RUN buildDeps='build-essential gcc gfortran python3-dev' \
    && apt-get update \
    && apt-get install -y $buildDeps --no-install-recommends \
    && apt-get install libopenblas-dev liblapack-dev libfreetype6-dev libpng-dev pkg-config -y \
#    && CFLAGS="-g0 -Os -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
#        /usr/local/bin/pip install \
#        --no-cache-dir \
#        --compile \
#        --global-option=build_ext \
#        --global-option="-j 4" \
#        -r requirements.txt \
    && apt-get autoremove --purge -y $buildDeps \
    && rm -rf /var/lib/apt/lists/*

COPY test.py .
#RUN ["python3", "test.py"]
