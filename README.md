# From Oracle to YugabyteDB with Debezium and Apicurio

## Overview

This working project demonstrates a Debezium setup for streaming data between
Oracle and YugabyteDB. Apicurio is also used as a schema registry to aid schema
managment between the producer and the sinks.

## Pull the Oracle Container

Unlike most containers, it is not possible to just download the Oracle
database. Oracle self hosts their own [registry](https://container-registry.oracle.com).
To be able to `pull` from the registry, create an account there and sign in.
Each container may require a license aggreement - click Database Repositories
and accept the terms for the "enterprise" repository (using the Continue
button). Once accpepted, log to the Oracle Registry with the Docker CLI:

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

This will start Zookeeper, Kafka, Kafka Connect, Apicurio, [Kafka UI](https://github.com/provectus/kafka-ui), Oracle and YugabyteDB (todo) and expose the following enpoints:

* [KakfaUI](http://localhost:8180/)

Confirm the container startup and monitor the logs:

```bash
docker compose ps
```

```bash
docker compose logs -f
```

## Run the Setup Scripts

The Oracle container is not automatically configured with logminer or a vaid user account for Debezium.  The provided
setup scripts will run the appropriate configuation for Oracle, Debezium and initialize the default schema(s) and data
to start the demonstration.

```bash
./setup.sh
```

```bash
http POST :8083/connectors @connector-json.json
```

* [Oracle Connector Properties](https://debezium.io/documentation/reference/stable/connectors/oracle.html#oracle-connector-properties)
