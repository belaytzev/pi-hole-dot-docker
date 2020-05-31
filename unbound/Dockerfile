FROM alpine:latest

RUN apk --update --no-cache add unbound drill ca-certificates bash
COPY unbound.conf /etc/unbound/unbound.conf
COPY forward-zone.conf /etc/unbound/forward-zone.conf
COPY --chown=unbound:unbound prepare.sh /opt/unbound/prepare.sh
COPY --chown=unbound:unbound run.sh /opt/unbound/run.sh

EXPOSE 53/tcp
EXPOSE 53/udp

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD drill @127.0.0.1 cloudflare.com || exit 1

CMD ["/opt/unbound/run.sh"]