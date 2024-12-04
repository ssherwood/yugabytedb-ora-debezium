# Migrating Data from Oracle to YugabyteDB with Debezium and Apicurio

## Overview

This project demonstrates using [Debezium](https://debezium.io/) to stream data
between Oracle and [YugabyteDB](https://www.yugabyte.com/). [Apicurio Registry](https://www.apicur.io/registry/)
is used as the schema registry to aid schema managment between the Producer and
the Sink(s).

## Get the Oracle Container

Unlike most other Docker containers, it is not possible to just download the
Oracle database. Oracle hosts their own [container registry](https://container-registry.oracle.com).
To `pull` from this registry, you will have to create an account.

Additionally, each container may require a separate license aggreement - click
"Database Repositories" and accept the terms for the "enterprise" repository
(using the Continue button). Once accpepted, log to the Oracle Registry with
the Docker CLI:

```bash
docker login -u <your account> container-registry.oracle.com
```

Download the container:

```bash
docker pull container-registry.oracle.com/database/enterprise:21.3.0.0
```

NOTE: A `404` error will occur if the license wasn't accpeted in the Oracle Registry portal.

## Run Docker Compose Up

```bash
docker compose up -d
```

```shell
[+] Running 8/8
 ⠿ Network apicurio_default              Created                        0.2s
 ⠿ Container apicurio-zookeeper0-1       Healthy                        6.3s
 ⠿ Container apicurio-oracle-db-1        Started                        0.8s
 ⠿ Container apicurio-yugabytedb-1       Started                        0.9s
 ⠿ Container apicurio-kafka0-1           Healthy                        13.0s
 ⠿ Container apicurio-schemaregistry0-1  Healthy                        18.8s
 ⠿ Container apicurio-debezium0-1        Healthy                        29.6s
 ⠿ Container apicurio-kafka-ui-1         Started                        30.2s
```

Confirm that the containers start up and monitor the logs:

```bash
docker compose ps
```

```bash
docker compose logs -f
```

It is recommended to keep tailing the logs as these will be useful to monitor
the initialization progress and additional configuration steps.

This will start Zookeeper, Kafka, Kafka Connect, Apicurio, [Kafka UI](https://github.com/provectus/kafka-ui),
Oracle and YugabyteDB (todo) and expose the following URLs:

* [KakfaUI](http://localhost:8180/)
* [Apicurio](http://localhost:8085/)
* [Yugabyted UI](http://localhost:15433/)
* [YugabyteDB Leader](http://localhost:7000/)
* [YugabyteDB TServer](http://localhost:9000/)

## Run the Initialization Scripts

The Oracle container will take a few minutes before the database will be ready.
The initial starup phase will occasionally emmit progress updates but will not
be ready until the logs show:

```shell
apicurio-oracle-db-1        | #########################
apicurio-oracle-db-1        | DATABASE IS READY TO USE!
apicurio-oracle-db-1        | #########################
```

Unfortunately, the container is not automatically configured with `logminer` or
a vaid user account for Debezium. The provided initialization scripts will run
the appropriate configuation for Oracle, Debezium and initialize the default
schema(s) and data to start the demonstration.

```bash
./init.sh
```

This script should do everything to configure the target and source database
with the demo schemas (and data for the Oracle source). The Debezium container
will also be configured with the require Oracle libraries and restarted.

## Deploy the Oracle Connector

```bash
http POST :8083/connectors @./connectors/connector-ora-json.json
```

This will activate the Oracle Debezium connector using LogMiner. It may take a
few minutes to fully activate and reflect with topics, connectors and data.

This connector is configured to use Apicurio's Json Converters and it's schema
registry implementation. With this pattern in place the messages published do
not contain the redundant schema information:

```json
{
	"schemaId": 4,
	"payload": {
		"before": null,
		"after": {
			"CUSTOMER_ID": "1",
			"DATE_OF_BIRTH": 474595200000,
			"FULL_NAME": "John Doe",
			"EMAIL": "john.doe@example.com",
			"CREATED_AT": 1733327361556671,
			"UPDATED_AT": 1733327361556671
		},
		"source": {
			"version": "3.0.3.Final",
			"connector": "oracle",
			"name": "ora_pdb1_debezium",
			"ts_ms": 1733328188000,
			"snapshot": "first",
			"db": "ORCLPDB1",
			"sequence": null,
			"ts_us": 1733328188000000,
			"ts_ns": 1733328188000000000,
			"schema": "DEBEZIUM",
			"table": "CUSTOMER",
			"txId": null,
			"scn": "2667232",
			"commit_scn": null,
			"lcr_position": null,
			"rs_id": null,
			"ssn": 0,
			"redo_thread": null,
			"user_name": null,
			"redo_sql": null,
			"row_id": null
		},
		"transaction": null,
		"op": "r",
		"ts_ms": 1733328193972,
		"ts_us": 1733328193972097,
		"ts_ns": 1733328193972097678
	}
}
```

A configuration of note is `decimal.handling.mode` of `string`. The default
behavior will encode the Oracle NUMERIC type and it is not very "human
readable". This configuration may not be desired for all use cases, but it aids
in visualizing the results during local testing.

For additional configuration options, review the [Oracle Connector Properties](https://debezium.io/documentation/reference/stable/connectors/oracle.html#oracle-connector-properties).

## Deploy the YugabyteDB Sink

Finally, deploy the YugabyteDB sink (the vanilla Debezium JDBC sink). This
connector will consume the topic `ora_pdb1_debezium.DEBEZIUM.CUSTOMER` and
write to the `public.${source.table}` (customer) table.

Ultimately the choice for which topics to consume and how to map them to their
underlying tables is up to the implementation as the choices can limit the
potential to scale out.

```bash
http POST :8083/connectors @./connectors/sink-ybdb-json.json
```

Configuration values of note:

- `connection.url` - specifically, `stringtype=unspecified` was needed to handle the decimal conversion done on the Oracle side as it makes the NUMERIC types come across as a string in the schema.

## TODOs

- Investigate DATE/TIME mappings as they are currently being consumed as numbers
- Add "Avaro" serization support and compare the differences
- 