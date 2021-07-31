#!/usr/bin/env bash
sudo apt-get update

# install platformio, this is used by marlin 
sudo apt-get install python3-pip -y
pip install -U platformio==5.1.1
# pip3 doesn't add its bin to path, do that here
echo "export PATH=$PATH:/home/vagrant/.local/bin" >> /home/vagrant/.bashrc

# docker
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo usermod -aG docker vagrant

# force startup folder to vagrant project
echo "cd /vagrant" >> /home/vagrant/.bashrc
