#!/bin/sh

terraform output kubeconfig > kubeconfig
KUBECONFIG=kubeconfig kubectl $@
