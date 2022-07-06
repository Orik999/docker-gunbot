#!/bin/sh
[ ! -d /mnt/gunbot1 ] && \
 mkdir /mnt/gunbot1
 
[ ! -d /mnt/gunbot/json ] && \
mkdir /mnt/gunbot/json && \
ln -sf /mnt/gunbot/json /opt/gunbot/json || \
ln -sf /mnt/gunbot/json /opt/gunbot/json

[ ! -d /mnt/gunbot/logs ] && \
mkdir /mnt/gunbot/logs && \
ln -sf /mnt/gunbot/logs /opt/gunbot/logs || \
ln -sf /mnt/gunbot/logs /opt/gunbot/logs

[ ! -d /mnt/gunbot/backups ] && \
mkdir /mnt/gunbot/backups && \
ln -sf /mnt/gunbot/backups /opt/gunbot/backups || \
ln -sf /mnt/gunbot/backups /opt/gunbot/backups

[ ! -d /mnt/gunbot/customStrategies ] && \
mkdir /mnt/gunbot/customStrategies && \
ln -sf /mnt/gunbot/customStrategies /opt/gunbot/customStrategies || \
ln -sf /mnt/gunbot/customStrategies /opt/gunbot/customStrategies

[ ! -f /mnt/gunbot/config.js ] && \
cp /opt/gunbot/config.js /mnt/gunbot/config.js && \
ln -sf /mnt/gunbot/config.js /opt/gunbot/config.js || \
ln -sf /mnt/gunbot/config.js /opt/gunbot/config.js

[ ! -f /mnt/gunbot/UTAconfig.json ] && \
cp /opt/gunbot/UTAconfig.json /mnt/gunbot/UTAconfig.json && \
ln -sf /mnt/gunbot/UTAconfig.json /opt/gunbot/UTAconfig.json || \
ln -sf /mnt/gunbot/UTAconfig.json /opt/gunbot/UTAconfig.json

[ ! -f /mnt/gunbot/autoconfig.json ] && \
cp /opt/gunbot/autoconfig.json /mnt/gunbot/autoconfig.json && \
ln -sf /mnt/gunbot/autoconfig.json /opt/gunbot/autoconfig.json || \
ln -sf /mnt/gunbot/autoconfig.json /opt/gunbot/autoconfig.json

[ ! -f /mnt/gunbot/gunbotgui.db ] && \
touch /opt/gunbot/gunbotgui.db && \
cp /opt/gunbot/gunbotgui.db /mnt/gunbot/gunbotgui.db && \
ln -sf /mnt/gunbot/gunbotgui.db /opt/gunbot/gunbotgui.db || \
ln -sf /mnt/gunbot/gunbotgui.db /opt/gunbot/gunbotgui.db

[ ! -f /mnt/gunbot/new_gui.sqlite ] && \
touch /opt/gunbot/new_gui.sqlite && \
cp /opt/gunbot/new_gui.sqlite /mnt/gunbot/new_gui.sqlite && \
ln -sf /mnt/gunbot/new_gui.sqlite /opt/gunbot/new_gui.sqlite || \
ln -sf /mnt/gunbot/new_gui.sqlite /opt/gunbot/new_gui.sqlite

[ ! -s /mnt/gunbot/config-js-example.txt ] && \
cp /opt/gunbot/config-js-example.txt /mnt/gunbot/config-js-example.txt

[ ! -s /mnt/gunbot/config.js ] && \
cp /opt/gunbot/config.js.bak /mnt/gunbot/config.js

[ ! -f /etc/localtime ] && \
cp /usr/share/zoneinfo/"$TZ" /etc/localtime

[ ! -s /etc/timezone ] && \
echo "$TZ" >  /etc/timezone

#   If MASTER_KEY_FILE exists Then set MASTER_KEY var
[ -f "$MASTER_KEY_FILE" ] && MASTER_KEY=$(cat "${MASTER_KEY_FILE}")
#   If MASTER_SECRET_FILE exists Then set MASTER_SECRE var
[ -f "$MASTER_SECRET_FILE" ] && MASTER_SECRET=$(cat "${MASTER_SECRET_FILE}")

#   If MASTER_KEY not empty and if config.js is not greater than 3.4kb Then replace config.js with config-binance.js
[ ! -z "${MASTER_KEY+x}" ] && [[ ! $(find /mnt/gunbot/config.js -type f -size +3052c 2>/dev/null) ]] && cp -rf /opt/gunbot/config-binance.js.bak /mnt/gunbot/config.js

#   If MASTER_KEY is not 0 chars Then apply MASTER_KEY var
[ ! -z "${MASTER_KEY+x}" ] && jq '.exchanges.binance.masterkey = '\"$MASTER_KEY\"'' /mnt/gunbot/config.js > /tmp/config2.js
#   If MASTER_SECRET is not 0 chars Then apply MASTER_SECRET var
[ ! -z "${MASTER_SECRET+x}" ] && jq '.exchanges.binance.mastersecret = '\"$MASTER_SECRET\"'' /tmp/config2.js > /mnt/gunbot/config.js

#   If GUNTHY_WALLET_FILE exists Then set GUNTHY_WALLET var
[ -f "$GUNTHY_WALLET_FILE" ] && GUNTHY_WALLET=$(cat "${GUNTHY_WALLET_FILE}")
#   If GUNTHY_WALLET is 42 chars Then apply GUNTHY_WALLET var
[ ! -z "${GUNTHY_WALLET+x}" ] && jq '.bot.gunthy_wallet = '\"$GUNTHY_WALLET\"'' /mnt/gunbot/config.js > /tmp/config2.js && mv -f /tmp/config2.js /mnt/gunbot/config.js

jq '.GUI.https = '$HTTPS_ENABLE'' /mnt/gunbot/config.js > /tmp/config2.js
jq '.GUI.authentication.login = '$AUTH_PASS'' /tmp/config2.js > /tmp/config3.js
jq '.GUI.port = 5000' /tmp/config3.js > /tmp/config4.js
jq '.bot.json_output = "/opt/gunbot/json"' /tmp/config4.js > /mnt/gunbot/config.js
rm -rf /tmp/*
/opt/gunbot/gunthy-linux
