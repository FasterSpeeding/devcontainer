FROM registry.fedoraproject.org/fedora:44@sha256:89b6da80c4d37a46429fefb7c0f607abdb812d18b1ee1d409505ee113ea32a2a

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
