FROM registry.fedoraproject.org/fedora:42@sha256:6038a93811ff177322b3f87d80e2561cf0cef3a16fa72ec04ea44aa4df21d811

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
  automake bash-completion ca-certificates clang curl git git-lfs \
  iputils kernel-devel llvm lsof make man man-db man-pages mise nano \
  openssl ps p7zip ugrep wget which zlib \
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
  # Setup brew
  mkdir ~/.homebrew && \
  curl -L https://github.com/Homebrew/brew/tarball/main | tar xz --strip-components 1 -C ~/.homebrew && \
  eval "$(~/.homebrew/bin/brew shellenv)" && \
  brew update --force && \
  brew cleanup --prune=all && \
  # Sync mise config to install languages and dev tooling
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
