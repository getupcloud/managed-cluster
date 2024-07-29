FROM quay.io/centos/centos:stream8

SHELL ["/bin/bash", "-x", "-c"]

ENV CLUSTER_DIR="/cluster" \
    REPO_DIR="/repo" \
    KREW_ROOT="/opt/krew" \
    INSIDE_CONTAINER="true"

ENV TERM="xterm-256color" \
    DOCTL_VERSION="1.63.1" \
    FLUX_VERSIONS="v0.15.3 v0.41.2" \
    GOOGLE_APPLICATION_CREDENTIALS="${CLUSTER_DIR}/service-account.json" \
    HCL2JSON_VERSION="v0.3.3" \
    HELM_PLUGINS="https://github.com/helm/helm-mapkubeapis" \
    KIND_VERSION="v0.11.1" \
    KREW_PLUGINS="access-matrix deprecations explore get-all kurt kvaps/node-shell lineage modify-secret outdated pexec score sniff tree" \
    KREW_REPOS="kvaps@https://github.com/kvaps/krew-index" \
    KREW_VERSION="v0.4.2" \
    KUBECONFIG="${CLUSTER_DIR}/.kube/config" \
    KUBELOGIN_VERSION="v0.0.32" \
    OC_VERSION="4.11.0-0.okd-2022-12-02-145640" \
    OSH="/etc/oh-my-bash" \
    TERRAFORM_VERSION="1.0.9" \
    TF_DATA_DIR="${CLUSTER_DIR}/.terraform" \
    TF_IN_AUTOMATION="true" \
    TF_LOG="INFO" \
    TF_LOG_PROVIDER="INFO" \
    TF_LOG_CORE="WARN" \
    TF_LOG_PATH="${CLUSTER_DIR}/terraform.log" \
    TF_PLAN_FILE="${CLUSTER_DIR}/terraform.tfplan" \
    TF_VARS_FILE="${CLUSTER_DIR}/terraform.tfvars" \
    VELERO_VERSION="1.6.2" \
    PATH="$PATH:$KREW_ROOT/bin"

COPY root/etc/yum.repos.d/ /etc/yum.repos.d/

WORKDIR $CLUSTER_DIR

RUN sed -i -e 's/mirrorlist/#mirrorlist/g' -e 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y epel-release epel-next-release && \
    dnf config-manager --add-repo https://rpm.releases.teleport.dev/teleport.repo && \
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf update -y && \
    dnf groupinstall -y 'Development Tools'

RUN \
    INSTALL_PACKAGES="https://github.com/cli/cli/releases/download/v2.4.0/gh_2.4.0_linux_amd64.rpm \
        vim-enhanced sudo docker-ce-cli teleport azure-cli google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin \
        dialog httpie bind-utils httpd-tools iproute iputils tree \
        git net-tools nmap openssl openssl-devel bc \
        gettext jq rsync strace sshpass pv procps-ng time traceroute \
        python3.11-devel python3.11-pip python39-devel python39-pip libffi-devel rust cargo" && \
    dnf install -y $INSTALL_PACKAGES && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN alternatives --set python3 /usr/bin/python3.11 && \
    pip3 install giturlparse.py pyyaml ruamel-yaml python-hcl2==3.0.5 && \
    curl -Lv https://github.com/junegunn/fzf/releases/download/0.29.0/fzf-0.29.0-linux_amd64.tar.gz \
        | sudo tar xzvf - -C /usr/local/bin && \
    curl -Lv https://github.com/Wilfred/difftastic/releases/download/0.27.0/difft-x86_64-unknown-linux-gnu.tar.gz \
        | sudo tar xzvf - -C /usr/local/bin && \
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

#RUN curl -kLO https://cache.agilebits.com/dist/1P/op/pkg/v1.12.3/op_linux_amd64_v1.12.3.zip && \
#        unzip op_linux_amd64_v1.12.3.zip -d /usr/local/bin && \
#        rm -f op_linux_amd64_v1.12.3.zip

RUN curl -skL https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh > /etc/oci-install.sh && \
    chmod +x /etc/oci-install.sh && \
    /etc/oci-install.sh --accept-all-defaults \
        --install-dir /opt/oci \
        --exec-dir /usr/local/bin/ \
        --script-dir /usr/local/bin/ \
        --rc-file-path /etc/profile.d/oci.sh && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf aws awscliv2.zip && \
    aws --version

RUN cd /usr/local/bin && \
    curl -skLO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -skL https://github.com/mikefarah/yq/releases/download/v4.13.2/yq_linux_amd64 > yq && \
    KERNEL_MACHINE=$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/' -e 's/aarch64/arm64/') && \
    curl -skL https://kind.sigs.k8s.io/dl/v0.11.1/kind-${KERNEL_MACHINE} > kind && \
    curl -skL https://github.com/tmccombs/hcl2json/releases/download/v0.3.4/hcl2json_linux_amd64 > hcl2json && \
    curl -skL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64 > \
      aws-iam-authenticator && \
    curl -skL https://github.com/derailed/k9s/releases/download/v0.24.14/k9s_Linux_x86_64.tar.gz | tar xzvf - k9s && \
    curl -skL https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubectx > kubectx && \
    curl -skL https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubens > kubens && \
    curl -sKl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases > /etc/profile.d/kubectl_aliases.sh && \
    curl -skL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
    curl -skL https://run.linkerd.io/install | INSTALLROOT=/usr/local bash && \
    curl -skL https://github.com/openshift/okd/releases/download/${OC_VERSION}/openshift-client-linux-${OC_VERSION}.tar.gz \
        | tar xzvf - oc && \
    KUBECTL_VERSIONS=$( \
        curl -s https://api.github.com/repos/kubernetes/kubernetes/releases?per_page=100 \
        | jq -r '.[] | .tag_name' \
        | grep '^v[0-9]\.[0-9][0-9]\?\.[0-9][0-9]\?$' \
        | sort -Vr \
        | awk -F . '!a[$1 FS $2]++' \
        | sort -V) && \
    for KUBECTL_VERSION in $KUBECTL_VERSIONS; do \
      curl -skL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > \
        kubectl_${KUBECTL_VERSION}; \
    done && \
    ln -s kubectl_$KUBECTL_VERSION kubectl && \
    ln -s ${KUBECONFIG%/*} /root/.kube && \
    for FLUX_VERSION in $FLUX_VERSIONS; do \
        curl -skL https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION:1}_linux_amd64.tar.gz \
            | tar xzv --transform="s,.*,flux-$FLUX_VERSION,"; \
    done && \
    ln -s flux-$FLUX_VERSION flux && \
    curl -skL https://github.com/digitalocean/doctl/releases/download/v$DOCTL_VERSION/doctl-$DOCTL_VERSION-linux-amd64.tar.gz \
        | tar xzv doctl && \
    curl -skL https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz \
        | tar xzv --strip-components=1 velero-v${VELERO_VERSION}-linux-amd64/velero && \
    curl -Lv https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux > sops && \
    \
    curl -skL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh > oh-my-bash.install && \
        chmod +x oh-my-bash.install && \
        echo "Execute 'oh-my-bash.install' to install OH-MY-BASH" && \
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    curl -kL https://gist.github.com/caruccio/3fe4cb8949419b093c5c5c9b3ac33631/raw/97915ca848e6e5689868c9fa00c3412479e2f9c3/kubectl-extract \
        -o /usr/local/bin/kubectl-extract && \
    curl -OkL https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip && \
        unzip kubelogin-linux-amd64.zip && mv bin/linux_amd64/kubelogin ./ && rm -rf bin kubelogin-linux-amd64.zip && \
    chmod +x /usr/local/bin/kubectl-extract && \
    chmod -R +x /usr/local/bin

RUN KERNEL_MACHINE=$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/' -e 's/aarch64/arm64/') && \
    curl -skL  https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-${KERNEL_MACHINE}.tar.gz \
        | tar xzv ./krew-${KERNEL_MACHINE} && \
    mv krew-${KERNEL_MACHINE} /usr/local/bin/krew && \
    krew install krew && \
    ln -s /usr/local/bin/krew /usr/local/bin/kubectl-krew && \
    for repo in ${KREW_REPOS}; do \
        kubectl krew index add ${repo%%@*} ${repo##*@}; \
    done && \
    for plugin in ${KREW_PLUGINS}; do \
        kubectl krew install $plugin; \
    done && \
    chmod -R 777 $KREW_ROOT && \
    for plugin in ${HELM_PLUGINS}; do \
        helm plugin install $plugin; \
    done

RUN cd /etc/profile.d && \
    curl -skL https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh > bash_ps1_kubernetes.sh && \
    chmod +x bash_ps1_kubernetes.sh && \
    curl -skL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > bash_ps1_git.sh && \
    chmod +x bash_ps1_git.sh && \
    kubectl completion bash > kubectl_completion.sh && \
    chmod +x kubectl_completion.sh

COPY root/ /
COPY root/etc/skel/ /root/
COPY Dockerfile /

ARG GIT_COMMIT
ARG VERSION
ARG RELEASE

RUN echo $VERSION > /.version && \
    echo $RELEASE > /.release && \
    echo $GIT_COMMIT > /.gitcommit && \
    rsync /etc/skel/ /root/ && \
    chmod -R +x /etc/profile.d/ && \
    chmod 777 /usr/share

ENTRYPOINT ["/usr/local/bin/entrypoint"]
