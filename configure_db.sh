#!/bin/bash
set -e

# Check current wal_level setting
WAL_LEVEL=$(psql -t -c "SHOW wal_level;" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB")

if [[ $WAL_LEVEL != "logical" ]]; then
    # Drop timescaledb if exists and adjust parameters
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        DROP EXTENSION IF EXISTS timescaledb;
EOSQL

    # Use ALTER SYSTEM commands outside of transaction block
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        ALTER SYSTEM SET wal_level = logical;
        ALTER SYSTEM SET max_replication_slots = 20;
        ALTER SYSTEM SET wal_keep_size = 2048;
EOSQL

    # Reload the configuration
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        SELECT pg_reload_conf();
EOSQL

    echo "All done please restart the database and delete this service."
else
    echo "DB is already configured"
fi
