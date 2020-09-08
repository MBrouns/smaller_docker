FROM python:3.8-alpine

COPY requirements.txt .
RUN apk --update add gcc build-base freetype-dev libpng-dev openblas-dev

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN pip install -r requirements.txt
COPY test.py .
RUN ["python3", "test.py"]
