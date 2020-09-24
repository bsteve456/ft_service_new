#! /bin/sh

mkdir /run/openrc && touch /run/openrc/softlevel
/etc/init.d/sshd start
rc-status
/etc/init.d/sshd restart

nginx -g 'daemon off;'
