# Building a customer docker daemon with blackjack and deterministric networks order

## Building a patched docker daemon

Effectively building docker from master with the following 
[patch](https://github.com/docker/libnetwork/issues/2093)

```bash
chmod +x ./build.sh
./build.sh
```

The above step can be run inside a container (helps with the cleanup)

```bash
docker run --privileged -it centos bash
git clone https://github.com/networkop/arista-ceos-topo
cd ari
```

## Replacing the existing docker daemon with the patched one

```bash
yum install which -y
systemctl stop docker.service
DOCKERD=$(which dockerd)
rm $DOCKERD
cp ./bundles/latest/binary-daemon/dockerd $DOCKERD
systemctl start docker.service
```

## Testing

Need to create networks with more than 3 interfaces to
catch that:

```bash
docker network create net1
docker network create net2
docker network create net3
docker network create net4

docker create --name test1 -it alpine sh
docker create --name test2 -it alpine sh

docker network connect net1 test1
docker network connect net2 test1
docker network connect net3 test1
docker network connect net4 test1

docker network connect net1 test2
docker network connect net2 test2
docker network connect net3 test2
docker network connect net4 test2

docker start test1
docker start test2
```

To check the order of interfaces:

```bash
docker exec -it test1 ip a
docker exec -it test2 ip a
```

