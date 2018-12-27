# Running vEOS in a container

This will run a vEOS as a KVM VM inside a Docker container. The assumption is that 
Docker host allows to run privileged containers and has KVM enabled

## Build a vEOS docker image 

(Optional) Convert VMDK to qcow on docker host

```bash
qemu-img convert -f vmdk -O qcow2 veos.vmdk veos.qcow2
```

Copy veos.vmdk into a local directory (otherwise provide paths to these files
to build.sh and it will copy them for you)

```bash
./build.sh ~/Downloads/veos.qcow2 
```

> Note: This installer assumes the latest version of vEOS that doesn't require aboot.iso

## Run a vEOS docker image

```bash
docker run -d --name veos --privileged veos
```

Allow up to 5 minutes to boot

## Logging in to vEOS

```bash
docker exec -it veos bash
virsh console veos
```

## Inject startup config

Startup injection works by mounting an ISO CDROM to the vEOS VM and using an init script to extract the startup configuration from it. This works by building a custom vEOS image interactively using the following steps:

* Once normal vEOS docker image is built, login the vEOS VM console for the first time:

```bash
$ docker run -d --name veos --privileged veos
$ docker exec -it veos bash
[root@03ac4c733bc7 /]# virsh console veos
```

* From inside the vEOS drop into the bash shell, mount the CDROM and copy the init script into the persistent storage directory:

```bash
localhost login: admin
localhost>en
localhost#bash
[admin@localhost ~]$ mkdir /tmp/cdrom 
[admin@localhost ~]$ sudo mount -t iso9660 /dev/cdrom /tmp/cdrom/
[admin@localhost ~]$ cp /tmp/cdrom/rc.eos /mnt/flash/
```

* Disconnect from the container and commit changes into a new image:

```bash
[root@03ac4c733bc7 /]# virsh destroy veos
[root@03ac4c733bc7 /]# exit
$ docker commit veos veos:latest
$ docker rm -f veos
```

From now on, you can mount startup configuration file  into `/mnt/flash/startup-config` when creating a vEOS container and that file will be automatically mounted and copied into the `/mnt/flash/startup-config` inside the vEOS VM:

```bash
echo "hostname MYRANDOM-HOSTNAME" > my-config
docker run -d --name veos -v $(pwd)/my-config:/mnt/flash/startup-config --privileged veos
docker exec -it veos bash
[root@de16326e92f2 /]# virsh console veos
MYRANDOM-HOSTNAME login:      
```

