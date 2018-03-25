#!/bin/bash
#
# Usage: install-from-release.sh [full_package_url]
#
# Assumes: release is a .tar.bz2, was saved with "home/.travis/.cache" as the
# initial prefix (and thus requires stripping of the first 3 components with
# tar)

full_package_url=$1

if [ -z "$full_package_url" ]; then
    echo "Usage: $0 [full_package_url]"
    exit 1
fi

echo "Downloading from: $full_package_url"
curl -L ${full_package_url} | tar -C $HOME/.cache -xvj --strip-components=3 | grep -e "/bin/" -e "/lib/" -e "/dbd/" -e "/db/"
