FROM python:3.8-alpine AS builder

COPY requirements.txt .
RUN apk --update --no-cache add openblas-dev freetype-dev
RUN apk --update --no-cache add --virtual .builddeps gcc build-base  g++ musl-dev  libpng-dev

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

COPY requirements.txt .
RUN pip install --user -r requirements.txt

RUN pip install --user cython==0.29.21 scipy==1.5.2
RUN pip install --user scikit-learn==0.22.1
RUN pip uninstall -y cython
RUN apk del --no-cache .builddeps

FROM python:3.8-alpine AS runner
WORKDIR app
RUN apk --update --no-cache add openblas-dev freetype-dev

COPY --from=builder /root/.local /root/.local

COPY test.py .
RUN ["python3", "test.py"]
