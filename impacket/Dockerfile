FROM python:3-alpine
RUN apk --update --no-cache add \
    zlib-dev \
    musl-dev \
    libc-dev \
    gcc \
    libffi-dev \
    openssl-dev && \
    rm -rf /var/cache/apk/*
RUN mkdir -p /opt/impacket
COPY . /opt/impacket
WORKDIR /opt/impacket
RUN pip install .
WORKDIR /opt/impacket/examples
CMD ["python"]
