#!/bin/sh

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null
then
exit
fi

trap '
rm ~/.BREW_LIST/master.zip  2>/dev/null
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rmdir ~/.BREW_LIST/LOCK  2>/dev/null
exit' 1 2 3 15

wget -q --no-check-certificate -P ~/.BREW_LIST https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip || exit
unzip -qo ~/.BREW_LIST/master.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks > ~/.BREW_LIST/Q_FONT.txt
rm ~/.BREW_LIST/master.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rmdir ~/.BREW_LIST/LOCK
