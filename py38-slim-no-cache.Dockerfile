FROM python:3.8-slim

COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt scikit-learn==0.22.1 \
    && find /root/.local/ -follow -type f -name '*.a' -delete \
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


COPY test.py .
RUN ["python3", "test.py"]
