FROM cloudbees/java-build-tools

USER root

ARG JENKINS_REMOTING_VERSION=3.35

RUN \
  apt update && apt-get install -y libssl-dev libreadline-dev zlib1g-dev dnsutils

# See https://github.com/jenkinsci/docker-slave/blob/master/Dockerfile#L31
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

RUN chmod a+rwx /home/jenkins
WORKDIR /home/jenkins
USER jenkins

#Install rbenv
RUN \
  git clone https://github.com/rbenv/ruby-build.git && \
  PREFIX=/home/jenkins/rbenv ./ruby-build/install.sh && \
  /home/jenkins/rbenv/bin/ruby-build -v 2.3.1 /home/jenkins/rbenv && \
  /home/jenkins/rbenv/bin/gem install bundler -v 1.17.3 --no-ri --no-rdoc

#Install aplo
ENV PATH=/home/jenkins/rbenv/shims:/home/jenkins/rbenv/bin:/usr/local/bin:/usr/local/sbin:$PATH
RUN \
  RUN git clone https://x-token-auth:GITHUB_API_KEY@github.com/ITV/aplo.git -b APLO_VERSION

USER root
RUN \
  ln -fsn /home/jenkins/aplo/exe/aplo /usr/local/bin/aplo

USER jenkins


ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
