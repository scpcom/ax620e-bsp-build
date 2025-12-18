#!/bin/bash -e

installpkgs(){
  echo "Updating repositories..."
  apt-get update

  echo "Installing required packages..."
  apt-get install -y cpio xxd
  apt-get install -y build-essential cmake git pkg-config rsync unzip wget zip
  apt-get install -y bc bison flex liblzma-dev libncurses-dev libssl-dev device-tree-compiler
  apt-get install -y ninja-build tcl
  apt-get install -y dosfstools file mtools
  apt-get install -y fuse2fs shellcheck
}

isadmin=`whoami`
if [ "X$1" = "Xinstallpkgs" ]; then
  installpkgs
  exit $?
elif [ "X$isadmin" = "Xroot" ]; then
  installpkgs
else
  sudo $0 installpkgs
fi

echo "Checking git config..."
gitusermail=`git config user.email || true`
gitusername=`git config user.name || true`
if [ "X${gitusermail}" = "X" ]; then
  echo "warning: please run git config to set user.email"
  git config --global user.email "builder@localhost.localdomain"
fi
if [ "X${gitusername}" = "X" ]; then
  echo "warning: please run git config to set user.name"
  git config --global user.name "builder"
fi

echo OK
