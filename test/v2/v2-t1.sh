#!/bin/bash

bin/docker-topo --create --debug test/v2/v2-t1.yml
docker exec -it v2-t1_host1 sudo ping -c 3 12.12.12.2
docker exec -it v2-t1_host1 sudo ping -c 3 13.13.13.3
docker exec -it v2-t1_host3 sudo ping -c 3 23.23.23.2
bin/docker-topo --destroy --debug test/v2/v2-t1.yml
