#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

# setup

sudo $SHELL -c 'echo other_args=\"-icc=false\" > /etc/sysconfig/docker'
sudo /etc/init.d/docker restart
sleep 5

ps -ef | grep [/]usr/bin/docker

## ct1

sudo docker run -d -p 22 dhrp/sshd /usr/sbin/sshd -D
sudo iptables -t filter -nL | tee /vagrant/iptables.filter.1.log
sudo iptables -t nat    -nL | tee /vagrant/iptables.nat.1.log

## ct2

sudo docker run -d -p 22 dhrp/sshd /usr/sbin/sshd -D
sudo iptables -t filter -nL | tee /vagrant/iptables.filter.2.log
sudo iptables -t nat    -nL | tee /vagrant/iptables.nat.2.log

# teardown

sudo docker kill $(sudo docker ps -q)
