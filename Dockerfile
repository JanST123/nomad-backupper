FROM ubuntu:22.04

WORKDIR /root
RUN apt-get update && apt install -y mariadb-client lftp git curl golang ssmtp

COPY lftp-scripts/lftp-script /root/lftp-script
COPY lftp-scripts/lftp-ls-script /root/lftp-ls-script

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

COPY monitor.sh /root/monitor.sh
RUN chmod +x /root/monitor.sh

COPY etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.ext
RUN cat /etc/ssmtp/ssmtp.conf.ext >> /etc/ssmtp/ssmtp.conf

ENTRYPOINT [ "/root/entrypoint.sh" ]