FROM alpine

RUN apk add icecast bash
WORKDIR /usr/share/icecast/
COPY . .
RUN mkdir -p /usr/share/icecast/log && \
    chown -R 100:101 /usr/share/icecast && \
    chown -R 100:101 /var/log/icecast && \
    chown -R 100:101 /etc/icecast.xml && \
    chmod +x entrypoint.sh
USER icecast
LABEL org.opencontainers.image.source="https://github.com/ahmetozer/icecast-container"
ENTRYPOINT [ "/usr/share/icecast/entrypoint.sh" ]