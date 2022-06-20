#!/bin/bash

set -euo pipefail

set -x

if [ "$1" = "import" ]; then
    # Ensure that database directory is in right state
    chown postgres:postgres -R /var/lib/postgresql
    if [ ! -f /var/lib/postgresql/12/main/PG_VERSION ]; then
        sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /var/lib/postgresql/12/main/ initdb -o "--locale C.UTF-8"
    fi

    # Initialize PostgreSQL
    createPostgresConfig
    service postgresql start
    echo "Postgres" | psql -U postgres -h 172.17.0.2 -c "CREATE USER renderer;"
    echo "Postgres" | psql -U postgres -h 172.17.0.2 -c "CREATE DATABASE  gis"
    echo "Postgres" | psql -U postgres -h 172.17.0.2 -c "ALTER DATABASE gis OWNER TO renderer;"
    echo "Postgres" | psql -U postgres -d gis -h 172.17.0.2 -c "CREATE EXTENSION postgis;" 
    echo "Postgres" | psql -U postgres -d gis -h 172.17.0.2 -c "CREATE EXTENSION hstore;"
    echo "Postgres" | psql -U postgres -d gis -h 172.17.0.2 -c "ALTER TABLE geometry_columns OWNER TO renderer;"
    echo "Postgres" | psql -U postgres -d gis -h 172.17.0.2 -c "ALTER TABLE spatial_ref_sys OWNER TO renderer;"
    echo "Postgres" | psql -U postgres -d gis -h 172.17.0.2 -c "ALTER USER renderer PASSWORD 'Postgres';"
    echo "Postgres" | psql -U postgres -h 172.17.0.2 -d gis -c "GRANT ALL PRIVILEGES ON DATABASE gis TO renderer;"
    echo "Postgres" | psql -U postgres -h 172.17.0.2 -d gis -c "GRANT CONNECT ON DATABASE gis TO renderer";
    setPostgresPassword

    # Download Luxembourg as sample if no data is provided
    if [ ! -f /data.osm.pbf ] && [ -z "${DOWNLOAD_PBF:-}" ]; then
        echo "WARNING: No import file at /data.osm.pbf, so importing Luxembourg as example..."
        DOWNLOAD_PBF="https://download.geofabrik.de/asia/india-latest.osm.pbf"
        DOWNLOAD_POLY="https://download.geofabrik.de/asia/india.poly"
    fi

    if [ -n "${DOWNLOAD_PBF:-}" ]; then
        echo "INFO: Download PBF file: $DOWNLOAD_PBF"
        wget ${WGET_ARGS:-} "$DOWNLOAD_PBF" -O /data.osm.pbf
        if [ -n "$DOWNLOAD_POLY" ]; then
            echo "INFO: Download PBF-POLY file: $DOWNLOAD_POLY"
            wget ${WGET_ARGS:-} "$DOWNLOAD_POLY" -O /data.poly
        fi
    fi

    if [ "${UPDATES:-}" = "enabled" ]; then
        # determine and set osmosis_replication_timestamp (for consecutive updates)
        osmium fileinfo /data.osm.pbf > /var/lib/mod_tile/data.osm.pbf.info
        osmium fileinfo /data.osm.pbf | grep 'osmosis_replication_timestamp=' | cut -b35-44 > /var/lib/mod_tile/replication_timestamp.txt
        REPLICATION_TIMESTAMP=$(cat /var/lib/mod_tile/replication_timestamp.txt)

        # initial setup of osmosis workspace (for consecutive updates)
        sudo -u renderer openstreetmap-tiles-update-expire $REPLICATION_TIMESTAMP
    fi

    # copy polygon file if available
    if [ -f /data.poly ]; then
        sudo -u renderer cp /data.poly /var/lib/mod_tile/data.poly
    fi
    
    echo mapnik-config --input-plugins
    
    # Import data
    echo "Postgres" | sudo -u postgres osm2pgsql -d gis -H 172.17.0.2 -W --create --slim -G --hstore --tag-transform-script /home/renderer/src/openstreetmap-carto/openstreetmap-carto.lua --number-processes ${THREADS:-4} -S /home/renderer/src/openstreetmap-carto/openstreetmap-carto.style /data.osm.pbf ${OSM2PGSQL_EXTRA_ARGS:-}

    # Create indexes
    echo "Postgres" | sudo -u postgres psql -d gis -h 172.17.0.2 -f /home/renderer/src/openstreetmap-carto/indexes.sql 

    #Import external data
    sudo chown -R renderer: /home/renderer/src
    echo "Postgres" | sudo -E -u postgres -h 172.17.0.2 python3 /home/renderer/src/openstreetmap-carto/scripts/get-shapefiles.py
    
    # echo "Postgres" | sudo -E -u renderer -h 172.17.0.2 python3 /home/renderer/src/openstreetmap-carto/scripts/get-shapefiles.py 

    # Register that data has changed for mod_tile caching purposes
    touch /var/lib/mod_tile/planet-import-complete

    exit 0
fi
