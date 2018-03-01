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

The entrypoint script will steal the DHCP IP off the container's default interface.

Allow up to 5 minutes to boot

## Logging in to CVP

```bash
docker exec -it cvp bash
virsh console cvp
```