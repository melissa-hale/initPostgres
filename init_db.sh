#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  DO
  \$body\$
  DECLARE
    wal_level_setting TEXT;
  BEGIN
    SELECT current_setting('wal_level') INTO wal_level_setting;

    IF wal_level_setting != 'logical' THEN
      EXECUTE 'DROP EXTENSION IF EXISTS timescaledb';
      EXECUTE 'ALTER SYSTEM SET wal_level = logical';
      EXECUTE 'ALTER SYSTEM SET max_replication_slots = 20';
      EXECUTE 'ALTER SYSTEM SET wal_keep_size = 2048';
      EXECUTE 'SELECT pg_reload_conf()';
      RAISE NOTICE 'All done please restart the database and delete this service. Here is the DATABASE_URL: %', current_setting('DATABASE_URL');
    ELSE
      RAISE NOTICE 'DB is already configured';
    END IF;
  END;
  \$body\$
  ;
EOSQL
