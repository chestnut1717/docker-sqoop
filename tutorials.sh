#!/bin/bash
echo "sqoop import \
-fs local \
-jt local \
-m 1 \
--driver com.mysql.jdbc.Driver \
--connect jdbc:mysql://mysql:3306/psyoblade \
--table users \
--target-dir $HOME/target/`date +'%Y%m%d-%H%M'`/users \
--verbose --username root --relaxed-isolation"
