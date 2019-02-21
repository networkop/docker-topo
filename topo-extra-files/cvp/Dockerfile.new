FROM centos:latest

ARG IMAGE=cvp-2018.2.2-kvm.tgz
ARG TOOLS=cvp-tools-2018.2.2.tgz

RUN yum -y install epel-release && \
    yum makecache fast && \
    yum install -y qemu-kvm iproute libvirt libvirt-client && \
    yum install -y python-pip openssh genisoimage net-tools && \
    pip install pyyaml && \
    yum clean all

RUN mkdir -p /cvp
ADD $IMAGE /cvp
ADD $TOOLS /cvp
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

