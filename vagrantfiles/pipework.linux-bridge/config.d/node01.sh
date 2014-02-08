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

## ct1

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
ctid=$(sudo docker ps -q -l)

## ct2

### eth0 172.17.0.xx  / dynamic ip address by docker
### eth1 192.168.1.12 / static  ip address by pipework

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
ctid=$(sudo docker ps -q -l)

sudo pipework br1 ${ctid} 192.168.1.12/24
brctl show

## ct3 : -i <ethX>

### eth0 172.17.0.xx  / dynamic ip address by docker
### eth1 192.168.1.13 / static  ip address by pipework
### eth2 192.168.2.13 / static  ip address by pipework
### eth3 192.168.3.13 / static  ip address by pipework

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
ctid=$(sudo docker ps -q -l)

sudo pipework br1 -i eth1 ${ctid} 192.168.1.13/24
sudo pipework br2 -i eth2 ${ctid} 192.168.2.13/24
sudo pipework br3 -i eth3 ${ctid} 192.168.3.13/24
brctl show

##

sudo docker ps
brctl show

# teardown
#sudo docker kill $(sudo docker ps -q)
