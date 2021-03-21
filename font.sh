#!/bin/bash

TI=(`date +"%Y %-m %-d"`) &&\
LS=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`) &&\
[ ${TI[0]} -gt ${LS[8]} -o ${TI[1]} -gt ${LS[5]} -o ${TI[2]} -gt ${LS[6]} ] &&\
rm -rf ~/.BREW_LIST/LOCK

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
 exit
fi

trap '
rm -f ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master ~/.BREW_LIST/homebrew-cask-drivers-master
rm -f ~/.BREW_LIST/Q_FONT.txt ~/.BREW_LIST/Q_DRIV.txt
rm -rf ~/.BREW_LIST/LOCK
exit' 1 2 3 15 20

curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
{ rm -rf ~/.BREW_LIST/LOCK; exit; }
curl -sLo ~/.BREW_LIST/master1.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
{ rm -rf ~/.BREW_LIST/LOCK; exit; }

if [ `uname` = Darwin ];then
curl -so ~/.BREW_LIST/Q_CASK.html https://formulae.brew.sh/cask/index.html ||\
{ rm -rf ~/.BREW_LIST/LOCK; exit; }
curl -sLo ~/.BREW_LIST/master2.zip https://github.com/Homebrew/homebrew-cask-drivers/archive/master.zip ||\
{ rm -rf ~/.BREW_LIST/LOCK; exit; }
fi

/usr/bin/unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks|sed 's/\(.*\)\.rb$/\1/' >~/.BREW_LIST/Q_FONT.txt

if [ `uname` = Darwin ];then
/usr/bin/unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST
ls ~/.BREW_LIST/homebrew-cask-drivers-master/Casks|sed 's/\(.*\)\.rb$/\1/' >~/.BREW_LIST/Q_DRIV.txt
fi

rm -f ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master ~/.BREW_LIST/homebrew-cask-drivers-master
rm -rf ~/.BREW_LIST/LOCK

if [ ! -s ~/.BREW_LIST/Q_FONT.txt ];then
 rm -f ~/.BREW_LIST/Q_FONT.txt ~/.BREW_LIST/Q_DRIV.txt
fi
