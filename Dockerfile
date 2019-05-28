FROM openjdk:8u212-jdk

LABEL maintainer="Even Holthe <even.holthe@me.com>"

ENV JENKINS_SWARM_VERSION 3.16
ENV OCTO_CLI_VERSION=6.2.3
ENV HOME /home/jenkins-slave

# Install pre-requisites (sudo, make, docker)
RUN apt-get update && apt-get install -y --no-install-recommends \
    net-tools \
    sudo \
    make \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    libunwind8 \
    rpm \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install docker-ce -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Install Jenkins Swarm
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
  && chmod 755 /usr/share/jenkins

# Install octo cli
RUN mkdir /octo \
  && curl -sSLo /tmp/octo-cli.tar.gz https://download.octopusdeploy.com/octopus-tools/$OCTO_CLI_VERSION/OctopusTools.$OCTO_CLI_VERSION.debian.8-x64.tar.gz \
  && tar -zxvf /tmp/octo-cli.tar.gz -C /octo \
  && ln -s /octo/Octo /usr/bin/octo \
  && rm /tmp/octo-cli.tar.gz

# Add user with sudo
RUN adduser --disabled-password --gecos '' jenkins-slave \
  && adduser jenkins-slave sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

USER jenkins-slave
VOLUME /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
