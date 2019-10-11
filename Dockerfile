FROM vlisivka/docker-centos7-systemd-unpriv

LABEL maintainer="huamaolin@qq.com"
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo


# install ansible
RUN yum update -y \
    && yum install ansible -y

ENV container docker    
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]


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
RUN ./setup.sh -e nginx_disable_https=true -- --skip-tags rabbitmq,postgresql_primary,postgresql_database,memcached

# add entrypoint script
ADD entrypoint.sh /entrypoint.sh

EXPOSE 80 443

# configure entrypoint
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/entrypoint.sh" ]
