repo=microsoft/vscode

tag=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name')
read type tag_sha < <(echo $(curl -s "https://api.github.com/repos/$repo/git/ref/tags/$tag" | 
     jq -r '.object.type,.object.sha'))

if [ $type == "commit" ]; then
    sha=$tag_sha
else
    sha=$(curl -s "https://api.github.com/repos/$repo/git/tags/$tag_sha" | jq '.object.sha')
fi

download_path="~/.vscode-server/cli/servers/Stable-$sha/server"
mkdir $download_path --parents
curl -L https://update.code.visualstudio.com/commit:$sha/server-linux-x64-web/stable | tar xz --strip 1 -C $download_path
mv $download_path/bin/code-server ~/.vscode-server/code-$sha
echo '["$sha"]' >> lru.json
