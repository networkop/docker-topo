FROM centos:latest

# Include epel for python-pip and update cache
RUN yum -y install epel-release && \
    yum makecache fast

# Install all the dependencies
## RUN yum update -y \
RUN yum install -y qemu-kvm bridge-utils iproute libvirt libvirt-client \
    && yum install -y python-pip openssh genisoimage net-tools \
    && pip install pyaml \
    && yum clean all

RUN yum install -y virt-install

# Copy the CVP and CVP-tools into the container
COPY veos.qcow2 /var/lib/libvirt/images/
COPY aboot.iso /var/lib/libvirt/images/
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
