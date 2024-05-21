ARG ALPINE_BASE=3.19.1

FROM docker.io/library/alpine:${ALPINE_BASE}
USER root

ARG USER=appuser
ARG GROUPNAME=appuser
ARG UID=1012
ARG GID=1012

RUN apk update && \
    apk add --update git bash sudo && \
    apk add --update curl jq gnupg && \
    apk add -q python3 py3-pip py3-requests py3-yaml && \
    apk add -q openssl && \
    apg add -q busybox-extras && \
    addgroup --system --gid "${GID}" "${GROUPNAME}" && \
    adduser --disabled-password --gecos "" --ingroup "${GROUPNAME}" --uid "${UID}" "${USER}" && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir install_tmp && chmod a+rwx install_tmp && cd install_tmp && \
    curl -fL https://getcli.jfrog.io/v2 | sh && \
    mv jfrog /usr/local/bin/ && ln -s /usr/local/bin/jfrog /usr/local/bin/jf && \
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin && \
    apk add --update docker openrc && \
    mkdir /run/openrc && touch /run/openrc/softlevel && \
    rc-update add docker boot && \
    curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 && \
    mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops && chmod +x /usr/local/bin/sops && export GPG_TTY=$(tty) && \
    curl -LO https://get.helm.sh/helm-v3.14.0-rc.1-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.14.0-rc.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && \
    curl -LO https://github.com/camptocamp/helm-sops/releases/download/20220419-3/helm-sops_20220419-3_linux_amd64.tar.gz && \
    tar -xvf helm-sops_20220419-3_linux_amd64.tar.gz && mv helm-sops /usr/local/bin/ && chmod +x /usr/local/bin/helm-sops

USER ${USER}
WORKDIR /home/${USER}
