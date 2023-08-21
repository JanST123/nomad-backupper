FROM ubuntu:22.04

WORKDIR /root
RUN apt-get update && apt install -y mariadb-client lftp git curl golang

COPY lftp-scripts/lftp-script /root/lftp-script
COPY lftp-scripts/lftp-ls-script /root/lftp-ls-script
COPY entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh


ENTRYPOINT [ "/root/entrypoint.sh" ]