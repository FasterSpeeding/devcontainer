FROM registry.fedoraproject.org/fedora:42.20250718.0@sha256:8f9a6d75762c70b9366d70b608b93ad591140a51d755ba8a7d3d044bd9d279a4

ARG PYTHON_VERSION="3.13.7"

RUN "/config/dnf.conf" >| /etc/dnf/dnf.conf && \
  dnf update -y && \
  # Install miscellaneous dev tools
  dnf install bash-completion ca-certificates clang curl git git-lfs \
  htop iputils jq llvm lsof nano opentofu rustup wget which \
  # Python build dependencies
  pkg-config dnf-plugins-core gcc gcc-c++ gdb lzma glibc-devel \
  libstdc++-devel openssl-devel readline-devel zlib-devel libffi-devel \
  bzip2-devel xz-devel sqlite sqlite-devel sqlite-libs libuuid-devel \
  gdbm-libs perf expat expat-devel mpdecimal -y && \
  dnf builddep python3 -y && \
  # Python development tools
  dnf install pipx -y && \
  # Cleanup DNF caches
  dnf clean all

RUN useradd -ms /bin/bash lucy && \
  passwd --delete lucy && \
  usermod -aG wheel lucy

USER lucy

WORKDIR /workspaces

# COPY --chown=lucy install_vs_server.sh /workspaces/.install_vs_server.sh
COPY ./.devcontainer.json /home/lucy/devcontainer.json

RUN --mount=type=bind,source=./config,target=/config,readonly \
  mkdir mkdir ~/.homebrew && \
  # Setup homebrew
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew && \
  cat "/config/brew.bashrc" >> ~/.bashrc && \
  . ~/.bashrc && \
  # Setup ASDF
  brew install asdf && \
  cat "/config/asdf.bashrc" >> ~/.bashrc && \
  . ~/.bashrc && \
  # Setup rust
  rustup-init --profile minimal --component clippy --component rustfmt -y && \
  # Install languages through Asdf
  asdf plugin-add python && \
  # Switch "$PYTHON_VERSION" to "latest" once https://github.com/asdf-community/asdf-python/issues/191 is fixed.
  asdf install python $PYTHON_VERSION && \
  asdf global python $PYTHON_VERSION && \
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
  asdf install nodejs latest && \
  asdf global nodejs latest && \
  # Python development tooling
  pipx install --pip-args=--no-cache-dir --python "$(which python)" nox[uv] uv && \
  pipx ensurepath && \
  cat "/config/general.bashrc" >> ~/.bashrc
  # TODO: Pre-install vscode server to lower initial connect time.
  # sh /workspaces/.install_vs_server.sh && \
