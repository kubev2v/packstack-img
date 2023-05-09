#!/bin/bash

set -e
#TBD make sure systemctl finished loading ssh
#workaround
sleep 10


# forward NFS to upstream host
#sed -i  "s/NFS_IP_ADDRESS/${EXTERNAL_IP}/g" /packstack.answer
sed -i  "s/NFS_IP_ADDRESS/127.0.0.1/g" /packstack.answer

cat /packstack.answer | grep CONFIG_CINDER_NFS_MOUNTS
#set the correct IP address
packstack --answer-file=/packstack.answer

#run host rediscovery in openstack yoga due to https://bugs.launchpad.net/packstack/+bug/1673305
nova-manage cell_v2 discover_hosts


#disable iptables firewall
iptables --flush
iptables-save >/etc/sysconfig/iptables


echo "LoadModule ssl_module modules/mod_ssl.so" >> /etc/httpd/conf.modules.d/00-ssl.conf
echo "LoadModule socache_shmcb_module  modules/mod_socache_shmcb.so" >> /etc/httpd/conf.modules.d/00-ssl.conf
