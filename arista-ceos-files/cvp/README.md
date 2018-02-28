# Running CloudVision Portal in a container

This will run a CVP as a KVM VM inside a Docker container. The assumption is that 
Docker host allows to run privileged containers and has KVM enabled

## Build a CVP docker image 

Assumes cvp.tgz, cvp-tools.tgz and answers.yaml are in the cwd

```bash
./build.sh
```
Have only been tested with 2017.2.3

## Run a CVP docker image

```bash
docker run -d --name cvp --privileged cvp
```

The mostly default docker bridge subnet `172.17.0.0/16` is hardcoded in the entrypoint script.
In order to override the IP, netmask and gateway settings, provide them as command
line arguments (will it work?):

```bash
docker run -d --name cvp --privileged cvp 192.168.0.100 255.255.255.0 192.168.0.1
```

Allow up to 5 minutes to boot

## Logging in to CVP

```bash
docker exec -it cvp bash
virsh console cvp
```