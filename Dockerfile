FROM fedora:41

COPY asdf/ ~/.asdf

RUN dnf update -y && \
  # Install miscellaneous dev tools
  dnf install bash-completion ca-certificates clang curl git git-lfs htop iputils-ping lsof nano rustup wget \
  # Python build dependencies
  pkg-config dnf-plugins-core gcc gcc-c++ gdb lzma glibc-devel \
  libstdc++-devel openssl-devel readline-devel zlib-devel libffi-devel \
  bzip2-devel xz-devel sqlite sqlite-devel sqlite-libs libuuid-devel \
  gdbm-libs perf expat expat-devel mpdecimal -y && \
  sudo dnf builddep python3 -y && \
  # Setup Rust
  rustup-init -y && \
  # Pre-install vscode server to lower initial connect time. 
  wget -O- https://aka.ms/install-vscode-server/setup.sh | sh && \
  # Update PATH with new installs.
  echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc && \
  echo ". $HOME/.cargo/env" >> ~/.bashrc

WORKDIR /workspace
