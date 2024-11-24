[Ondrej Sika (sika.io)](https://sika.io) | <ondrej@sika.io> | [go to course ->](#course)

# RKE2 and Rancher Training

## About Course

- [Rancher training in Czech Republic](https://ondrej-sika.cz/skoleni/rancher)
- [Rancher training in Europe](https://ondrej-sika.com/training/rancher)


## Course

## Agenda

- Rancher Ecosystem
  - RKE2
  - Rancher
- RKE2
  - Create Cluster
  - Update Cluster
- Rancher & Terraform
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

## Set Environment Variables for Terraform

Unix

```sh
export TF_VAR_digitalocean_token=do_token_xxx
export TF_VAR_base_domain=do0.sikademo.com
```

```sh
export TF_VAR_rancher_api_url=https://rancher.do0.sikademo.com
```

```sh
export TF_VAR_rancher_token_key=token-xxx:xxx
```

PowerShell

```powershell
$Env.TF_VAR_digitalocean_token = "do_token_xxx"
$Env.TF_VAR_base_domain = "do0.sikademo.com"
```

```powershell
$Env.TF_VAR_rancher_api_url = "https://rancher.do0.sikademo.com"
```

```powershell
$Env.TF_VAR_rancher_token_key = "token-xxx:xxx"
```

## Prepare DigitalOcean Account

Add SSH key & base domain

```
cd terraform/core
terraform init
terraform apply -auto-approve
```

## RKE2

## Manual RKE2 Provisioning

- <https://docs.rke2.io/install/quickstart/>
- <https://docs.rke2.io/install/ha/>

```
cd terraform/rke2-manual
terraform init
terraform apply -auto-approve
```

Check Kubernetes

```
/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes
```

## Automatic (Cloud Init) RKE2 Provisioning

```
cd terraform/rke2-auto
terraform init
terraform apply -auto-approve
```

Check Kubernetes

```
/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes
```

## Rancher

## Install Single Node Rancher using Docker

- <https://ranchermanager.docs.rancher.com/v2.7/pages-for-subheaders/rancher-on-a-single-node-with-docker>
- <https://ranchermanager.docs.rancher.com/v2.7/pages-for-subheaders/rancher-on-a-single-node-with-docker#option-d-lets-encrypt-certificate>
- <https://ranchermanager.docs.rancher.com/v2.7/getting-started/installation-and-upgrade/resources/bootstrap-password>

```
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  --name rancher \
  rancher/rancher:latest \
  --acme-domain <rancher_domain>
```

Example

```
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  --name rancher \
  rancher/rancher:latest \
  --acme-domain rancher.sikademo.com
```

Get bootstrap password:

```
docker logs rancher  2>&1 | grep "Bootstrap Password:"
```

## Install Rancher to Kubernetes

```
helm upgrade --install \
  rancher \
  rancher --repo https://releases.rancher.com/server-charts/stable \
  --namespace cattle-system --create-namespace \
  --set hostname=<rancher_domain> \
  --set ingress.tls.source=letsEncrypt \
  --wait
```

```
helm upgrade --install \
  rancher \
  rancher --repo https://releases.rancher.com/server-charts/stable \
  --namespace cattle-system --create-namespace \
  --set hostname=rancher.k8s.sikademo.com \
  --set ingress.tls.source=letsEncrypt \
  --wait
```

Get bootstrap password:

```
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{ .data.bootstrapPassword|base64decode}}{{ "\n" }}'
```

## Install Rancher

```
cd terraform/rancher
terraform init
terraform apply -auto-approve
```

## Bootstrap Rancher

```
cd terraform/bootstrap
terraform init
terraform apply -auto-approve
```

Get token

```
terraform output rancher_token_key
```

## Global Configuration

Apply global configuration from Terraform

```
cd terraform/global
terraform init
terraform apply -auto-approve
```

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
cd terraform/cluster-debian
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

## Projects & Namespace

Projects are logical entity inside cluster wich contains namespaces. You can assign users to specific project.

Namespaces are standart Kubernetes Namespaces.

## Alerting

### Notifiers

Notifiers are backend for alerting. Supports email, Slack, PagerDuty, ...

### Alert Groups

Alert Groups are collections of Alert Rules poited on one or many Notifiers(backends).

### Alert Rules

Alert Rule is a rule which trigger alert.

## Rancher CLI

### Login

```
rancher login <rancher_url> --name demo --token <token>
```

### List Servers

```
rancher server ls
rancher server current
```

### Switch Server

```
rancher server switch
```

### List Clusters

```
rancher clusters
```

### Get `kubeconfig`

```
rancher clusters kubeconfig <cluster_id>
rancher clusters kf <cluster_id>
```

### Current (Project) Context

```
rancher context current
```

### Switch Context

```
rancher context switch
```

### Racher `kubectl`

Use cluster from current context

```
rancher kubectl

rancher kubectl get no
rancher kubectl get po -A
```

### List Namespaces for Current Cluster

```
rancher nodes
```

### SSH to node

```
rancher ssh <node_id/node_name>
```

### List Projects for Current Cluster

```
rancher projects
```

### New Project

```
rancher projects new <name>
```

### List Namespaces for Current Project

```
rancher namespace
```

### Create Namespace

```
rancher namespace new <project_name>-<suffix>
```

## Thank you! & Questions?

That's it. Do you have any questions? __Let's go for a beer!__

## Useful links
 - Article (Czech): [Ceph Persistent volumes v Kubernetes pomocí Rook](https://ondrej-sika.cz/blog/ceph-persistent-volumes-v-kubernetes-pomoci-rook/)
 - [Terraform Docs](https://www.terraform.io/docs/)
 - [Terraform Rancher2 provider docs](https://www.terraform.io/docs/providers/rancher2/)
 - [Terraform Digital Ocean provider docs](https://www.terraform.io/docs/providers/do/)

### Ondrej Sika

- email: <ondrej@sika.io>
- web: <https://sika.io>
- twitter: [@ondrejsika](https://twitter.com/ondrejsika)
- linkedin:	[/in/ondrejsika/](https://linkedin.com/in/ondrejsika/)
- Newsletter, Slack, Facebook & Linkedin Groups: <https://join.sika.io>

_Do you like the course? Write me recommendation on Twitter (with handle `@ondrejsika`) and LinkedIn (add me [/in/ondrejsika](https://www.linkedin.com/in/ondrejsika/) and I'll send you request for recommendation). __Thanks__._

Wanna to go for a beer or do some work together? Just [book me](https://book-me.sika.io) :)
