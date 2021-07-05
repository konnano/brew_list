#!/bin/bash

if [ `uname` = Darwin ];then 
  TI1=(`date +"%Y %-m %-d"`)
 LS1=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`) &&\
 [ ${TI1[0]} -gt ${LS1[8]} -o ${TI1[1]} -gt ${LS1[5]} -o ${TI1[2]} -gt ${LS1[6]} ] &&\
 rm -rf ~/.BREW_LIST/LOCK
else
  TI2=(`date +"%Y %m %d"`)
 LS2=(`ls -d --full-time ~/.BREW_LIST/LOCK 2>/dev/null`)
 LS2=(`echo ${LS2[5]}|sed 's/-/ /g'`)
 [[ ${TI2[0]} > ${LS2[0]} || ${TI2[1]} > ${LS2[1]} || ${TI2[2]} > ${LS2[2]} ]] &&\
 rm -rf ~/.BREW_LIST/LOCK
fi

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
 exit
fi

trap '
rm -f ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ~/.BREW_LIST/_brew.txt
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master ~/.BREW_LIST/homebrew-cask-drivers-master
rm -f ~/.BREW_LIST/Q_FONT.txt ~/.BREW_LIST/Q_DRIV.txt ~/.BREW_LIST/DB
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
   LIST1+=($LS1$LS3$LS2)
  LS1=''; LS2=''; LS3=''
 done < ~/.BREW_LIST/Q_CASK.html

 echo -ne ${LIST1[@]}|sed 's/^ //' > ~/.BREW_LIST/cask.txt

else
 curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula-linux/index.html ||\
  { rm -rf ~/.BREW_LIST/LOCK; exit; }
fi
 test='0'
 while read line;do
  if [[ $line =~ \<td\>\<a[^\>]*\>(.+)\</a\>\</td\>$ ]];then
   LS1=${BASH_REMATCH[1]}\\t
    continue
  fi
  if [[ $line =~ \<td\>(.+)\</td\>$ ]] && [ $test = 0 ];then
   LS2=${BASH_REMATCH[1]}\\t
    test='1'
     continue
  fi
  if [[ $line =~ \<td\>(.+)\</td\>$ ]] && [ $test = 1 ];then
   LS3=${BASH_REMATCH[1]}\\n
    test='0'
  fi
   LIST2+=($LS1$LS2$LS3)
  LS1=''; LS2=''; LS3=''
 done < ~/.BREW_LIST/Q_BREW.html

 echo -ne ${LIST2[@]}|sed 's/^ //' > ~/.BREW_LIST/_brew.txt

 sort ~/.BREW_LIST/_brew.txt > ~/.BREW_LIST/brew.txt 

 rm -f ~/.BREW_LIST/DBM.*
 perl ~/.BREW_LIST/tie.pl

if [ `uname` = Darwin ];then
 cp ~/.BREW_LIST/DBM.db ~/.BREW_LIST/DB
else
 cp ~/.BREW_LIST/DBM.pag ~/.BREW_LIST/DB
fi

rm -f ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ~/.BREW_LIST/_brew.txt
rm -rf ~/.BREW_LIST/homebrew-cask-fonts-master ~/.BREW_LIST/homebrew-cask-drivers-master
rm -rf ~/.BREW_LIST/LOCK
