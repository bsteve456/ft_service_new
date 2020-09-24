#! /bin/sh

#rc-service telegraf restart
touch /var/run/utmp
mkdir /etc/telegraf
mv /etc/telegraf.conf /etc/telegraf/
telegraf
#tail -f /dev/null

