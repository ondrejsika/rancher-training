#!/bin/sh

terraform output -raw kubeconfig > kubeconfig.yml
KUBECONFIG=kubeconfig.yml kubectl $@
