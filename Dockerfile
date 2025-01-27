FROM fedora:41

RUN dnf update -y && \
  # Install miscellaneous dev tools
  dnf install bash-completion ca-certificates clang curl git git-lfs \
  htop iputils jq llvm lsof nano rustup wget which opentofu \
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

RUN mkdir ~/.asdf && \
  # Setup Asdf
  curl -L https://github.com/asdf-vm/asdf/tarball/master | tar xz --strip 1 -C ~/.asdf && \
  # Setup homebrew
  mkdir ~/.homebrew && \
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew && \
  # Setup rust
  rustup-init --profile minimal --component clippy --component rustfmt -y && \
  # Pre-install vscode server to lower initial connect time.
  # sh /workspaces/.install_vs_server.sh && \
  # Update PATH with new installs.
  echo "PATH=$PATH:$HOME/.homebrew/bin" >> ~/.bashrc && \
  echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc && \
  echo ". $HOME/.cargo/env" >> ~/.bashrc && \
  . ~/.bashrc && \
  # Install latest versions through Asdf
  asdf plugin-add python && \
  # Switch "3.13.0" to "latest" once https://github.com/asdf-community/asdf-python/issues/191 is fixed.
  asdf install python 3.13.0 && \
  asdf global python 3.13.0 && \
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
  asdf install nodejs latest && \
  asdf global nodejs latest && \
  # Python development tooling
  pipx install --pip-args=--no-cache-dir --python "$(which python)" nox[uv] uv && \
  pipx ensurepath

