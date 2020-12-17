#!/bin/bash

TI=(`date +"%Y %-m %-d"`) &&\
LS=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`) &&\
[ ${TI[0]} -gt ${LS[8]} -o ${TI[1]} -gt ${LS[5]} -o ${TI[2]} -gt ${LS[6]} ] &&\
rm -rf ~/.BREW_LIST/LOCK

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
 exit
fi

trap '
rm -f ~/.BREW_LIST/master.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rm -rf ~/.BREW_LIST/LOCK
exit' 1 2 3 15 20

curl -sLo ~/.BREW_LIST/master.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
{ rm -rf ~/.BREW_LIST/LOCK; exit; }
/usr/bin/unzip -q ~/.BREW_LIST/master.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks|sed 's/\(.*\)\.rb$/\1/' >~/.BREW_LIST/Q_FONT.txt
rm -f ~/.BREW_LIST/master.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rm -rf ~/.BREW_LIST/LOCK

if [ ! -s ~/.BREW_LIST/Q_FONT.txt ];then
 rm -f ~/.BREW_LIST/Q_FONT.txt
fi
