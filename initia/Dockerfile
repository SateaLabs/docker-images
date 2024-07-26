FROM ubuntu:22.04

RUN apt-get update -y && \
    apt-get install wget curl build-essential make gcc jq git lz4 -y && \
    rm -rf /usr/local/go

RUN curl -L https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz | tar -xzf - -C /usr/local

ENV GOPATH $HOME/go
ENV PATH $PATH:/usr/local/go/bin:$HOME/go/bin
ENV INITIA_VERSION v0.2.14
RUN git clone https://github.com/initia-labs/initia.git && \
    cd initia && \
    git checkout $INITIA_VERSION && \
    make install

ENV moniker test
ENV chainId initiation-1

ENV SLINKY_VERSION v0.4.3
RUN git clone https://github.com/skip-mev/slinky.git && \
    cd slinky && \
    git checkout $SLINKY_VERSION && \
    make build

COPY ./init.sh ./init.sh

RUN chmod +x ./init.sh
# RUN sh init.sh

ENTRYPOINT ["sh","init.sh"]