# Running CloudVision Portal in a container

This will run a CVP as a KVM VM inside a Docker container. The assumption is that 
Docker host allows to run privileged containers and has KVM enabled

## Modify build settings

Only IP settings and hostname are worth changing. DNS, NTP and interface names 
can be left default

```yaml
version: 2
common:
   default_route: 172.17.0.1
   dns: [ 8.8.8.8 ]
   ntp: [ 0.fedora.pool.ntp.org, 1.fedora.pool.ntp.org ]
   device_interface: eth0       # one on which managed devices can reach CVP
                                # This is optional. Defaults to eth0.

node1:
   hostname: cvp.lab
   interfaces:
      eth0:
         ip_address: 172.17.0.100    # We do not support IPv6 yet
         netmask: 255.255.0.0
```

The above settings assume CVP is connected to a default docker bridge and is
assigned a static ip of `172.17.0.100`

 
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

Allow up to 5 minutes to boot


