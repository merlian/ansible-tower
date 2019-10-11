FROM centos:centos7

LABEL maintainer="huamaolin@qq.com"
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo


# install ansible
RUN yum update -y \
    && yum install ansible -y

WORKDIR /tmp/tower-installer
# define tower version and PG_DATA
ENV TOWER_VERSION 3.5.3-1.el7
ENV PG_DATA /var/lib/postgresql/9.6/main

# download tower installer
RUN curl -sSL http://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-${TOWER_VERSION}.tar.gz -o ansible-tower-setup-bundle-${TOWER_VERSION}.tar.gz \
    && tar xvf ansible-tower-setup-bundle-${TOWER_VERSION}.tar.gz \
    && rm -f ansible-tower-setup-bundle-${TOWER_VERSION}.tar.gz

# change working dir
WORKDIR /tmp/tower-installer/ansible-tower-setup-bundle-${TOWER_VERSION}

# create var folder
RUN mkdir /var/log/tower

# copy inventory
ADD inventory inventory

# install tower
RUN ./setup.sh -e nginx_disable_https=true -- --skip-tags rabbitmq,postgresql_primary,postgresql_database

# add entrypoint script
ADD entrypoint.sh /entrypoint.sh

EXPOSE 80 443

# configure entrypoint
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/entrypoint.sh" ]
