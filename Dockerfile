FROM fedora:41

RUN dnf update -y && \
  # Install miscellaneous dev tools
  dnf install bash-completion ca-certificates clang curl git git-lfs \
  htop iputils jq llvm lsof nano rustup wget \
  # Python build dependencies
  pkg-config dnf-plugins-core gcc gcc-c++ gdb lzma glibc-devel \
  libstdc++-devel openssl-devel readline-devel zlib-devel libffi-devel \
  bzip2-devel xz-devel sqlite sqlite-devel sqlite-libs libuuid-devel \
  gdbm-libs perf expat expat-devel mpdecimal -y && \
  dnf builddep python3 -y && \
  dnf clean all

RUN useradd -ms /bin/bash lucy && \
  passwd --delete lucy && \
  usermod -aG wheel lucy

USER lucy

RUN mkdir ~/.asdf && \
  # Setup Asdf
  curl -L https://github.com/asdf-vm/asdf/tarball/master | tar xz --strip 1 -C ~/.asdf && \
  # Setup homebrew
  mkdir ~/.homebrew && \
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew && \
  # Setup rust
  rustup-init --profile minimal --component clippy --component rustfmt -y && \
  # Pre-install vscode server to lower initial connect time.
  # TODO: wait until Microsoft properly supports this again, all the
  # available solutions rn are hacks that Microsoft could randomly kill
  # Update PATH with new installs.
  echo "PATH=$PATH:$HOME/.homebrew/bin" >> ~/.bashrc && \
  echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc && \
  echo ". $HOME/.cargo/env" >> ~/.bashrc && \
  . ~/.bashrc && \
  # Install latest versions through Asdf
  asdf plugin-add python && \
  asdf install python latest && \
  asdf global python latest && \
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
  asdf install nodejs latest && \
  asdf global nodejs latest

WORKDIR /workspace
