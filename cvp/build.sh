#!/bin/bash

check_if_file_exists () {
  if [ ! -f $1 ]; then
    echo "$1 file not found!"
    exit 1
  fi
}

check_if_file_exists cvp.tgz

check_if_file_exists cvp-tools.tgz

check_if_file_exists answers.yaml

chmod 660 /dev/kvm && chown root:qemu /dev/kvm

docker build -t cvp .
