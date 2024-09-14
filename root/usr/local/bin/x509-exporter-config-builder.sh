#!/bin/bash

OKD_ROOT_DIR=/etc/kubernetes/static-pod-resources
CERTS_DIRS=(
  /etc/kubernetes
  /etc/kubernetes/pki
  /etc/kubernetes/ssl
  /var/lib/kubelet/pki/kubelet-client-current.pem
  /var/lib/kubelet/pki/kubelet-server-current.pem
)
PODS_DIRS=()

if [ -d "$OKD_ROOT_DIR" ]; then
  CERTS_DIR+=(
    $OKD_ROOT_DIR/configmaps
    $OKD_ROOT_DIR/etcd-certs
    $OKD_ROOT_DIR/kube-apiserver-certs
    $OKD_ROOT_DIR/kube-controller-manager-certs
    $OKD_ROOT_DIR/kube-scheduler-certs
  )
  for name in etcd kube-apiserver kube-controller-manager kube-scheduler; do
    revision=$(printf "%s\n" $OKD_ROOT_DIR/${name}-pod-*/ | awk -F- '{print $NF}' | sort -n | tail -n 1)
    pod_dir="$OKD_ROOT_DIR/${name}-pod-$revision"
    if [ -d "$pod_dir" ]; then
      PODS_DIRS+=( "$pod_dir" )
    fi
  done
fi

CERTS_DIRS+=( ${PODS_DIRS[*]} )

for name in ${CERTS_DIRS[*]}; do
  certs=( $(find -L $name -type f -regextype egrep -regex '.*\.(crt|cert|pem)$' -exec grep -q '^-----BEGIN CERTIFICATE-----' {} \; -print 2>/dev/null) )

  if [ ${#certs[*]} -eq 0 ]; then
    continue
  fi

  for cert in ${certs[*]}; do
    hash=$(md5sum "$cert" | cut -f 1 -d ' ')
    CERTS["$hash"]="$cert"
  done
done

CONFIG_DIRS=(
  /etc/kubernetes
  /var/lib/kubelet
)

for name in ${CONFIG_DIRS[*]}; do
  confs=( $(find -L $name -maxdepth 1 -type f -exec grep -qE '^(kind: Config|contexts:|clusters:)$' {} \; -print 2>/dev/null) )

  if [ ${#confs[*]} -eq 0 ]; then
    continue
  fi

  for conf in ${confs[*]}; do
    hash=$(md5sum "$conf" | cut -f 1 -d ' ')
    CONFS["$hash"]="$conf"
  done
done

if  [ ${#PODS_DIRS[*]} -gt 0 ]; then
  for name in ${PODS_DIRS[*]}; do
    confs=( $(find -L $name -type f -exec grep -qE '^(kind: Config|contexts:|clusters:)$' {} \; -print 2>/dev/null) )

    if [ ${#confs[*]} -eq 0 ]; then
      continue
    fi

    for conf in ${confs[*]}; do
      hash=$(md5sum "$conf" | cut -f 1 -d ' ')
      CONFS["$hash"]="$conf"
    done
  done
fi

echo 'watchFiles:'
if [ ${#CERTS[*]} -gt 0 ]; then
  printf -- "- %s\n" ${CERTS[@]} | sort -u
else
  echo "[]"
fi

echo
echo 'watchKubeconfFiles:'
if [ ${#CONFS[*]} -gt 0 ]; then
  printf -- "- %s\n" ${CONFS[@]} | sort -u
else
  echo "[]"
fi
