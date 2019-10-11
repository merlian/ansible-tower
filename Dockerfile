FROM centos:centos8

LABEL maintainer="huamaolin@qq.com"

WORKDIR /tmp/tower-installer

# install ansible
RUN yum update -y \
    && yum -y install python3-pip \
    && pip3 install --upgrade pip \
    && pip install ansible

# define tower version and PG_DATA
ENV TOWER_VERSION 3.5.3-1
ENV PG_DATA /var/lib/postgresql/9.6/main

# download tower installer
RUN curl -sSL http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-${TOWER_VERSION}.tar.gz -o ansible-tower-setup-${TOWER_VERSION}.tar.gz \
    && tar xvf ansible-tower-setup-${TOWER_VERSION}.tar.gz \
    && rm -f ansible-tower-setup-${TOWER_VERSION}.tar.gz

# change working dir
WORKDIR /tmp/tower-installer/ansible-tower-setup-${TOWER_VERSION}

# create var folder
RUN mkdir /var/log/tower

# copy inventory
ADD inventory inventory

# install tower
RUN ./setup.sh

# add entrypoint script
ADD entrypoint.sh /entrypoint.sh

EXPOSE 80 443

# configure entrypoint
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/entrypoint.sh" ]
