#!/bin/bash

/solutions/install_packages.sh

echo Instalando java ...
if [ ! -f /solutions/app/java/bin/java ]; then
	wget -P /solutions/app/ --no-cookies --no-check-certificate --header \
    	"Cookie: oraclelicense=accept-securebackup-cookie" \
    	"http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b15/jdk-${JAVA_VERSION}-linux-x64.tar.gz"
	tar -xvzf /solutions/app/jdk-${JAVA_VERSION}-linux-x64.tar.gz -C /solutions/app/
	chmod -R 777 $(ls -d /solutions/app/jdk*/)
	ln -sf $(ls -d /solutions/app/jdk*/) /solutions/app/java
fi

echo Instalando maven ...
if [ ! -f /solutions/app/maven/bin/mvn ]; then
	wget -P /solutions/app/ "http://apache.rediris.es/maven/maven-3/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz"
	tar -xvzf /solutions/app/apache-maven-${M2_VERSION}-bin.tar.gz -C /solutions/app/
	chmod -R 777 $(ls -d /solutions/app/apache-maven*/)
	ln -sf $(ls -d /solutions/app/apache-maven*/) /solutions/app/maven
fi

echo Instalando servidor ssh ...
if [ ! -f /usr/sbin/sshd ]; then
	yum -y install openssh-server
	mkdir /var/run/sshd
	ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
	sed -i "s/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g" /etc/ssh/sshd_config
	sed -i "s/HostKey \/etc\/ssh\/ssh_host_ed25519_key/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/g" /etc/ssh/sshd_config
fi

yum -y install xorg-x11-xauth
yum -y install xorg-x11-utils
yum -y install xorg-x11-fonts-*
yum -y install xorg-x11-server-utils
yum clean all

echo Instalando chrome ...
if [ ! -f /usr/bin/chrome ]; then
	yum -y install chromium
	ln -sf /usr/lib64/chromium-browser/chromium-browser.sh /usr/bin/chrome
fi

echo Instalando jenkins ...
if [ ! -f /solutions/jenkins/jenkins.war ]; then
	mkdir -p /solutions/app/jenkins
	mkdir -p /solutions/app/jenkins/ref/init.groovy.d
	cp /solutions/init.groovy /solutions/app/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
	curl -fsSL ${JENKINS_URL} -o /solutions/app/jenkins/jenkins.war && echo "${JENKINS_SHA}  /solutions/app/jenkins/jenkins.war" | sha1sum -c -
	chmod -R 777 /solutions/app/jenkins
fi

java $JAVA_OPTS -jar /solutions/app/jenkins/jenkins.war