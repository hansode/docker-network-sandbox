#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

sudo $SHELL -c 'echo other_args=\"-icc=true\" > /etc/sysconfig/docker'
sudo /etc/init.d/docker restart

ps -ef | grep [/]usr/bin/docker
