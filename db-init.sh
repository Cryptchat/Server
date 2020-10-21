#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
      CREATE USER cryptchat WITH PASSWORD '$POSTGRES_PASSWORD';
      EXCEPTION WHEN DUPLICATE_OBJECT THEN
      RAISE NOTICE 'cryptchat user already exists, skipping.';
    END
    \$\$;
    SELECT 'CREATE DATABASE cryptchat_production'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'cryptchat_production')\\gexec
    GRANT ALL PRIVILEGES ON DATABASE cryptchat_production TO cryptchat;
EOSQL
