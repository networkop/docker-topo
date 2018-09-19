FROM alpine:latest

RUN apk update && \
    apk add libteam && \
    apk add open-lldp && \
    apk add sudo && \
    apk add tcpdump && \
    apk add scapy && \
    apk add iperf3

RUN adduser -u 1000 -G wheel -D alpine && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY entrypoint.sh /home/alpine/
RUN chmod +x /home/alpine/entrypoint.sh

USER alpine 

ENTRYPOINT ["/home/alpine/entrypoint.sh"]

CMD ["eth0:192.168.100.100/24"]
