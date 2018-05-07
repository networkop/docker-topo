#!/bin/bash

set -x
set -e

bin/docker-topo --create --debug test/v1/t1.yml
docker exec -it t1_host-1 sudo ping -c 3 12.12.12.2
bin/docker-topo --destroy --debug test/v1/t1.yml


bin/docker-topo --create --debug test/v2/veth.yml
docker exec -it veth_host1 sudo ping -c 3 12.12.12.2
docker exec -it veth_host1 sudo ping -c 3 13.13.13.3
docker exec -it veth_host3 sudo ping -c 3 23.23.23.2
bin/docker-topo --destroy --debug test/v2/veth.yml

echo "Local test completed successfully"
