#!/bin/bash

echo "Copy JDBC drivers (if mounted) to classpath"
cp /jdbc/*.jar $SQOOP_HOME/lib

echo "Start Hadoop services"
/etc/docker-startup/hive-bootstrap.sh

echo "Leave user with a shell"
/bin/bash
