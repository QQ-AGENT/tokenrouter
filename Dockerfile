FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY server.py /app/server.py
EXPOSE 9960
CMD ["python3", "server.py"]
