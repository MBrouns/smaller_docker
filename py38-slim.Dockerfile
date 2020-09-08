FROM python:3.8-slim

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY test.py .
RUN ["python3", "test.py"]
