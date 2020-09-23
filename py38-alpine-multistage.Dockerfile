FROM python:3.8-alpine AS builder

RUN apk --update add gcc build-base freetype-dev libpng-dev openblas-dev
RUN apk --no-cache add --virtual .builddeps g++ musl-dev
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

WORKDIR app
COPY requirements.txt .

RUN pip install -r requirements.txt

RUN pip install cython==0.29.21
RUN pip install scipy==1.5.2
RUN pip install scikit-learn==0.22.1

FROM python:3.8-alpine AS runner
WORKDIR app
COPY --from=builder /root/.local /root/.local

COPY test.py .
RUN ["python3", "test.py"]
