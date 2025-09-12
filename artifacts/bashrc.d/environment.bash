# Misc aliases
alias cat='bat --style=plain --pager=never'
alias egrep='ug -E'
alias fgrep='ug -F'
alias grep='ug'

# Add some eza aliases
alias l.='eza -d .*'
alias l1='eza -1'
alias ll='eza -l --icons=auto --group-directories-first'
alias ls='eza'

# Extend PATH
eval "$($HOME/.homebrew/bin/brew shellenv)"
eval "$(mise activate bash)"

# Define user-wide environment variables.
export HOMEBREW_NO_ANALYTICS=1
