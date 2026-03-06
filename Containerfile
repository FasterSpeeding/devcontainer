FROM registry.fedoraproject.org/fedora:42@sha256:22b0d2fdbfb39999ce2323b74ec5c4ed26838e1ac40aa43393436240343b9a9f

ARG PYTHON_VERSION="3.13.7"

RUN --mount=type=bind,source=./,target=/ctx,readonly \
  pushd /ctx && \
  bash ./build_root.bash && \
  popd

RUN useradd -ms /bin/bash lucy && \
  passwd --delete lucy && \
  usermod -aG wheel lucy

USER lucy

WORKDIR /workspaces

RUN --mount=type=bind,source=./,target=/ctx,readonly \
  pushd /ctx && \
  bash ./build_user.bash && \
  popd
