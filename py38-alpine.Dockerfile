FROM python:3.8-alpine

COPY requirements.txt .
RUN apk --update --no-cache add openblas-dev freetype-dev
RUN apk --update --no-cache add --virtual .builddeps gcc build-base  g++ musl-dev  libpng-dev

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

COPY requirements.txt .
RUN pip install -r requirements.txt

# We can't scikit-learn using requirements.txt in one go here: pip passes through your requirements twice.
# First it downloads all packages and runs each setup.py. Then it installs them all in a second pass.
# Because scikit-learn imports numpy in its setup, it fails in the first pass
RUN pip install cython==0.29.21 scipy==1.5.2
RUN pip install scikit-learn==0.22.1
RUN apk del --no-cache .builddeps

COPY test.py .
RUN ["python3", "test.py"]
