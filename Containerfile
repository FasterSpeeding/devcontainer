FROM registry.fedoraproject.org/fedora:42@sha256:e395b2b72f6b4f62c4cf9c055a201d8d920cd73f526ec84fbc44bf964aacd904

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
