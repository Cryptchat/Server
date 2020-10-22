#!/bin/bash

docker exec -it cryptchat-db /bin/bash -c 'psql -U cryptchat -d cryptchat_production'
