#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

# setup

#sudo $SHELL -c 'echo other_args=\"-icc=false\" > /etc/sysconfig/docker'
#sudo /etc/init.d/docker restart
#sleep 5

ps -ef | grep [/]usr/bin/docker

nodeid=3
# node02:192.168.10.21 <-> node03:192.168.10.31
gre_remoet_ip=192.168.10.21

## gre tunnel

sudo ovs-vsctl list-ports ovsbr1 | egrep -q -w ^gre1 || {
  sudo ovs-vsctl add-port ovsbr1 gre1 -- set interface gre1 type=gre options:remote_ip=${gre_remoet_ip} options:pmtud=false
}

## ct1

### eth0 172.17.0.xx  / dynamic ip address by docker
### eth1 192.168.1.x1 / static  ip address by pipework

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
ctid=$(sudo docker ps -q -l)

sudo pipework ovsbr1 -i eth1 ${ctid} 192.168.1.${nodeid}1/24
sudo ovs-ofctl show ovsbr1

## ct2

### eth0 172.17.0.xx  / dynamic ip address by docker
### eth1 192.168.1.x2 / static  ip address by pipework

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
ctid=$(sudo docker ps -q -l)

sudo pipework ovsbr1 -i eth1 ${ctid} 192.168.1.${nodeid}2/24
sudo ovs-ofctl show ovsbr1

## ct3

### eth0 172.17.0.xx  / dynamic ip address by docker
### eth1 192.168.1.x3 / static  ip address by pipework

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
ctid=$(sudo docker ps -q -l)

sudo pipework ovsbr1 -i eth1 ${ctid} 192.168.1.${nodeid}3/24
sudo ovs-ofctl show ovsbr1

##

sudo docker ps
sudo ovs-vsctl show

# teardown
#sudo docker kill $(sudo docker ps -q)
