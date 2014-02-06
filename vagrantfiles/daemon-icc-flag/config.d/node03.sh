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

cat <<'_EOS_' > Dockerfile
FROM dhrp/sshd

RUN echo root:root | chpasswd
_EOS_

sudo docker build -t sshd .

#
# ct01 -+-> ct11 -> ct21
#       |
#       +-> ct12 -> ct22
#

## ct0x

{
  sudo docker run -p 22 -d -name ct01_${suffix} sshd /usr/sbin/sshd -D
  sudo docker ps
  sudo iptables -t filter -nL
} | tee /vagrant/ct01_${suffix}.txt

## ct1x

{
  sudo docker run -d -name ct11_${suffix} -link ct01_${suffix}:sshd sshd /usr/sbin/sshd -D
  sudo docker ps
  sudo iptables -t filter -nL
} | tee /vagrant/ct11_${suffix}.txt

{
  sudo docker run -d -name ct12_${suffix} -link ct01_${suffix}:sshd sshd /usr/sbin/sshd -D
  sudo docker ps
  sudo iptables -t filter -nL
} | tee /vagrant/ct12_${suffix}.txt

## ct2x

{
  sudo docker run -d -name ct21_${suffix} -link ct11_${suffix}:sshd sshd /usr/sbin/sshd -D
  sudo docker ps
  sudo iptables -t filter -nL
} | tee /vagrant/ct21_${suffix}.txt

{
  sudo docker run -d -name ct22_${suffix} -link ct12_${suffix}:sshd sshd /usr/sbin/sshd -D
  sudo docker ps
  sudo iptables -t filter -nL
} | tee /vagrant/ct22_${suffix}.txt

# teardown

#sudo docker kill $(sudo docker ps -q)
