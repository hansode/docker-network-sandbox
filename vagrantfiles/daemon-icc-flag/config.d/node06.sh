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

suffix=${RANDOM}

##

yes | ssh-keygen -N "" -t dsa -C insecure_key -f insecure_key
chown vagrant:vagrant insecure_key

cat <<'_EOS_' > Dockerfile
FROM dhrp/sshd

RUN echo root:root | chpasswd
RUN mkdir -m 700 /root/.ssh
ADD insecure_key     /root/insecure_key
ADD insecure_key.pub /root/.ssh/authorized_keys
RUN chmod 700        /root/insecure_key
RUN chmod 644        /root/.ssh/authorized_keys
_EOS_

sudo docker build -t sshd .

## ct1

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
sudo iptables -t filter -nL | tee /vagrant/iptables.filter.1.log
sudo iptables -t nat    -nL | tee /vagrant/iptables.nat.1.log

## ct2

sudo docker run -d -p 22 sshd /usr/sbin/sshd -D
sudo iptables -t filter -nL | tee /vagrant/iptables.filter.2.log
sudo iptables -t nat    -nL | tee /vagrant/iptables.nat.2.log

# teardown

sudo docker kill $(sudo docker ps -q)
