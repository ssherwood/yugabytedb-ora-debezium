#!/bin/sh

# set up archive logging and enable debezium access
mkdir -p /opt/oracle/oradata/recovery_area

export ORACLE_SID=ORCLCDB
sqlplus /nolog <<- EOF
	connect sys/Tiger123 as sysdba
	alter system set db_recovery_file_dest_size = 100G;
	alter system set db_recovery_file_dest = '/opt/oracle/oradata/recovery_area' scope=spfile;
	exit;
EOF

# use the scripted shutdown so the container doesn't stop
/home/oracle/shutDown.sh immediate

sqlplus / as sysdba <<- EOF
   startup mount;
   alter database archivelog;
   alter database open;
   alter pluggable database all open;
   alter system register;
   archive log list
   exit;
EOF

# enable logminer database features/settings
sqlplus sys/Tiger123@//localhost:1521/ORCLCDB as sysdba <<- EOF
  alter database add supplemental log data;
  alter profile default limit failed_login_attempts unlimited;
  exit;
EOF

# create logminer tablespace for cdb
sqlplus sys/Tiger123@//localhost:1521/ORCLCDB as sysdba <<- EOF
  CREATE TABLESPACE LOGMINER_TBS DATAFILE '/opt/oracle/oradata/ORCLCDB/logminer_tbs.dbf' SIZE 250M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
  exit;
EOF

# create logminer tablespace for pdb1
sqlplus sys/Tiger123@//localhost:1521/ORCLPDB1 as sysdba <<- EOF
  CREATE TABLESPACE LOGMINER_TBS DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/logminer_tbs.dbf' SIZE 250M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
  exit;
EOF

# create the debezium role for required access to logminer
sqlplus sys/Tiger123@//localhost:1521/ORCLCDB as sysdba <<- EOF
  CREATE USER c##dbzuser IDENTIFIED BY dbz DEFAULT TABLESPACE LOGMINER_TBS QUOTA UNLIMITED ON LOGMINER_TBS CONTAINER=ALL;

  GRANT CREATE SESSION TO c##dbzuser CONTAINER=ALL;
  GRANT SET CONTAINER TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ON V_\$DATABASE TO c##dbzuser CONTAINER=ALL;
  GRANT FLASHBACK ANY TABLE TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ANY TABLE TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;
  GRANT EXECUTE_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ANY TRANSACTION TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ANY DICTIONARY TO c##dbzuser CONTAINER=ALL;
  GRANT LOGMINING TO c##dbzuser CONTAINER=ALL;

  GRANT CREATE TABLE TO c##dbzuser CONTAINER=ALL;
  GRANT LOCK ANY TABLE TO c##dbzuser CONTAINER=ALL;
  GRANT CREATE SEQUENCE TO c##dbzuser CONTAINER=ALL;

  GRANT EXECUTE ON DBMS_LOGMNR TO c##dbzuser CONTAINER=ALL;
  GRANT EXECUTE ON DBMS_LOGMNR_D TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ON V_\$LOGMNR_LOGS TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ON V_\$LOGMNR_CONTENTS TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ON V_\$LOGFILE TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ON V_\$ARCHIVED_LOG TO c##dbzuser CONTAINER=ALL;
  GRANT SELECT ON V_\$ARCHIVE_DEST_STATUS TO c##dbzuser CONTAINER=ALL;

  exit;
EOF

# create the debezium user and permissions

sqlplus sys/Tiger123@//localhost:1521/ORCLPDB1 as sysdba <<- EOF
  CREATE USER debezium IDENTIFIED BY dbz;
  GRANT CONNECT TO debezium;
  GRANT CREATE SESSION TO debezium;
  GRANT CREATE TABLE TO debezium;
  GRANT CREATE SEQUENCE to debezium;
  ALTER USER debezium QUOTA 100M on users;
  exit;
EOF