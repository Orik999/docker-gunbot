####    Starting point resourse link
####    https://github.com/computeronix/docker-gunbot/blob/stable/Dockerfile#L77
####
ARG GUNBOTVERSION="latest"
ARG GITHUBOWNER="GuntharDeNiro"
ARG GITHUBREPO="BTCT"
ARG GBINSTALLLOC="/opt/gunbot"
ARG GBMOUNT="/mnt/gunbot"
ARG GBPORT=5000
ARG MAINTAINER="Gunthy"
ARG WEBSITE="https://github.com/GuntharDeNiro/BTCT"
ARG DESCRIPTION="docker file alpine, containerized gunbot - ${GUNBOTVERSION}"

FROM alpine:latest AS gunbot-builder
ARG GUNBOTVERSION
ARG GITHUBOWNER
ARG GITHUBREPO
ARG GBINSTALLLOC
ARG GBMOUNT
ARG GBPORT

WORKDIR /tmp

RUN apk update \
  && apk add --no-cache wget jq unzip openssl \
  && rm -rf /var/lib/apt/lists/* \
  && wget -q -nv -O gunbot.zip $(wget -q -nv -O- https://api.github.com/repos/${GITHUBOWNER}/${GITHUBREPO}/releases/${GUNBOTVERSION} 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("gunthy_linux")) | .browser_download_url') \
  && unzip -qd . gunbot.zip \
  && mv gunthy_linux gunbot \
  && printf "[req]\n" > ssl.config \
  && printf "distinguished_name = req_distinguished_name\n" >> ssl.config \
  && printf "prompt = no\n" >> ssl.config \
  && printf "[req_distinguished_name]\n" >> ssl.config \
  && printf "commonName = localhost\n" >> ssl.config \
  && openssl req -config ssl.config -newkey rsa:2048 -nodes -keyout gunbot/localhost.key -x509 -days 365 -out gunbot/localhost.crt

COPY startup.sh /tmp/gunbot
COPY config-binance.js.bak /tmp/gunbot
COPY config.js.bak /tmp/gunbot

RUN cp -rf gunbot/config.js.bak gunbot/config.js

FROM alpine:latest
ARG MAINTAINER
ARG WEBSITE
ARG DESCRIPTION
ARG GBINSTALLLOC
ARG GBPORT
ENV GUNBOTLOCATION=${GBINSTALLLOC}

ENV HTTPS_ENABLE=false \
    AUTH_PASS=false

LABEL \
  maintainer="${MAINTAINER}" \
  website="${WEBSITE}" \
  description="${DESCRIPTION}"

COPY --from=gunbot-builder /tmp/gunbot ${GBINSTALLLOC}

WORKDIR ${GBINSTALLLOC}

RUN apk update \
  && apk add --no-cache libc6-compat gcompat libstdc++ jq tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && chmod +x "${GBINSTALLLOC}/startup.sh"

EXPOSE ${GBPORT}
CMD ["sh","-c","${GUNBOTLOCATION}/startup.sh"]