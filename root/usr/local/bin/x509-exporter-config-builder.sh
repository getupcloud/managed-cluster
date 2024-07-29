if [ $# -ne 1 ]; then
  echo "Usage: $0 [cp|node]"
  exit 1
fi

SEARCH_DIRS_CRT_CP=(
  /etc/kubernetes/pki
  /etc/kubernetes/ssl

  /etc/kubernetes/static-pod-resources/etcd-certs/secrets/etcd-all-certs
  /etc/kubernetes/static-pod-resources/etcd-certs/configmaps
  /etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-peer-client-ca
  /etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-serving-ca

  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/aggregator-client
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/check-endpoints-client-cert-key
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/control-plane-node-admin-client-cert-key
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/external-loadbalancer-serving-certkey
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/internal-loadbalancer-serving-certkey
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/kubelet-client
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/localhost-serving-cert-certkey
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/service-network-serving-certkey
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/aggregator-client-ca
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/client-ca
  # /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/trusted-ca-bundle
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/

  /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/secrets/csr-signer
  /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/secrets/kube-controller-manager-client-cert-key
  /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/configmaps/aggregator-client-ca
  /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/configmaps/client-ca
  # /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/configmaps/trusted-ca-bundle

  /etc/kubernetes/static-pod-resources/kube-scheduler-certs/secrets/kube-scheduler-client-cert-key
)

SEARCH_DIRS_CRT_NODE=(
  /var/lib/kubelet/pki
  /var/lib/kubelet/ssl
  /etc/kubernetes/pki
  /etc/kubernetes/ssl
)

SEARCH_DIRS_KUBECFG=(
  /etc/kubernetes
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/check-endpoints-kubeconfig
  /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/control-plane-node-kubeconfig
)

if [  $1 == cp ]; then
cat <<EOF
controlplane:
  nodeSelector:
    node-role.kubernetes.io/master: ""
  tolerations:
  - effect: NoSchedule
    operator: Exists
EOF
echo
echo '  watchFiles: []'
echo
echo '  watchDirectories:'
for dir in ${SEARCH_DIRS_CRT_CP[@]}; do
  find ${dir} -type f -regextype egrep -regex '.*\.(crt|pem)$' -printf "- %h\n" 2>/dev/null
done  | sort -u  | sed -e 's/^/  /'
echo
echo '  watchKubeconfFiles:'
for dir in ${SEARCH_DIRS_KUBECFG[@]}; do
  find ${dir} -maxdepth 1 -type f -regextype egrep -regex '.*(kubeconfig|kubelet.conf|controller-manager.conf|scheduler.conf|admin.conf)$' -printf "- %p\n" 2>/dev/null
done | sort -u | sed -e 's/^/  /'


elif [ $1 == node ]; then
cat <<EOF
nodes:
  tolerations:
  - effect: NoSchedule
    operator: Exists
EOF
echo
echo '  watchFiles: []'
echo
echo '  watchDirectories:'
for dir in ${SEARCH_DIRS_CRT_NODE[@]}; do
  find ${dir} -type f -regextype egrep -regex '.*\.(crt|pem)$' -printf "- %h\n" 2>/dev/null
done | sort -u | sed -e 's/^/  /'
echo
echo '  watchKubeconfFiles:'
for dir in ${SEARCH_DIRS_KUBECFG[@]}; do
  find ${dir} -maxdepth 1 -type f -regextype egrep -regex '.*(kubeconfig|kubelet.conf)$' -printf "- %p\n" 2>/dev/null
done | sort -u | sed -e 's/^/  /'

else
  echo "Usage: $0 [cp|node]"
  exit 1
fi
