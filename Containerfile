FROM registry.fedoraproject.org/fedora:42@sha256:ed1a695cfc9e400277c1c90ba7e5827ef2aa2ce01dde862519603dd799815de6

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
