FROM registry.fedoraproject.org/fedora:44@sha256:00b77a26ae17ecf3e0d931989a676a11c5a8b55e37a5daee86727b757b6b7771

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
