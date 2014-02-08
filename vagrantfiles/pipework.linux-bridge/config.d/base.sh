#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

##

function pull_image() {
  local image_name=${1:-base}

  sudo docker images ${image_name} | egrep -w ^${image_name} || {
    sudo docker pull ${image_name}
  }
}

##

pull_image dhrp/sshd

##

while read line; do
  set ${line}

  # /etc/sysctl.conf
  egrep ^$1 /etc/sysctl.conf -q || {
    echo "$1 = $3" | sudo tee -a /etc/sysctl.conf
  } && {
    sudo sed -i "s,^$1.*,$1 = $3," /etc/sysctl.conf
  }

  # verify
  egrep ^$1 /etc/sysctl.conf
done < <(cat <<-_EOS_
	net.bridge.bridge-nf-call-iptables = 1
	_EOS_
	)

sudo sysctl -p

##

yes | ssh-keygen -N "" -t dsa -C sample -f sample
chown vagrant:vagrant sample

cat <<'_EOS_' > Dockerfile
FROM dhrp/sshd

RUN echo root:root | chpasswd
RUN mkdir -m 700 /root/.ssh
ADD sample       /root/sample
ADD sample.pub   /root/.ssh/authorized_keys
RUN chmod 700    /root/sample
RUN chmod 644    /root/.ssh/authorized_keys
_EOS_

sudo docker build -t sshd .
