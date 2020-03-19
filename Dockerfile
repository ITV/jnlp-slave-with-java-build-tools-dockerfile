FROM cloudbees/java-build-tools

USER root

#Install rbenv
RUN \
  apt update && apt-get install -y libssl-dev libreadline-dev zlib1g-dev && \
  git clone https://github.com/rbenv/ruby-build.git && \
  PREFIX=/usr/local ./ruby-build/install.sh && \
  ruby-build -v 2.3.1 /usr/local && \
  gem install bundler -v 1.17.3 --no-ri --no-rdoc

ARG JENKINS_REMOTING_VERSION=3.35

# See https://github.com/jenkinsci/docker-slave/blob/master/Dockerfile#L31
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

RUN chmod a+rwx /home/jenkins
WORKDIR /home/jenkins
USER jenkins

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
