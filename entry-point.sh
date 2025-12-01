#!/bin/sh
set -e

while ! nc -z ${MYSQL_HOST} ${MYSQL_PORT}; do
  echo "MySQL not ready yet... retrying in 2 seconds"
  sleep 2
done

exec java \
  -Xms${JAVA_XMS} \
  -Xmx${JAVA_XMX} \
  -Ddatasource.dialect="${DB_DIALECT}" \
  -Ddatasource.url="${DB_URL}" \
  -Ddatasource.username="${DB_USER}" \
  -Ddatasource.password="${DB_PASS}" \
  -Dspring.profiles.active="${SPRING_PROFILE}" \
  -jar /lavagna/lavagna.war