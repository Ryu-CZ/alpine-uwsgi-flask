# start from basic alpine python
FROM python:3-alpine

# sign yourself
MAINTAINER Ryu-CZ

# Docker is able to use stack of layers form previous builds.
# So lets palce commands whish does always same thing first
EXPOSE 5000
RUN mkdir -p /opt/app && mkdir -p /etc/app
VOLUME ["/etc/app"]
WORKDIR /opt/app

# Dependecies could change or get upgraded occasionally.
COPY requirements.txt /opt/app

# Install dependencies
# gcc libc-dev linux-headers are libs and tools for uwsgi building
# clear not required data at the end to reduce image size
RUN set -e; \
	apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		linux-headers \
	; \
	pip install --no-cache-dir -r requirements.txt; \
	apk del .build-deps;

# Your code is changing frequently, place it as last to prevent creation of new layer stack
COPY [".", "/opt/app"]

# this will be executed by docker when you run the image
ENTRYPOINT ["uwsgi", "--ini-paste", "/opt/app/uwsgi.ini"]