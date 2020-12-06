#!/bin/sh
wget -q --no-check-certificate -P ~/.BREW_LIST https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip || exit
unzip -q ~/.BREW_LIST/master.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks > ~/.BREW_LIST/Q_FONT.txt
rm ~/.BREW_LIST/master.zip ~/.BREW_LIST/master.zip.* 2>/dev/null
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master

if [ ! -s ~/.BREW_LIST/Q_FONT.txt ]
then
rm ~/.BREW_LIST/Q_FONT.txt
fi
