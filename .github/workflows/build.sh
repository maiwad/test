#!/usr/bin/env bash
# This is Latest
# xy_latest=$(curl -s "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | sed 'y/,/\n/' | grep 'tag_name' | awk -F '"' '{print substr($4,2)}')
# This is Pre-release
xy_tagname=$(curl "https://github.com/XTLS/Xray-core/releases" 2>&1 | grep "tree" | grep "data-view-component"  | head -n 1 | awk -F"\"" '{print $2}' | awk -F"/" '{print $5}' | cut -d"v" -f 2)
xy_current=$(./releases/xy version | awk 'NR==1 {print $2}')
caddy_latest=$(curl -s "https://api.github.com/repos/caddyserver/caddy/releases/latest" | grep "tag_name" | cut -d\" -f4 | sed -e "s/^v//" -e "s/-.$//" | cut -d"v" -f 2)
caddy_current=$(./releases/caddy version | cut -d" " -f 1 | cut -d"v" -f 2)
# if [[ ${xy_latest} == ${xy_current} ]]
if [[ ${xy_tagname} == ${xy_current} ]]
then
    echo 'xy is nothing to do'
else
    git clone https://github.com/XTLS/Xray-core.git
    cd Xray-core && go mod download
    CGO_ENABLED=0 go build -o xy -trimpath -ldflags "-s -w -buildid=" ./main
    mv xy ../releases/xy
    cd ../
    rm -rf Xray-core
fi
if [[ ${caddy_latest} == ${caddy_current} ]]
then
    echo 'cddy is nothing to do'
else
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
    xcaddy build latest --output ./releases/caddy
fi
git config user.name github-actions
git config user.email github-actions@github.com
git add .
git commit --allow-empty -m "$(git log -1 --pretty=%s)"
git push
          
