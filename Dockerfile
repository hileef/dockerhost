FROM alpine:latest

RUN apk --update --no-cache add iptables bash

COPY ./entrypoint.sh /

ENV PORTS=0:65535
ENTRYPOINT ["/entrypoint.sh"]