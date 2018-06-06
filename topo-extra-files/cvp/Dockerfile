FROM centos:latest

# Include epel for python-pip and update cache
RUN yum -y install epel-release && \
    yum makecache fast

# Install all the dependencies
## RUN yum update -y \
RUN yum install -y qemu-kvm bridge-utils iproute libvirt libvirt-client \
    && yum install -y python-pip openssh genisoimage net-tools ethtool \
    && pip install pyaml \
    && yum clean all

# Copy the CVP and CVP-tools into the container
ADD cvp.tgz /tmp
ADD cvp-tools.tgz /tmp
COPY answers.yaml /tmp
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["192.168.200.254", "255.255.255.0"]
