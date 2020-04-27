#!/bin/sh

IP=$(terraform output -json node_ips | jq '.[0]')
sed -i ".backup" -e "s/1.1.1.1/$IP/g" cluster.yml

IP=$(terraform output -json node_ips | jq '.[1]')
sed -i ".backup" -e "s/2.2.2.2/$IP/g" cluster.yml

IP=$(terraform output -json node_ips | jq '.[2]')
sed -i ".backup" -e "s/3.3.3.3/$IP/g" cluster.yml
