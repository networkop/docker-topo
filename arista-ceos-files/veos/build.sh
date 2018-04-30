#!/bin/bash

QCOW_PATH=$1
ABOOT_PATH=$2

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

copy_to_cwd $QCOW_PATH veos.qcow2
copy_to_cwd $ABOOT_PATH aboot.iso

check_if_file_exists veos.qcow2
check_if_file_exists aboot.iso

CMD="docker build -t veos ."
echo $CMD
eval $CMD
