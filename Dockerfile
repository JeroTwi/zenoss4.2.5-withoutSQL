# Use Ubuntu 14.04 as base image
FROM ubuntu:14.04
# Maintainer of the Dockerfile
MAINTAINER netwerkbeheer <netwerkbeheer@staedion.nl>
# Set some environment variables.
ENV MYSQLHOST="zenoss-mysql"
ENV MYSQLROOTPW="zenoss"
ENV MYSQLUSERPW="zenoss"
# Run the whole set of installations.
RUN ZENOSSHOME="/home/zenoss" \
    && DOWNDIR="/tmp" \
    && ZVER="425" \
    && ZVERb="4.2.5" \
    && ZVERc="2108" \
    && DVER="03c" \
    && echo $(grep $(hostname) /etc/hosts | cut -f1) zenoss4-core >> /etc/hosts && echo "zenoss4-core" > /etc/hostname \
    && export ZENHOME=/usr/local/zenoss \
    && export PYTHONPATH=/usr/local/zenoss/lib/python \
    && export PATH=/usr/local/zenoss/bin:$PATH \
    && export INSTANCE_HOME=$ZENHOME \
    && useradd -m -U -s /bin/bash zenoss \
    && mkdir $ZENOSSHOME/zenoss$ZVER-srpm_install \
    && mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME \
    && apt-get update \
    && apt-get -y install wget software-properties-common python-software-properties libpangocairo-1.0-0 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libnss3 libcups2 libxss1 libxrandr2 libgconf2-4 libasound2 libatk1.0-0 libgtk-3-0 libxslt-dev snmp build-essential rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential \
    && echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections \
    && apt-get -y install libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java8-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox redis-server \
    && apt-get -f install \
    && /etc/init.d/memcached start && sleep 2 \
    && /etc/init.d/redis-server start && sleep 2 \
    && wget https://netcologne.dl.sourceforge.net/project/zenossforubuntu/zenoss-core-425-2108_03c_amd64.deb -P $DOWNDIR/ \
    && dpkg -i $DOWNDIR/zenoss-core-425-2108_03c_amd64.deb \
    && chown -R zenoss:zenoss $ZENHOME && chown -R zenoss:zenoss $ZENOSSHOME \
    && wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.3.0/rabbitmq-server_3.3.0-1_all.deb -P $DOWNDIR/ \
    && dpkg -i $DOWNDIR/rabbitmq-server_3.3.0-1_all.deb \
    && chown -R zenoss:zenoss $ZENHOME && echo \
    && /etc/init.d/rabbitmq-server start && sleep 2\
    && rabbitmqctl add_user zenoss zenoss \
    && rabbitmqctl add_vhost /zenoss \
    && rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*' && echo \
    && cd /usr/local/zenoss/lib/python/pynetsnmp \
    && mv netsnmp.py netsnmp.py.orig \
    && wget https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.5/misc/netsnmp.py \
    && chown zenoss:zenoss netsnmp.py \
    && echo && ln -s /usr/local/zenoss /opt \
    && apt-get install libssl1.0.0 libssl-dev -y \
    && ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so.10 \
    && ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10 \
    && ln -s /usr/local/zenoss/zenup /opt \
    && chmod +x /usr/local/zenoss/zenup/bin/zenup \
    && echo 'watchdog True' >> $ZENHOME/etc/zenwinperf.conf \
    && touch $ZENHOME/var/Data.fs && echo \
    && wget --no-check-certificate -N https://raw.githubusercontent.com/JeroTwi/zenoss/master/core-autodeploy/$ZVERb/misc/zenoss -P $DOWNDIR/ \
    && cp $DOWNDIR/zenoss /etc/init.d/zenoss \
    && chmod 755 /etc/init.d/zenoss \
    && echo && touch /etc/insserv/overrides/zenoss \
    && echo "### BEGIN INIT INFO"  > /etc/insserv/overrides/zenoss \
    && echo "# Provides: zenoss-stack"  >> /etc/insserv/overrides/zenoss \
    && echo "# Required-Start: $local_fs $network $remote_fs"  >> /etc/insserv/overrides/zenoss \
    && echo "# Required-Stop: $local_fs $network $remote_fs"  >> /etc/insserv/overrides/zenoss \
    && echo "# Should-Start: $all"  >> /etc/insserv/overrides/zenoss \
    && echo "# Should-Stop: $all"  >> /etc/insserv/overrides/zenoss \
    && echo "# Default-Start: 2 3 4 5"  >> /etc/insserv/overrides/zenoss \
    && echo "# Default-Stop: 0 1 6"  >> /etc/insserv/overrides/zenoss \
    && echo "# Short-Description: Start/stop Zenoss-stack"  >> /etc/insserv/overrides/zenoss \
    && echo "# Description: Start/stop Zenoss-stack"  >> /etc/insserv/overrides/zenoss \
    && echo "### END INIT INFO"  >> /etc/insserv/overrides/zenoss \
    && echo && chown -c root:zenoss /usr/local/zenoss/bin/pyraw \
    && chown -c root:zenoss /usr/local/zenoss/bin/zensocket \
    && chown -c root:zenoss /usr/local/zenoss/bin/nmap \
    && chmod -c 04750 /usr/local/zenoss/bin/pyraw \
    && chmod -c 04750 /usr/local/zenoss/bin/zensocket \
    && chmod -c 04750 /usr/local/zenoss/bin/nmap && echo \
    && wget --no-check-certificate -N https://raw.githubusercontent.com/stdnwbeheer/zenoss4.2.5/master/secure_zenoss_ubuntu.sh -P $ZENHOME/bin \
    && chown -c zenoss:zenoss $ZENHOME/bin/secure_zenoss_ubuntu.sh && chmod -c 0700 $ZENHOME/bin/secure_zenoss_ubuntu.sh \
    && sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf \
    && cd / && wget --no-check-certificate -N https://raw.githubusercontent.com/stdnwbeheer/zenoss4.2.5/master/docker-entrypoint.sh \
    && cd / && chown root:root docker-entrypoint.sh && chmod +x docker-entrypoint.sh \
    && zenglobalconf -u zodb-admin-password=${MYSQLROOTPW} \
    && zenglobalconf -u zep-admin-password=${MYSQLROOTPW} \
    && su -l -c "$ZENHOME/bin/secure_zenoss_ubuntu.sh" zenoss \
    && /etc/init.d/rabbitmq-server stop && sleep 2 \
    && /etc/init.d/memcached stop && sleep 2 \
    && /etc/init.d/redis-server stop && sleep 2 \
    && rm -R $DOWNDIR/* \
    && rm /var/log/rabbitmq/*.log \
    && apt-get -y purge wget \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean
# Expose port 8080 to the host to see ZenOSS web interface
EXPOSE 8080
# This container is started default with the docker-enrtypoint.sh script.
ENTRYPOINT ["/docker-entrypoint.sh"]
