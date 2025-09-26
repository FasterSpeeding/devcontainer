Add set -eux

set -eux

# Set global configuration
cat ./artifacts/dnf.conf >| /etc/dnf/dnf.conf

# Install generic build tools

dnf distro-sync
dnf copr enable jdxcode/mise

dnf install @c-development @development-tools \
    automake ca-certificates gcc kernel-devel nano openssl \
    # Install Python build dependencies
    bzip2 bzip2-devel gdbm-libs libffi-devel libnsl2 libuuid-devel libzstd-devel \
    llvm readline-devel rsync sqlite-devel tk-devel xz-devel zlib-devel \
    # Install User tools
    bash-completion curl iputils lsof man man-db \
    man-pages mise ps p7zip ugrep wget which zlib -y

# Update man pages
# mandb

# Cleanup DNF caches
dnf autoremove
dnf clean all
