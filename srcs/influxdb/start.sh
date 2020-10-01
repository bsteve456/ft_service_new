#! /bin/sh

#rc-service influxdb restart

#FILE=/var/lib/influxdb/meta/meta.db

#influx -execute "CREATE USER admin WITH PASSWORD 'password' WITH ALL PRIVILEGES"
#while [ $? == 1 ];
#do
#  influx -execute "CREATE USER admin WITH PASSWORD 'password' WITH ALL PRIVILEGES"
#done
#echo "admin created"
#influx -username admin -password password -execute "CREATE DATABASE IF NOT EXISTS influx_db"

#influx -username admin -password password -execute "CREATE USER IF NOT EXISTS influx_user WITH PASSWORD 'password'"

#influx -username admin -password password -execute "GRANT ALL ON influx_db TO influx_user"
#rc-service influxdb stop
#tail -f /dev/null
#if test -f "$FILE"; then
#	influxd restore -metadir /var/influxdb/lib/meta 
#	influxd restore -datadir /var/influxdb/lib/data 
#fi
influxd -config /etc/influxdb.conf 
