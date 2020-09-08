FROM python:3.8-slim

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY test.py .
RUN ["python3", "test.py"]
