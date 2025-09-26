Add set -eux

# Copy over user config

rsync -rtv ./artifacts/config/ ~/.config/
rsync -rtv ./artifacts/bashrc.d/ ~/.bashrc.d/
cp ./.devcontainer.json ~/devcontainer.json

# Setup brew

mkdir ~/.homebrew
curl -L https://github.com/Homebrew/brew/tarball/main | tar xz --strip-components 1 -C ~/.homebrew

eval "$(~/.homebrew/bin/brew shellenv)"

brew update --force
brew cleanup --prune=all

# Sync mise config to install languages and dev tooling

# GPG keys needed to verify make
gpg --keyserver keys.gnupg.net --recv-keys 96B047156338B6D4 80CB727A20C79BB2

mise install -y cmake make ninja cosign

eval "$(mise activate bash)"

mise install -y
mise cache clear -y

mkdir -p ~/.local/share/bash-completion/completions
mise completion bash > ~/.local/share/bash-completion/completions/mise

# TODO: Pre-install vscode server to lower initial connect time.
# sh ./install_vs_server.sh
