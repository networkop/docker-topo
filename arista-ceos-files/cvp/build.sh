#!/bin/bash

CVP_PATH=$1
TOOLS_PATH=$2
ANSWER_PATH=$3

check_if_file_exists () {
  if [ ! -f $1 ]; then
    echo "$1 file not found!"
    exit 1
  fi
}

copy_to_cwd () {
  if [ ! -f $2 ]; then
    cp -n $1 $2
  fi
}

copy_to_cwd $CVP_PATH cvp.tgz
copy_to_cwd $TOOLS_PATH cvp-tools.tgz
copy_to_cwd $ANSWER_PATH answers.yaml

check_if_file_exists cvp.tgz
check_if_file_exists cvp-tools.tgz
check_if_file_exists answers.yaml

chmod 660 /dev/kvm && chown root:qemu /dev/kvm

CMD="docker build -t cvp ."
echo $CMD
eval $CMD