#!/bin/bash

echo Executing eks-post-create hook

if timeout 10 kubectl get storageclass gp2 &>/dev/null; then
  timeout 10 kubectl annotate --overwrite storageclass gp2 storageclass.kubernetes.io/is-default-class-
fi
