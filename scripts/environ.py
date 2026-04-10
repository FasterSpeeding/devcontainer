import os
import pathlib


CTX_PATH = pathlib.Path(os.environ["MOUNTED_CONTEXT"])
ARTIFACTS_PATH = CTX_PATH / "artifacts"
DOTFILES_REPO = os.environ.get("DOTFILES_REPO", "git@github.com:FasterSpeeding/dotfiles.git")
