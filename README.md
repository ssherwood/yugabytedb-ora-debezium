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

```shell
[+] Running 7/7
 ⠿ Network apicurio_default              Created                                               0.2s
 ⠿ Container apicurio-zookeeper0-1       Started                                               0.7s
 ⠿ Container apicurio-oracle-db-1        Started                                               0.6s
 ⠿ Container apicurio-kafka0-1           Started                                               0.9s
 ⠿ Container apicurio-schemaregistry0-1  Started                                               1.2s
 ⠿ Container apicurio-kafka-ui-1         Started                                               1.5s
 ⠿ Container apicurio-kafka-connect0-1   Started                                               1.6s
 TODO add missing YB container output
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

Also, the container is not automatically configured with `logminer` or a vaid
user account for Debezium. The provided initialization scripts will run the
appropriate configuation for Oracle, Debezium and initialize the default
schema(s) and data to start the demonstration.

```bash
./init.sh
```

TODO

```bash
http POST :8083/connectors @connector-json.json
```

* [Oracle Connector Properties](https://debezium.io/documentation/reference/stable/connectors/oracle.html#oracle-connector-properties)
