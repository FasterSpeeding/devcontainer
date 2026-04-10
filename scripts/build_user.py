import pathlib
import shutil
import subprocess

import scripts.environ as environ


CHEZMOI_CACHE_PATH = pathlib.Path.home() / ".cache" / "chezmoi"


def main() -> None:
    # Init dotfiles repository
    subprocess.run("mise", "exec", "chezmoi", "--", "chezmoi", "init", "--apply", environ.DOTFILES_REPO)

    # Cleanup cache
    if CHEZMOI_CACHE_PATH.exists():
        shutil.rmtree(str(CHEZMOI_CACHE_PATH))


if __name__ == "__main__":
    main()
