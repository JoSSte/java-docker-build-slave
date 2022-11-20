FROM ubuntu:22.04

LABEL maintainer="Jonas Stevnsvig <jonas@stevnsvig.com>"

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 11
    apt-get install -qy openjdk-11-jdk && \
# Install maven
    apt-get install -qy maven && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins to the image
    adduser --disabled-password --gecos "" jenkins

RUN mkdir /home/jenkins/.m2

# fix java

RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64/ /home/jenkins/jdk \
    chown jenkins:jenkins /home/jenkins/jdk

#ADD settings.xml /home/jenkins/.m2/
# Copy authorized_keys & known_hosts & private key for ssh deploys
COPY ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
COPY ssh/known_hosts /home/jenkins/.ssh/known_hosts

RUN ssh-keyscan -H bitbucket.org >> /home/jenkins/.ssh/known_hosts \
    ssh-keyscan -H github.com >> /home/jenkins/.ssh/known_hosts \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
