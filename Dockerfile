FROM hashicorp/terraform:1.0.2

ENV CLUSTERDIR="/cluster" \
    REPODIR="/repo" \
    TERM="xterm-256color" \
    PATH=$PATH:/root/.krew/bin

SHELL ["/bin/sh", "-x", "-c"]

RUN apk update && \
    INSTALL_PACKAGES="bash curl procps vim vimdiff docker \
        ncurses aws-cli coreutils httpie bind-tools apache2-utils \
        git iproute2 net-tools nmap openssl less tar \
        gettext yq jq rsync strace ca-certificates gnupg \
        build-base py3-pip python3-dev libffi-dev rust cargo py3-wheel openssl-dev" && \
    apk add --no-cache $INSTALL_PACKAGES && \
    apk upgrade --no-cache && \
    pip install giturlparse.py && \
    ln -s /usr/bin/python3 /usr/bin/python

SHELL ["/bin/bash", "-x", "-c"]

ENV \
    DOCTL_VERSION="1.63.1" \
    FLUX_VERSIONS="v0.15.3" \
    HCL2JSON_VERSION="v0.3.3" \
    KIND_VERSION="v0.11.1" \
    KREW_PLUGINS="tree kvaps/node-shell deprecations sniff" \
    KREW_REPOS="kvaps@https://github.com/kvaps/krew-index" \
    KREW_VERSION="v0.4.1" \
    KUBECONFIG="${CLUSTERDIR}/.kube/config" \
    KUBECTL_VERSIONS="v1.18.18 v1.19.10 v1.20.6 v1.21.0" \
    OSH="/etc/oh-my-bash" \
    TF_DATA_DIR="${CLUSTERDIR}/.terraform.d" \
    TF_IN_AUTOMATION="true" \
    TF_LOG="INFO" \
    TF_LOG_PATH="${CLUSTERDIR}/terraform.log" \
    TF_PLAN_FILE="${CLUSTERDIR}/terraform.tfplan" \
    TF_VARS_FILE="${CLUSTERDIR}/terraform.tfvars" \
    VELERO_VERSION="1.6.2"

# it takes too long so we do it asap
RUN curl -skL https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh > /etc/oci-install.sh && \
    chmod +x /etc/oci-install.sh && \
    /etc/oci-install.sh --accept-all-defaults \
        --install-dir /opt/oci \
        --exec-dir /usr/local/bin/ \
        --script-dir /usr/local/bin/ \
        --rc-file-path /etc/profile.d/oci.sh

RUN cd /usr/local/bin && \
    curl -skL https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64 > kind && \
    curl -skL https://github.com/tmccombs/hcl2json/releases/download/v0.3.3/hcl2json_linux_amd64 > hcl2json && \
    curl -skL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.3/aws-iam-authenticator_0.5.3_linux_amd64 > \
      aws-iam-authenticator && \
    curl -skL https://github.com/derailed/k9s/releases/download/v0.24.14/k9s_Linux_x86_64.tar.gz | tar xzvf - k9s && \
    curl -skL https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubectx > kubectx && \
    curl -skL https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubens > kubens && \
    curl -sKl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases > /etc/profile.d/kubectl_aliases.sh && \
    curl -skL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
    curl -skL https://run.linkerd.io/install | INSTALLROOT=/usr/local bash && \
    curl -skL https://github.com/cli/cli/releases/download/v1.13.1/gh_1.13.1_linux_amd64.tar.gz | \
        tar xzvf - gh_1.13.1_linux_amd64/bin/gh --strip-components 2 && \
    for KUBECTL_VERSION in $KUBECTL_VERSIONS; do \
      curl -skL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > \
        kubectl_${KUBECTL_VERSION}; \
    done && \
    ln -s kubectl_$KUBECTL_VERSION kubectl && \
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
    chmod -R +x /usr/local/bin/

RUN KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" && \
    curl -skL https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew.tar.gz \
        | tar xzv $KREW && \
    $KREW install krew && \
    ln -s ~/.krew/bin/kubectl-krew /usr/local/bin/krew && \
    for repo in ${KREW_REPOS}; do \
        kubectl krew index add ${repo%%@*} ${repo##*@}; \
    done && \
    for plugin in ${KREW_PLUGINS}; do \
        kubectl krew install $plugin; \
    done

RUN curl -skL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh > oh-my-bash.install && \
        chmod +x oh-my-bash.install && \
        echo "Execute 'oh-my-bash.install' to install OH-MY-BASH" && \
    curl -skL https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh > /etc/profile.d/bash_ps1_kubernetes.sh && \
    chmod +x /etc/profile.d/bash_ps1_kubernetes.sh && \
    curl -skL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > /etc/profile.d/bash_ps1_git.sh && \
    chmod +x /etc/profile.d/bash_ps1_git.sh

COPY root/ /
COPY root/etc/skel/ /root/
COPY Dockerfile /

ARG GIT_COMMIT
ARG VERSION

RUN chmod -R +x /usr/local/bin && \
    echo $VERSION > /.version && \
    echo $GIT_COMMIT > /.gitcommit && \
    rsync /etc/skel/ /root/ && \
    chmod -R +x /etc/profile.d/

WORKDIR $CLUSTERDIR

ENTRYPOINT ["/usr/local/bin/entrypoint"]
