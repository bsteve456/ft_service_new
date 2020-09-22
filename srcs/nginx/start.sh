#! /bin/sh

touch /run/openrc/softlevel && /etc/init.d/sshd restart

nginx -g 'daemon off;'
