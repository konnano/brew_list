#!/bin/bash

TI=(`date +"%Y %-m %-d"`) &&\
LS=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`) &&\
[ ${TI[0]} -gt ${LS[8]} -o ${TI[1]} -gt ${LS[5]} -o ${TI[2]} -gt ${LS[6]} ] &&\
rm -rf ~/.BREW_LIST/LOCK

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
 exit
fi

trap '
rm -f ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ~/.BREW_LIST/_brew.txt
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master ~/.BREW_LIST/homebrew-cask-drivers-master
rm -f ~/.BREW_LIST/Q_FONT.txt ~/.BREW_LIST/Q_DRIV.txt
rm -rf ~/.BREW_LIST/LOCK
exit' 1 2 3 15 20

 test='0'
if [ `uname` = Darwin ];then

curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
curl -so ~/.BREW_LIST/Q_CASK.html https://formulae.brew.sh/cask/index.html ||\
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
curl -sLo ~/.BREW_LIST/master1.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
curl -sLo ~/.BREW_LIST/master2.zip https://github.com/Homebrew/homebrew-cask-drivers/archive/master.zip ||\
 { rm -rf ~/.BREW_LIST/LOCK; exit; }

/usr/bin/unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST
 ls ~/.BREW_LIST/homebrew-cask-fonts-master/Casks|\
  sed 's/\(.*\)\.rb$/\1/' > ~/.BREW_LIST/Q_FONT.txt

/usr/bin/unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST
 ls ~/.BREW_LIST/homebrew-cask-drivers-master/Casks|\
  sed 's/\(.*\)\.rb$/\1/' > ~/.BREW_LIST/Q_DRIV.txt

 while read line;do
  if [[ $line =~ \<td\>\<a[^\>]*\>(.+)\</a\>\</td\>$ ]];then
   LS1=${BASH_REMATCH[1]}\\t
    continue
  fi
  if [[ $line =~ \<td\>(.+)\</td\>$ ]] && [ $test = 0 ];then
   LS2=${BASH_REMATCH[1]}\\n
    test='1'
     continue
  fi
  if [[ $line =~ \<td\>(.+)\</td\>$ ]] && [ $test = 1 ];then
   LS3=${BASH_REMATCH[1]}\\t
    test='0'
  fi
   LIST+=($LS1$LS3$LS2)
  LS1=''; LS2=''; LS3=''
 done < ~/.BREW_LIST/Q_CASK.html

 echo -ne ${LIST[@]}|sed 's/^ //' > ~/.BREW_LIST/cask.txt

else
 curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula-linux/index.html ||\
  { rm -rf ~/.BREW_LIST/LOCK; exit; }
fi

 while read line;do
  if [[ $line =~ \<td\>\<a[^\>]*\>(.+)\</a\>\</td\>$ ]];then
   echo -ne ${BASH_REMATCH[1]}\\t >> ~/.BREW_LIST/_brew.txt
    continue
  fi
  if [[ $line =~ \<td\>(.+)\</td\>$ ]] && [ $test = 0 ];then
   echo -ne ${BASH_REMATCH[1]}\\t >> ~/.BREW_LIST/_brew.txt
    test='1'
     continue
  fi
  if [[ $line =~ \<td\>(.+)\</td\>$ ]] && [ $test = 1 ];then
   echo ${BASH_REMATCH[1]} >> ~/.BREW_LIST/_brew.txt
    test='0'
  fi
 done < ~/.BREW_LIST/Q_BREW.html

 sort ~/.BREW_LIST/_brew.txt > ~/.BREW_LIST/brew.txt 

/usr/bin/env perl ~/.BREW_LIST/tie.pl

rm -f ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ~/.BREW_LIST/_brew.txt
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master ~/.BREW_LIST/homebrew-cask-drivers-master
rm -rf ~/.BREW_LIST/LOCK
