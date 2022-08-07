#!/bin/sh

terraform output kubeconfig > kubeconfig.yml
KUBECONFIG=kubeconfig.yml kubectl $@
