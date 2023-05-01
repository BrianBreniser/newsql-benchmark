FROM registry.redhat.io/ubi8/openjdk-11:latest

USER root
# need to install python2.7 for ycsb
RUN \
    microdnf install -y git-core wget tar python2 && \
    microdnf clean all && \
    ln -sf /usr/bin/python2.7 /usr/bin/python

# install ycsb with wget
RUN \
    wget https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz && \
    tar xfvz ycsb-0.17.0.tar.gz && \
    rm ycsb-0.17.0.tar.gz

# install fdb client
RUN \
    rpm -i https://github.com/apple/foundationdb/releases/download/7.1.31/foundationdb-clients-7.1.31-1.el7.x86_64.rpm


# command that just loops and does nothing, so container does not exit
CMD ["tail", "-f", "/dev/null"]



# docker build -t ycsb .

