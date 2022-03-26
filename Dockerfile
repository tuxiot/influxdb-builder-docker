FROM golang:1.17.0 AS dbuild

ENV DEBIAN_FRONTEND noninteractive

# Needed for Yarn steps to veryify the keys
RUN apt update
RUN apt install --yes curl gnupg2
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Now update index with Yarn
RUN apt update
RUN apt install --yes \
        git \
        libclang-dev \
        llvm-dev \
        make \
        nodejs \
        protobuf-compiler \
        ragel \
        yarn \
        clang \
        pkg-config \
        libprotobuf-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"


FROM dbuild AS dshell

ARG USERID=1000
RUN adduser --quiet --home /code --uid ${USERID} --disabled-password --gecos "" influx
USER influx

ENTRYPOINT [ "/bin/bash" ]

FROM dbuild AS dbuild-all

COPY . /code
WORKDIR /code
RUN go get github.com/influxdata/flux@v0.143.0 && go mod tidy && go mod vendor
RUN make

##
# InfluxDB Image (Monolith)
##
FROM debian:sid-slim AS influx

COPY --from=dbuild-all /code/bin/linux/influxd /usr/bin/influxd

EXPOSE 8086

ENTRYPOINT [ "/usr/bin/influxd" ]

