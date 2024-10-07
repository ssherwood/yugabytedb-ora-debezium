#!/usr/bin/env bash

if ! docker compose > /dev/null 2>&1; then
  echo "This initialization script requires docker compose."
  echo "See the install instructions:  https://docs.docker.com/compose/install/"
  exit 1
fi

docker compose cp scripts/initLogminer.sh oracle-db:/tmp
docker compose exec oracle-db /tmp/initLogminer.sh

docker compose cp scripts/initSqlOra.sql oracle-db:/tmp
docker compose exec -it oracle-db sqlplus debezium/dbz@//localhost:1521/orclpdb1 @/tmp/initSqlOra.sql

docker compose cp scripts/initSqlYB.sql yugabytedb:/tmp
docker compose exec -it yugabytedb bash -c '/home/yugabyte/bin/ysqlsh -h $(hostname) -f /tmp/initSqlYB.sql'

docker compose cp scripts/initKafkaConnect.sh kafka-connect0:/tmp
docker compose exec kafka-connect0 /tmp/initKafkaConnect.sh
docker compose restart kafka-connect0
