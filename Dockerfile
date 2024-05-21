# Use an official Ubuntu base image
FROM nvidia/cuda:11.6.1-runtime-ubuntu20.04

WORKDIR /root/

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    echo "tzdata tzdata/Areas select Asia" | debconf-set-selections && \
    echo "tzdata tzdata/Zones/Asia select Shanghai" | debconf-set-selections && \
    apt-get install -y curl unzip pciutils expect && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY models/ /root/.kuzco/models/

COPY script/ /root/script/

RUN chmod +x /root/script/install.sh /root/script/versioncheck.sh /root/script/kuzco_start.exp /root/script/worker.sh && \
    /root/script/install.sh

HEALTHCHECK --interval=1m --timeout=3s --retries=3 CMD /bin/bash /root/script/healthcheck.sh

CMD ["/root/script/worker.sh"]