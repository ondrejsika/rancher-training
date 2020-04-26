[Ondrej Sika (sika.io)](https://sika.io) | <ondrej@sika.io> | [go to course ->](#course)

# Rancher Training

    Ondrej Sika <ondrej@ondrejsika.com>
    https://github.com/ondrejsika/rancher-training

## About Course

- [Rancher training in Czech Republic](https://ondrej-sika.cz/skoleni/rancher)
- [Rancher training in Europe](https://ondrej-sika.com/training/rancher)


## Course

## Agenda

- Rancher Ecosystem
  - Rancher OS
  - RKE
  - Rancher
- Rancher & Terraform
- Rancher OS
- Rancher
  - Install Rancher
  - Bootstrap Rancher
  - Setup
    - Cloud Credentials
    - Node Templates
    - Users
  - Clusters
    - Rancher Managed Cluster on Managed Nodes
    - Rancher Managed Cluster on Existing Nodes
    - Imported Cluster
  - Access Control
  - Rancher CLI
- RKE
  - Create Cluster
  - Update Cluster


## Racher OS

### Create Demo Rancher OS VM

Create VM

```
cd terraform/rancheros
terraform apply -auto-approve
```

SSH into

```
ssh rancher@$(terraform output ros_ip)
```

### `ros` command

You have to be root to manage RancherOS

```
sudo su
ros
```

#### Console

```
ros console list
```

```
ros console enable debian
ros console list
```

```
ros console switch -f debian
```

SSH to RancherOS again:

```
ssh rancher@$(terraform output ros_ip)
apt
sudo su
ros console list
```

#### Engine

```
ros engine --help
```

#### Upgrade Rancher OS

```
ros os upgrade
```

## Rancher

### Rancher Drivers

Rancher has two types of drivers: __Cluster Drivers__ and __Node Drivers__

__Cluster Drivers__ creates Kubernetes using RKE or cloud provides (eg.: Amazon EKS, Azure AKS, ...)

__Node Drivers__ creates only nodes on cloud platform and use RKE for setup own Kubernetes cluster on them


### Catalogs

Catalogs are helm repositories for app deployments

### RKE Templates

RKE Templates are RKE Configs for new Kubernetes clusters. If you want to have all clusters created with specific parameters, for example without nginx ingress, you can create template to do that.

### Cloud Credentials

If you want to use clouds for managed clusters or node, you have to setup cloud credentials which will be used for connection to cloud.

### Node Templates

Before you can create cluster using cloud node drivers, you have to create node template. This node template use credentials stored in Cloud Credentials and specify node parameters like image, size, region, ...

## Clusters

### Rancher Managed Cluster on Managed Nodes

```
cd terraform/cluster-rancheros
terraform init
terraform apply -auto-approve
```

### Rancher Managed Cluster on Existing Nodes

```
cd terraform/do-nodes
terraform init
terraform apply -auto-approve
```

1. Create cluster manually
2. SSH to nodes and run:

```
SERVER=<server>
TOKEN=<token>
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.4.2 --server $SERVER --token $TOKEN --etcd --controlplane --worker
```

3. That's it.

### Imported Cluster

Create Imported Cluster

```
cd terraform/cluster-imported
terraform init
terraform apply -auto-approve
```

Create Cluster on Digital Ocean

```
cd terraform/do-kubernetes
terraform init
terraform apply -auto-approve
```

Get agent token and apply using `kubectl.sh`, which connect cluster created by Terraform

```
SERVER=<server>
TOKEN=<token>
./kubectl.sh apply -f https://$SERVER/v3/import/$TOKEN.yaml
```

## Thank you & Questions

### Ondrej Sika

- email:	<ondrej@sika.io>
- web:	[sika.io](https://sika.io)
- twitter: 	[@ondrejsika](https://twitter.com/ondrejsika)
- linkedin:	[/in/ondrejsika/](https://linkedin.com/in/ondrejsika/)

_Do you like the course? Write me recommendation on Twitter (with handle `@ondrejsika`) and LinkedIn. Thanks._
