#!/bin/bash

#Stop container procedure
cleanup() {
    echo "Container stopped, performing cleanup..."
    /etc/init.d/zenoss stop && sleep 2
    /etc/init.d/mysql stop && sleep 2
    /etc/init.d/rabbitmq-server stop && sleep 2
    /etc/init.d/redis-server stop && sleep 2
    /etc/init.d/memcached stop
}

#Trap SIGTERM
trap 'cleanup' SIGTERM

#Start container procedure
/etc/init.d/memcached start && sleep 2
/etc/init.d/redis-server start && sleep 2
/etc/init.d/rabbitmq-server start && sleep 2
if [ ! -f /firstrun ]; then
    rabbitmqctl add_user zenoss zenoss
    rabbitmqctl add_vhost /zenoss
    rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
    touch /firstrun
fi
/etc/init.d/mysql start && sleep 2
/etc/init.d/zenoss start && sleep 5
tail -f /dev/null &

#Wait
wait $!
