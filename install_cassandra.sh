#!/bin/bash

xdcp compute[000-023] /etc/yum.repos.d/datastax.repo /etc/yum.repos.d/datastax.repo

psh compute[000-023] yum -y install dsc21
psh compute[000-023] yum -y install cassandra21-tools

psh compute[000-023] chown -R cassandra:cassandra /var/run/cassandra
psh compute[000-023] chown -R cassandra:cassandra /var/log/cassandra
psh compute[000-023] chown -R cassandra:cassandra /var/lib/cassandra

psh compute[000-023] service cassandra stop

xdcp compute[000-023] ./cassandra.yaml /etc/cassandra/conf/cassandra.yaml

#psh compute[000-023] service cassandra start
pdsh -w compute[000-003] service cassandra start
pdsh -w compute[004-023] service cassandra start

#install opscenter ./DataStaxOpsCenter-linux-x64-installer.run
#/etc/opscenter/opscenterd.conf, change 8888 to 8004
service opscenterd start

#psh compute[000-023] yum install datastax-agent
#psh compute[000-023] service datastax-agent start
#psh compute[000-023] echo "stomp_interface: 129.207.46.224" | sudo tee -a /var/lib/datastax-agent/conf/address.yaml
#psh compute[000-023] echo "use_ssl: 1" | sudo tee -a /var/lib/datastax-agent/conf/address.yaml


#Install with tar ball.
curl -L http://downloads.datastax.com/community/dsc-2.0.tar.gz | tar xz
#Change conf/cassandra.yaml:seed,listen_address,rpc_address, bin/cassandra:JAVA_HOME
/opt/cscloud/utils/cp_file_all ./dsc-cassandra-2.1.5 /opt/cscloud/
pdsh -w compute[000-023] ln -sf /opt/cscloud/dsc-cassandra-2.1.5 /opt/cscloud/cassandra-latest
pdsh -w compute[000-003] /opt/cscloud/cassandra-latest/bin/cassandra
pdsh -w compute[017-023] /opt/cscloud/cassandra-latest/bin/cassandra -Dconsistent.rangemovement=false

pdsh -w compute[000-023] "jps | grep CassandraDaemon | cut -d ' ' -f 1 | xargs -rn1 kill"
