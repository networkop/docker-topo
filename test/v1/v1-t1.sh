#!/bin/bash

bin/docker-topo --create --debug test/v1/v1-t1.yml
docker exec -it v1-t1_host-1 sudo ping -c 3 12.12.12.2
bin/docker-topo --destroy --debug test/v1/v1-t1.yml 
