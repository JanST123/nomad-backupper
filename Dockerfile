FROM ubuntu:22.04

WORKDIR /root
RUN apt-get update && apt install -y mariadb-client lftp git curl golang

COPY lftp-scripts/lftp-script /root/lftp-script
COPY lftp-scripts/lftp-ls-script /root/lftp-ls-script
COPY entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh

RUN sed -i "s/FTP_HOST/${FTP_HOST}/g" /root/lftp-script
RUN sed -i "s/FTP_HOST/${FTP_HOST}/g" /root/lftp-ls-script
RUN sed -i "s/FTP_USER/${FTP_USER}/g" /root/lftp-script
RUN sed -i "s/FTP_USER/${FTP_USER}/g" /root/lftp-ls-script
RUN sed -i "s/FTP_PASS/${FTP_PASS}/g" /root/lftp-script
RUN sed -i "s/FTP_PASS/${FTP_PASS}/g" /root/lftp-ls-script


ENTRYPOINT [ "/root/entrypoint.sh" ]