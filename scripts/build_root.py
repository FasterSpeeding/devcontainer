import pathlib
import shutil
import subprocess

import scripts.environ as environ


DNF_DEPENDENCIES = [
    # Build dependencies
    "@c-development", "@development-tools", "automake", "ca-certificates", "gcc", "kernel-devel", "nano", "openssl"
    # Python build dependencies
    "bzip2", "bzip2-devel", "gdbm-libs", "libffi-devel", "libnsl2", "libuuid-devel", "libzstd-devel", "llvm", "readline-devel", "rsync", "sqlite-devel", "tk-devel", "xz-devel", "zlib-devel",
    # User tooling
    "bash-completion", "curl", "iputils", "lsof", "man", "man-db", "man-pages", "mise", "ps", "p7zip", "ugrep", "wget", "which", "zlib"
]


def execute(*args: str, ) -> None:
    subprocess.run(args, check=True)


def main() -> None:
    # Set global configuration
    dnf_conf_path = pathlib.Path("/etc/dnf/dnf.conf")
    dnf_conf_path.unlink(missing_ok=True)
    shutil.copyfile(str(environ.ARTIFACTS_PATH / "dnf.conf"), str(dnf_conf_path))

    # Install dnf dependencies
    execute("dnf", "distr-sync", "-y")
    execute("dnf", "copr", "enable", "jdxcode/mise", "-y")
    execute("dnf", "install", "-y", *DNF_DEPENDENCIES)

    # Cleanup
    execute("dnf", "autoremove")
    execute("dnf", "clean", "all")


if __name__ == "__main__":
    main()

# TODO:
# Update man pages
# mandb