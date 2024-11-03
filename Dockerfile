FROM fedora:41

COPY asdf/ ~/.asdf

RUN dnf install curl git rustup \
  # Python build dependencies
  pkg-config dnf-plugins-core gcc gcc-c++ gdb lzma glibc-devel \
  libstdc++-devel openssl-devel readline-devel zlib-devel libffi-devel \
  bzip2-devel xz-devel sqlite sqlite-devel sqlite-libs libuuid-devel \
  gdbm-libs perf expat expat-devel mpdecimal && \
  sudo dnf builddep python3 && \
  rustup-init && \
  echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc

WORKDIR workspace
