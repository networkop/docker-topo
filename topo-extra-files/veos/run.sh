#!/bin/bash
docker rm -f veos
docker network create net1
docker network create net2
docker network create net3
docker create --name veos --privileged veos
docker network connect net1 veos
docker network connect net2 veos
docker network connect net3 veos
docker start veos
