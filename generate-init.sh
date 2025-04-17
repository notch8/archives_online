#!/bin/bash
set -e

DB_HOST="${DATABASE_HOST:-db}"

# Wait until MySQL is ready
until mysqladmin ping -h "$DB_HOST" -u root -p${MYSQL_ROOT_PASSWORD} --silent; do
  echo "Waiting for MySQL to be ready..."
  sleep 2
done

# Prepare the SQL script with environment variables substituted
cat <<-EOSQL > /tmp/init.sql.template
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE DATABASE IF NOT EXISTS ${TEST_DB};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${TEST_DB}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

# Substitute environment variables and save the result to a new file
envsubst < /tmp/init.sql.template > /tmp/init.sql

# Run the SQL script
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -h "$DB_HOST" < /tmp/init.sql

echo "Database setup and user permissions granted."
