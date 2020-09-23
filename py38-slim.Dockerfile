FROM python:3.8-slim

COPY requirements.txt .

RUN pip install --user -r requirements.txt
RUN  pip install --user scikit-learn==0.22.1

COPY test.py .
RUN ["python3", "test.py"]
