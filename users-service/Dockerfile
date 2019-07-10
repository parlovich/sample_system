FROM python:2.7-alpine

EXPOSE 8081

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY user-service.py .
COPY users.json .

CMD [ "python", "./user-service.py" ]
