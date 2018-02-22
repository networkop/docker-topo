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

# Copy the CVP and CVP-tools into the container
ADD cvp.tgz /tmp
ADD cvp-tools.tgz /tmp
COPY answers.yaml /tmp
COPY entrypoint.sh /

# Generate ISO
RUN /tmp/geniso.py  -y /tmp/answers.yaml -p cvpadmin -o /tmp/

# Generate libvirt XML
RUN /tmp/generateXmlForKvm.py -n cvp \
    --device-bridge virbr0 -i /tmp/cvxTemplate.xml -o result.xml \
    -x /tmp/disk1.qcow2 -y /tmp/disk2.qcow2 -c /tmp/node1-cvp.iso \
    -b 10240 -p 2 \
    -e /usr/libexec/qemu-kvm 

RUN chmod +x /entrypoint.sh 

ENTRYPOINT /entrypoint.sh
