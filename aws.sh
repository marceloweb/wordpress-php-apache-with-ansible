#!/bin/sh

selinux=`getenforce`

if [ ${selinux^^} == "ENFORCING" ] 
then 
  sed -i "s/$selinux/Permissive/g" /etc/selinux/config
  sleep 3
  setenforce Permissive
  sleep 3
fi

mkdir -p /app/INSTALL_BINARIES
mkdir -p /app/awx/projects
mkdir -p /app/docker/
mkdir -p /app/postgres_data
chmod -R 750 /app

yum install docker -y
systemctl stop docker

cp -r /var/lib/docker /app/
cd /var/lib
mv docker docker_bkp
ln -snf /app/docker docker

systemctl start docker
systemctl enable docker

yum install python -y
yum install python-docker-py.noarch -y
yum install git ansible -y
yum install libselinux-python -y

cd /app/INSTALL_BINARIES
git clone https://github.com/ansible/awx

pip install docker-compose
pip uninstall -y docker docker-py && pip install docker~=3.7.2

docker volume create portainer_data
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

cat /app/INSTALL_BINARIES/awx/installer/inventory |grep -v "#" |sort -nr |grep .
