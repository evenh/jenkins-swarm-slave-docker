FROM openjdk:8-jdk

LABEL maintainer="Even Holthe <even.holthe@me.com>"

ENV JENKINS_SWARM_VERSION 3.15
ENV HOME /home/jenkins-slave

# install netstat to allow connection health check with
# netstat -tan | grep ESTABLISHED
RUN apt-get update && apt-get install -y --no-install-recommends \
		net-tools \
		sudo \
		make \
	&& rm -rf /var/lib/apt/lists/*

# Add user with sudo
RUN adduser --disabled-password --gecos '' jenkins-slave
RUN adduser jenkins-slave sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
  && chmod 755 /usr/share/jenkins

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

USER jenkins-slave
VOLUME /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
