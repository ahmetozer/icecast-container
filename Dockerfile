FROM alpine

WORKDIR /root
RUN apk add icecast bash
COPY . .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/root/entrypoint.sh" ]