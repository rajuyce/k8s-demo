#!/bin/bash
sudo yum install docker -y
sudo service docker start
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 -v /u01/rancher:/var/lib/rancher rancher/rancher
