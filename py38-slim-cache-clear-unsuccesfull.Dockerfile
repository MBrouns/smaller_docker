FROM python:3.8-slim

COPY requirements.txt .

RUN pip install --user -r requirements.txt
RUN pip install --user scikit-learn==0.22.0

RUN rm -rf /root/.cache/pip
RUN find /root/.local/ -follow -type f -name '*.a' -delete
RUN find /root/.local/ -follow -type f -name '*.pyc' -delete
RUN find /root/.local/ -follow -type f -name '*.txt' -delete
RUN find /root/.local/ -follow -type f -name '*.md' -delete
RUN find /root/.local/ -follow -type f -name '*.png' -delete
RUN find /root/.local/ -follow -type f -name '*.jpg' -delete
RUN find /root/.local/ -follow -type f -name '*.jpeg' -delete
RUN find /root/.local/ -follow -type f -name '*.js.map' -delete
RUN find /root/.local/ -name '*.c' -delete
RUN find /root/.local/ -name '*.pxd' -delete
RUN find /root/.local/ -name '*.pyd' -delete
RUN find /usr/local/lib/python3.8 -name '__pycache__' | xargs rm -r


COPY test.py .
RUN ["python3", "test.py"]
