# Running vEOS in a container

This will run a vEOS as a KVM VM inside a Docker container. The assumption is that 
Docker host allows to run privileged containers and has KVM enabled

## Build a vEOS docker image 

(Optional) Convert VMDK to qcow on docker host

```bash
qemu-img convert -f vmdk -O qcow2 veos.vmdk veos.qcow2
```

Copy veos.vmdk and aboot.iso into a local directory (otherwise provide paths to these files
to build.sh and it will copy them for you)

```bash
./build.sh ~/Downloads/veos.qcow2 ~/Downloads/aboot.iso
```

## Run a vEOS docker image

```bash
docker run -d --name veos --privileged veos
```

Allow up to 5 minutes to boot

## Control number of interfaces

It's possible to connect arbitrary number of interfaces by providing a argument to entrypoint script, like this:

```bash
docker run -d --name veos --privileged veos 5
```

The above command will create a veos image with 5 interfaces. In order for this to work docker container needs to be attached to 5 networks (by default there's only 1)

## Logging in to vEOS

```bash
docker exec -it veos bash
virsh console veos
```
