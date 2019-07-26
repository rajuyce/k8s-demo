#Pull base imdage
From tomcat:8-jre8

#Maintainer
MAINTAINER "ynraju4@gmail.com"

RUN rm -rf /usr/local/tomcat/webapps/*

#copy war file on to container
COPY ./webapp/target/webapp.war /usr/local/tomcat/webapps/ROOT.war
