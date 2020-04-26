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
- Rancher OS
- Rancher
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

## Thank you & Questions

### Ondrej Sika

- email:	<ondrej@sika.io>
- web:	[sika.io](https://sika.io)
- twitter: 	[@ondrejsika](https://twitter.com/ondrejsika)
- linkedin:	[/in/ondrejsika/](https://linkedin.com/in/ondrejsika/)

_Do you like the course? Write me recommendation on Twitter (with handle `@ondrejsika`) and LinkedIn. Thanks._
