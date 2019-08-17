FROM jenkins/jnlp-slave:3.27-1 
USER root

RUN apt-get update -y
RUN apt-get install wget maven openjdk-8-jre docker gettext -y 
RUN wget https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
RUN which kubectl
