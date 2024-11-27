#!/bin/sh

# add the required Oracle libraries not already included in the Kafka Connect container

#cd /kafka/connect
#curl -O https://repo1.maven.org/maven2/io/debezium/debezium-connector-jdbc/2.7.3.Final/debezium-connector-jdbc-2.7.3.Final.jar
#curl -O https://repo1.maven.org/maven2/io/debezium/debezium-core/2.7.3.Final/debezium-core-2.7.3.Final.jar

#cd /kafka/libs
#curl -O https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc11/23.5.0.24.07/ojdbc11-23.5.0.24.07.jar
#curl -O https://repo1.maven.org/maven2/com/oracle/database/xml/xdb/23.5.0.24.07/xdb-23.5.0.24.07.jar
#curl -O https://repo1.maven.org/maven2/com/thoughtworks/xstream/xstream/1.4.20/xstream-1.4.20.jar

# unsure if this is really needed or not but including it anyway as it could be useful to debug connectivity issues...

cd /kafka/external_libs
curl -O https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip
unzip instantclient-basic-linux.x64-21.15.0.0.0dbru.zip
