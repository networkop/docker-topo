# Running CloudVision Portal in a container

## Modify build settings

The below settings assume CVP is connected to a default docker bridge and is 
assigned a static ip of `172.17.0.100`

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
 
## Build a CVP docker image 

Assumes cvp.tgz, cvp-tools.tgz and answers.yaml are in the cwd

```bash
./build.sh
```
## Run a CVP docker image

```bash
docker run -d --name cvp --privileged cvp
```

Allow up to 5 minutes to boot


