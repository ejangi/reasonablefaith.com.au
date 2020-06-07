#!/usr/bin/env bash

# Start the sql proxy
if [ "$_CLOUDSQL_INSTANCE" ]; then
    echo >&2 "Starting cloud_sql_proxy to: ${_CLOUDSQL_INSTANCE}"
    cloud_sql_proxy -instances=${_CLOUDSQL_INSTANCE}=tcp:3306 &
fi

# Execute the rest of your ENTRYPOINT and CMD as expected.
exec "$@"