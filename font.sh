#!/bin/bash

if LS=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`);then
 TI=(`date +"%Y %-m %-d"`)
 if [ ${TI[0]} -gt ${LS[8]} -o ${TI[1]} -gt ${LS[5]} -o ${TI[2]} -gt ${LS[6]} ];then
  rmdir ~/.BREW_LIST/LOCK
 fi
fi

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
 echo LOCK ###
 exit
fi

trap '
rm ~/.BREW_LIST/master.zip 2>/dev/null
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rmdir ~/.BREW_LIST/LOCK 2>/dev/null
exit' 1 2 3 15 20

curl -sLo ~/.BREW_LIST/master.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
{ rmdir ~/.BREW_LIST/LOCK; exit; }
/usr/bin/unzip -q ~/.BREW_LIST/master.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks|sed 's/\(.*\)\.rb$/\1/' > ~/.BREW_LIST/Q_FONT.txt
rm ~/.BREW_LIST/master.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master
rmdir ~/.BREW_LIST/LOCK

