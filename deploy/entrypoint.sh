#!/bin/bash

# this script is probably not perfect, but it's good enough for my purposes
# I wouldn't use it on a real production system

# adapted from https://github.com/discourse/discourse_docker/blob/master/templates/web.letsencrypt.ssl.template.yml

set -e

mkdir -p /shared/log
mkdir -p /shared/ssl

cp /nginx.conf /etc/nginx/conf.d/cryptchat.conf
cp /nginx-letsencrypt.conf /etc/nginx/nginx-letsencrypt.conf
rm -f /etc/nginx/sites-enabled/default

cd /root && git clone --branch 2.8.2 --depth 1 https://github.com/Neilpang/acme.sh.git && cd /root/acme.sh
install -d -m 0755 -g root -o root $SSL_ROOT
cd /root/acme.sh && LE_WORKING_DIR="${SSL_ROOT}" ./acme.sh --install --log "${SSL_ROOT}/acme.sh.log"
cd /root/acme.sh && LE_WORKING_DIR="${SSL_ROOT}" ./acme.sh --upgrade --auto-upgrade

issue_cert() {
  LE_WORKING_DIR="${SSL_ROOT}" $SSL_ROOT/acme.sh --issue $2 -d $CRYPTCHAT_HOSTNAME --keylength $1 -w /Server/public
}
nginx -c /etc/nginx/nginx-letsencrypt.conf

cert_exists() {
  [[ "$(cd $SSL_ROOT/$CRYPTCHAT_HOSTNAME && openssl verify -CAfile ca.cer fullchain.cer | grep "OK")" ]]
}
if ! cert_exists; then
  issue_cert "4096"
fi
LE_WORKING_DIR="${SSL_ROOT}" $SSL_ROOT/acme.sh \
  --installcert \
  -d $CRYPTCHAT_HOSTNAME \
  --fullchainpath /shared/ssl/ssl.cer \
  --keypath /shared/ssl/ssl.key

nginx -t
service nginx restart || service nginx restart

cd /Server
git pull
bundle install --without development test
bundle exec rake db:migrate
bundle exec rake assets:precompile

rm -f /Server/tmp/pids/server.pid

exec "$@"
