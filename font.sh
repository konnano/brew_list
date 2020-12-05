#!/bin/sh
mkdir -p ~/.BREW_FORT
wget -q --no-check-certificate -P ~/.BREW_FORT https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip || exit
unzip -q ~/.BREW_FORT/master.zip -d ~/.BREW_FORT
rm ~/.BREW_FORT/master.zip
ls ~/.BREW_FORT/homebrew-cask-fonts-master/Casks > ~/.Q_FONT.txt
rm -rf ~/.BREW_FORT/homebrew-cask-fonts-master
rm ~/.BREW_FORT/master.zip.[1-9] 2>/dev/null
rm ~/.BREW_FORT/master.zip.[1-9].[1-9] 2>/dev/null

if [ ! -s ~/.Q_FONT.txt ]
then
rm ~/.Q_FONT.txt
fi
