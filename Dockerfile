FROM hashicorp/terraform:1.0.2

ENV WORKDIR=/work \
    REPODIR=/repo \
    KIND_VERSION=v0.11.1 \
    HCL2JSON_VERSION=v0.3.3 \
    KUBECTL_VERSIONS="v1.18.18 v1.19.10 v1.20.6 v1.21.0" \
    FLUX_VERSIONS="v0.15.3 v0.16.1" \
    TERM=xterm-256color

ENV TF_DATA_DIR=${WORKDIR}/.terraform.d \
    TF_IN_AUTOMATION=true \
    TF_LOG=INFO \
    TF_LOG_PATH=${WORKDIR}/terraform.log \
    TF_VARS_FILE=${WORKDIR}/terraform.tfvars \
    TF_PLAN_FILE=${WORKDIR}/terraform.tfplan \
    KUBECONFIG=${WORKDIR}/.kube/config

ENV INSTALL_PACKAGES="bash curl procps vim jq docker \
        ncurses aws-cli coreutils httpie bind-tools \
        git iproute2 net-tools nmap openssl less tar"

RUN apk add --no-cache $INSTALL_PACKAGES && \
    apk upgrade --no-cache && \
    cd /usr/local/bin && \
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
    curl -skL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh | bash && \
    curl -skL https://github.com/cli/cli/releases/download/v1.13.1/gh_1.13.1_linux_amd64.tar.gz | \
        tar xzvf - gh_1.13.1_linux_amd64/bin/gh --strip-components 2

#RUN libuser addgroup -g 1001 getup && \
#    adduser getup -h /home/getup -g "" -s /bin/bash -G getup -D -u 1001

RUN cd /usr/local/bin && \
    for KUBECTL_VERSION in $KUBECTL_VERSIONS; do \
      curl -skL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > \
        kubectl-${KUBECTL_VERSION}; \
    done && \
    ln -s kubectl-$KUBECTL_VERSION kubectl && \
    for FLUX_VERSION in $FLUX_VERSIONS; do \
        curl -skL https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION:1}_linux_amd64.tar.gz \
            | tar xzv --transform="s,.*,flux-$FLUX_VERSION,"; \
    done && \
    ln -s flux-$FLUX_VERSION flux

COPY root/ /

ARG GIT_COMMIT
ARG VERSION

RUN chmod -R +x /usr/local/bin && \
    echo $VERSION > /.version && \
    echo $GIT_COMMIT > /.gitcommit && \
    ln -s /root/.bashrc /root/.bash_profile

WORKDIR $WORKDIR

ENTRYPOINT ["/usr/local/bin/entrypoint"]
