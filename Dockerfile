FROM ubuntu:20.04

# 09.01.2023 regain - Search Tool

# Parameter 
# Change this values to your preferences
#ENV ...

# add unprivileged tomcat user
RUN useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Packages
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get -qq update && apt-get -y upgrade
RUN sudo apt install default-jdk

# INSTALL tomcat
RUN cd /tmp
RUN wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.20/bin/apache-tomcat-10.0.20.tar.gz
RUN tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1
RUN chown -R tomcat:tomcat /opt/tomcat/
RUN chmod -R u+x /opt/tomcat/bin

# CONFIG tomcat
ADD tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
ADD context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
ADD context.xml /usr/local/tomcat/webapps/host-manager/META-INF/context.xml



RUN ufw allow 8888

EXPOSE 8888

# And add changes to ``/etc/alternatives/my.cnf``
#RUN sed -ri "$a[client]" "/etc/alternatives/my.cnf"
 
# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/usr/local/tomcat/webapps"]

# Scripts
#ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
#ADD supervisord-apache2.sh /usr/local/bin/supervisord-apache2.sh
#ADD start.sh /usr/local/bin/start.sh
#RUN chmod +x /usr/local/bin/*.sh

# By default, simply start tomcat.
CMD ["catalina.sh", "run"]
