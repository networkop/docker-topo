FROM centos:7

# Include epel for python-pip and update cache
RUN yum -y install epel-release && \
    yum makecache fast && \
    yum install -y qemu-kvm bridge-utils iproute libvirt libvirt-client genisoimage virt-install telnet && \
    yum clean all

# Copy the CVP and CVP-tools into the container
COPY veos.qcow2 /var/lib/libvirt/images/
COPY entrypoint.sh /
RUN mkdir -p /mnt/flash
COPY rc.eos /mnt/flash/rc.eos

RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
