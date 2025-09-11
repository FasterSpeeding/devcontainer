# Load static config added during Dev container build.
while read -r -d $'\0' path; do
    source "$path"
done < <(find "$HOME/.config/bash" -type f -name "*.bash" -print0)
