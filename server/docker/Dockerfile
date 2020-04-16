#基础image
FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -y install wget \
    && apt-get -y install net-tools \
    && apt-get -y install libreadline-dev \
    && apt-get -y install build-essential \
    && apt-get -y install --no-install-recommends wget gnupg ca-certificates \
    && wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - \
    && apt-get -y install --no-install-recommends software-properties-common \
    && add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
    && apt-get update \
    && apt-get -y install openresty

CMD ["/bin/bash"]
