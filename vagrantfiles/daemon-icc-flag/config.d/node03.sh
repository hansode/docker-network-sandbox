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

## ct0x

sudo docker run -d -name ct01 dhrp/sshd /usr/sbin/sshd -D
sudo docker ps
sudo iptables -t filter -nL

## ct1x

sudo docker run -d -name ct11 -link ct01:sshd dhrp/sshd /usr/sbin/sshd -D
sudo docker run -d -name ct12 -link ct11:sshd dhrp/sshd /usr/sbin/sshd -D

sudo docker ps
sudo iptables -t filter -nL

## ct2x

sudo docker run -d -name ct21 -link ct01:sshd dhrp/sshd /usr/sbin/sshd -D
sudo docker run -d -name ct22 -link ct21:sshd dhrp/sshd /usr/sbin/sshd -D

sudo docker ps
sudo iptables -t filter -nL

# teardown
sudo docker kill $(sudo docker ps -q)
