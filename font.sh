#!/bin/bash

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
exit
fi

trap '
rm -f ~/.BREW_LIST/master.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rm -rf ~/.BREW_LIST/LOCK
exit' 1 2 3 15 20

curl -sLo ~/.BREW_LIST/master.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
{ rmdir ~/.BREW_LIST/LOCK; exit; }
/usr/bin/unzip -q ~/.BREW_LIST/master.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks|sed 's/\(.*\)\.rb$/\1/' > ~/.BREW_LIST/Q_FONT.txt
rm -f ~/.BREW_LIST/master.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rm -rf ~/.BREW_LIST/LOCK
