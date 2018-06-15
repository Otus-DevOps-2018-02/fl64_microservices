FROM python:3.6.0-alpine

WORKDIR /app
COPY . /app
## added dev packets (musl-dev gcc)
RUN apk update && apk add musl-dev gcc && pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
