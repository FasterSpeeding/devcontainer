FROM registry.fedoraproject.org/fedora:42.20250718.0@sha256:8f9a6d75762c70b9366d70b608b93ad591140a51d755ba8a7d3d044bd9d279a4

ARG PYTHON_VERSION="3.13.7"

RUN --mount=type=bind,source=./config,target=/config,readonly \
  # Set global configuration
  bash /config/vars.bash && \
  cat /config/dnf.conf >| /etc/dnf/dnf.conf && \
  mkdir --parents /etc/mise && \
  cat /config/mise.toml >> /etc/mise/config.toml && \
  # Install miscellaneous dev tools
  dnf distro-sync -y && \
  dnf copr enable jdxcode/mise -y && \
  dnf install @c-development @development-tools \
  automake bash-completion bat btop ca-certificates clang curl git git-lfs \
  iputils jq kernel-devel llvm lsof make man man-db man-pages mise nano \
  openssl opentofu p7zip rustup ugrep vim wget which zlib \
  # Python build dependencies
  pkg-config dnf-plugins-core gcc gcc-c++ gdb lzma glibc-devel \
  libstdc++-devel openssl-devel readline-devel zlib-devel libffi-devel \
  bzip2-devel xz-devel sqlite sqlite-devel sqlite-libs libuuid-devel \
  gdbm-libs perf expat expat-devel mpdecimal -y && \
  dnf builddep python3 -y && \
  # Update man pages
  mandb && \
  # Cleanup DNF caches
  dnf autoremove && \
  dnf clean all

RUN useradd -ms /bin/bash lucy && \
  passwd --delete lucy && \
  usermod -aG wheel lucy

USER lucy

WORKDIR /workspaces

# COPY --chown=lucy install_vs_server.sh /workspaces/.install_vs_server.sh
COPY ./.devcontainer.json /home/lucy/devcontainer.json

RUN --mount=type=bind,source=./config,target=/config,readonly \
  # Install homebrew
  mkdir mkdir ~/.homebrew && \
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew && \
  ~/.homebrew/bin/brew update --force && \
  chmod -R go-w ~/.homebrew/share/zsh && \
  # Sync mise config to install languages and dev tooling
  mise install -y && \
  mise cache clear && \
  mkdir -p ~/.local/share/bash-completion/ && \
  mise completion bash --include-bash-completion-lib > ~/.local/share/bash-completion/completions/mise && \
  # Setup environment variables
  cat /config/general.bashrc >> ~/.bashrc && \
  cat /config/vars.bash >> ~/.bashrc && \
  . ~/.bashrc && \
  # Install misc tooling
  uvx install --no-cache nox[uv] && \
  cargo install eza
  # TODO: Pre-install vscode server to lower initial connect time.
  # sh /workspaces/.install_vs_server.sh && \
