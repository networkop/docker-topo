#!/bin/bash

bin/docker-topo --create --debug test/v2/v2-t3.yml
docker exec -it v2-t3_host1 sudo ping -c 3 12.12.12.2
docker exec -it v2-t3_host1 sudo ping -c 3 21.21.21.2
docker exec -it v2-t3_host1 sudo ping -c 3 112.112.112.2
bin/docker-topo --destroy --debug test/v2/v2-t3.yml
