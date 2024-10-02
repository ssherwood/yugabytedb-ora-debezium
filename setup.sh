docker compose cp setupLogminer.sh oracle-db:/tmp
docker compose cp setupSql.sql oracle-db:/tmp
docker compose exec oracle-db /tmp/setupLogminer.sh
docker compose exec -it oracle-db sqlplus debezium/dbz@//localhost:1521/orclpdb1 @/tmp/setupSql.sql

docker compose cp setupConnect.sh kafka-connect0:/tmp
docker compose exec kafka-connect0 /tmp/setupConnect.sh
docker compose restart kafka-connect0
