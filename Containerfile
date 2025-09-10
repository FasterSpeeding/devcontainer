FROM registry.fedoraproject.org/fedora:42@sha256:5a17ac8b773eac120d5f46316b196f5f6bb07a5a83e34d11a2a106780056bfaf

ARG PYTHON_VERSION="3.13.7"

RUN --mount=type=bind,source=./config,target=/config,readonly \
  # Set global configuration
  bash /config/vars.bash && \
  cat /config/dnf.conf >| /etc/dnf/dnf.conf && \
  mkdir --parents /etc/mise && \
  cat /config/mise.toml >> /etc/mise/config.toml && \
  # Install generic build tools
  dnf distro-sync -y && \
  dnf copr enable jdxcode/mise -y && \
  dnf install @c-development @development-tools \
  automake ca-certificates gcc kernel-devel openssl \
  # Install Python build dependencies
  bzip2 bzip2-devel gdbm-libs libffi-devel libnsl2 libuuid-devel \
  libzstd-devel llvm readline-devel sqlite-devel tk-devel xz-devel zlib-devel \
  # Install User tools
  bash-completion curl iputils lsof man man-db \
  man-pages mise nano ps p7zip ugrep wget which zlib -y && \
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
  # Setup brew
  mkdir ~/.homebrew && \
  curl -L https://github.com/Homebrew/brew/tarball/main | tar xz --strip-components 1 -C ~/.homebrew && \
  eval "$(~/.homebrew/bin/brew shellenv)" && \
  brew update --force && \
  brew cleanup --prune=all && \
  # Sync mise config to install languages and dev tooling
  # GPG keys needed to verify make
  gpg --keyserver keys.gnupg.net --recv-keys 96B047156338B6D4 80CB727A20C79BB2 && \
  mise install -y cmake make ninja cosign && \
  eval "$(mise activate bash)" && \
  mise install -y && \
  mise cache clear -y && \
  mkdir -p ~/.local/share/bash-completion/completions && \
  mise completion bash > ~/.local/share/bash-completion/completions/mise && \
  # Setup environment variables
  cat /config/general.bashrc >> ~/.bashrc && \
  cat /config/vars.bash >> ~/.bashrc && \
  . ~/.bashrc
  # TODO: Pre-install vscode server to lower initial connect time.
  # sh /workspaces/.install_vs_server.sh && \
