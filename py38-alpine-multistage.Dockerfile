FROM python:3.8-alpine AS builder

RUN apk --no-cache --update-cache add gcc gfortran python python-dev py-pip build-base wget freetype-dev libpng-dev openblas-dev
RUN apk --no-cache add lapack libstdc++ && apk --no-cache add --virtual .builddeps g++ gcc gfortran musl-dev lapack-dev
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

WORKDIR app

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt


FROM python:3.8-alpine AS runner
WORKDIR app
COPY --from=builder /root/.local /root/.local

COPY test.py .
RUN ["python3", "test.py"]
