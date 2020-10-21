#!/bin/bash
set -e

cd /Server
bundle exec rake db:migrate
bundle exec rake assets:precompile

rm -f /Server/tmp/pids/server.pid

exec "$@"
