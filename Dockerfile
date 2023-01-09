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
RUN mysql -u root -p &&\
    CREATE DATABASE nubuilder4; &&\
    quit
RUN mysql -u root -p nubuilder4 < ./nubuilder4.sql

RUN service mysql restart

# Expose the mysql port
EXPOSE 3306

# ADD APACHE
# Run the rest of the commands as the ``root`` user
USER root

#RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd

# SET Servername to localhost
#RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf
#RUN a2enconf servername

# Manually set up the apache environment variables
#ENV APACHE_RUN_USER www-data
#ENV APACHE_RUN_GROUP www-data
#ENV APACHE_LOG_DIR /var/log/apache2
#ENV APACHE_LOCK_DIR /var/lock/apache2
#ENV APACHE_PID_FILE /var/run/apache2.pid
 
#RUN chown -R www-data:www-data /var/www
#RUN chmod u+rwx,g+rx,o+rx /var/www
#RUN find /var/www -type d -exec chmod u+rwx,g+rx,o+rx {} +
#RUN find /var/www -type f -exec chmod u+rw,g+rw,o+r {} +

RUN ufw allow 80
RUN ufw allow 8080

EXPOSE 80
EXPOSE 443

# And add changes to ``/etc/alternatives/my.cnf``
RUN sed -ri "$a[client]" "/etc/alternatives/my.cnf"
RUN sed -ri "$aport=3306" "/etc/alternatives/my.cnf"
RUN sed -ri "$asocket=/tmp/mysql.sock" "/etc/alternatives/my.cnf"
RUN sed -ri "$a[mysqld]" "/etc/alternatives/my.cnf"
RUN sed -ri "$aport=3306" "/etc/alternatives/my.cnf"
RUN sed -ri "$asocket=/tmp/mysql.sock" "/etc/alternatives/my.cnf"
RUN sed -ri "$akey_buffer_size=16M" "/etc/alternatives/my.cnf"
RUN sed -ri "$amax_allowed_packet=8M" "/etc/alternatives/my.cnf"
RUN sed -ri "$asql-mode=NO_ENGINE_SUBSTITUTION" "/etc/alternatives/my.cnf"
RUN sed -ri "$a[mysqldump]" "/etc/alternatives/my.cnf"
RUN sed -ri "$aquick" "/etc/alternatives/my.cnf"
 
# Update the default apache site with the config we created.
#ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
 
# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/var/www/html/nubuilder4", "/home"]

# Scripts
#ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
#ADD supervisord-apache2.sh /usr/local/bin/supervisord-apache2.sh
#ADD start.sh /usr/local/bin/start.sh
#RUN chmod +x /usr/local/bin/*.sh

# By default, simply start apache.
#CMD ["/usr/local/bin/start.sh"]
