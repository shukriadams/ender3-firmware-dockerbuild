#!/usr/bin/env bash
sudo apt-get update

# install arduino-cli 
wget https://github.com/arduino/arduino-cli/releases/download/0.18.3/arduino-cli_0.18.3_Linux_64bit.tar.gz -O arduino-cli.tar.gz 
tar -xvf arduino-cli.tar.gz
sudo mv arduino-cli /usr/bin
sudo chmod +x /usr/bin/arduino-cli
rm arduino-cli.tar.gz

# install platformio, this is used by marlin 
sudo apt-get install python3-pip -y
pip install -U platformio==5.1.1
# pip3 doesn't add its bin to path, do so here
echo "export PATH=$PATH:/home/vagrant/.local/bin" >> /home/vagrant/.bashrc

# docker
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo usermod -aG docker vagrant

# force startup folder to vagrant project
echo "cd /vagrant" >> /home/vagrant/.bashrc
