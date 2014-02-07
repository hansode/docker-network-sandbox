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

sudo mkdir -p /etc/sysctl.d
cat <<_EOS_ | sudo tee /etc/sysctl.d/30-bridge-if.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
_EOS_

sudo sysctl -p
