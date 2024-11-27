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

This version of the connector is specifically configured to use Apicurio's Json
Converters.

For additional configuration options, review the [Oracle Connector Properties](https://debezium.io/documentation/reference/stable/connectors/oracle.html#oracle-connector-properties).

## Deploy the YugabyteDB Sink


TODO
configure c3p0
Initializing c3p0 pool... com.mchange.v2.c3p0.PoolBackedDataSource@b40b33bf [ connectionPoolDataSource -> com.mchange.v2.c3p0.WrapperConnectionPoolDataSource@e440e407 [ acquireIncrement -> 32, acquireRetryAttempts -> 30, acquireRetryDelay -> 1000, autoCommitOnClose -> false, automaticTestTable -> null, breakAfterAcquireFailure -> false, checkoutTimeout -> 0, connectionCustomizerClassName -> null, connectionTesterClassName -> com.mchange.v2.c3p0.impl.DefaultConnectionTester, contextClassLoaderSource -> caller, debugUnreturnedConnectionStackTraces -> false, factoryClassLocation -> null, forceIgnoreUnresolvedTransactions -> false, forceSynchronousCheckins -> false, identityToken -> 1bqrg1yb6170lqlibdyz1a|797d98ea, idleConnectionTestPeriod -> 0, initialPoolSize -> 5, maxAdministrativeTaskTime -> 0, maxConnectionAge -> 0, maxIdleTime -> 0, maxIdleTimeExcessConnections -> 0, maxPoolSize -> 32, maxStatements -> 0, maxStatementsPerConnection -> 0, minPoolSize -> 5, nestedDataSource -> com.mchange.v2.c3p0.DriverManagerDataSource@955765c4 [ description -> null, driverClass -> null, factoryClassLocation -> null, forceUseNamedDriverClass -> false, identityToken -> 1bqrg1yb6170lqlibdyz1a|504b69ab, jdbcUrl -> jdbc:postgresql://yugabytedb:5433/yugabyte, properties -> {password=******, user=******} ], preferredTestQuery -> null, privilegeSpawnedThreads -> false, propertyCycle -> 0, statementCacheNumDeferredCloseThreads -> 0, testConnectionOnCheckin -> false, testConnectionOnCheckout -> false, unreturnedConnectionTimeout -> 0, usesTraditionalReflectiveProxies -> false; userOverrides: {} ], dataSourceName -> null, extensions -> {}, factoryClassLocation -> null, identityToken -> 1bqrg1yb6170lqlibdyz1a|4efdbd67, numHelperThreads -> 3 ]   [com.mchange.v2.c3p0.impl.AbstractPoolBackedDataSource]

curl -O https://repo1.maven.org/maven2/com/fasterxml/jackson/module/jackson-module-jaxb-annotations/2.13.4/jackson-module-jaxb-annotations-2.13.4.jar
curl -O https://repo1.maven.org/maven2/com/fasterxml/jackson/module/jackson-module-scala_3/2.13.4/jackson-module-scala_3-2.13.4.jar
