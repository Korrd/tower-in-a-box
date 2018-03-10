# Ansible Tower Dockerfie
FROM ubuntu:16.04

MAINTAINER victomartin@gmail.com

# Set env vars and stuff
ENV ANSIBLE_TOWER_VER=3.2.3

# This var depends on ANSIBLE_TOWER_VER, so it needs to be on a different layer for it to work.
ENV ANSIBLE_SETUP_SCRIPT=/opt/tower-setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}/setup.sh

# Set locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# Add repos and install our stuff. There are things below that depend on `apt-transport-https`, hence we need
# to do two passes.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 382E94DE \
  && apt-get update \
  && apt-get install -y \
    apt-transport-https \
    wget \
    libffi-dev \
    cron \
    software-properties-common \
    gcc \
    locales \
    libssl-dev \
    python-setuptools \
    python-simplejson \
    python2.7-dev \
    build-essential \
    curl \
  && sh -c "echo 'deb https://apt.datadoghq.com/ stable 6' > /etc/apt/sources.list.d/datadog.list" \
  && apt-get update \
  && apt-get install -y datadog-agent \
  && easy_install pip \
  && pip install ansible==2.3 certifi==2015.04.28 \
  && pip install datadog

# Download [and extract] Tower
RUN wget http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
  && mkdir -p /opt/tower-setup/ansible-tower-setup-${ANSIBLE_TOWER_VER} \
  && tar -xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz -C /opt/tower-setup \
  && rm -rf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
  && mkdir /var/log/tower

# Copy required files for the tower installation procedure
COPY tower_setup_conf.yml /opt/tower-setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}/tower_setup_conf.yml
COPY files/inventory /opt/tower-setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}/inventory

# Install Tower
RUN ${ANSIBLE_SETUP_SCRIPT}

# Add required files so tower is properly configured (needs to be done AFTER installation)
COPY files/settings.py /etc/tower/settings.py
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY files/license /etc/tower/license

# Permissions and apt cache cleanup!
RUN chmod +x /docker-entrypoint.sh \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 443
ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME "/var/lib/postgresql/9.6/main"

CMD ["ansible-tower"]
