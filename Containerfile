FROM registry.fedoraproject.org/fedora:45@sha256:2ef4549d369cc3ea30d1965fcc4e8f75848f3361eca3515f3f0d1a1441806d84

ARG PYTHON_VERSION="3.13.7"

RUN --mount=type=bind,source=./,target=/ctx,readonly \
  pushd /ctx && \
  python ./scripts/build_root.py && \
  popd

RUN useradd -ms /bin/bash lucy && \
  passwd --delete lucy && \
  usermod -aG wheel lucy

USER lucy

WORKDIR /workspaces

RUN --mount=type=bind,source=./,target=/ctx,readonly \
  pushd /ctx && \
  python ./scripts/build_user.py && \
  popd
