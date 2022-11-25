#!/bin/bash

{
    kubectl annotate storageclass/gp2 storageclass/gp2-csi storageclass.kubernetes.io/is-default-class- || true
    kubectl annotate --overwrite storageclass/gp3-csi storageclass.kubernetes.io/is-default-class=true || true
} >&2

echo {}
