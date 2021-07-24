#!/bin/bash

NAME=`uname`
if [[ ! $NAME = Darwin && ! $NAME = Linux ]];then
 exit
elif [[ $NAME = Darwin ]];then
 CPU=`sysctl machdep.cpu.brand_string`
fi

if [[ $NAME = Darwin && $1 && $1 = unlink ]];then
  if [[ $CPU =~ Intel ]];then
   rm -f /usr/local/bin/brew_list
  else
   rm -f /opt/homebrew/bin/brew_list
  fi
   rm -rf ~/.BREW_LIST
    exit
elif [[ $NAME = Linux && $1 && $1 = unlink ]];then
 rm -f /home/linuxbrew/.linuxbrew/bin/brew_list
  rm -rf ~/.BREW_LIST
   exit
fi

if [[ $NAME = Darwin ]];then
  if [[ $CPU =~ Intel &&  -e /usr/local/bin/brew_list ]];then
   echo exist /usr/local/bin/brew_list  
    exit
  elif [[ $CPU =~ M1 && -e /opt/homebrew/bin/brew_list ]];then 
   echo exist /opt/homebrew/bin/brew_list
    exit
  fi
elif [[ $NAME = Linux && -e /home/linuxbrew/.linuxbrew/bin/brew_list ]];then
 echo exist /home/linuxbrew/.linuxbrew/bin/brew_list
  exit
fi

DIR=$(cd $(dirname $0); pwd)

mkdir -p ~/.BREW_LIST

if [[ $NAME = Darwin ]];then
  if [[ $CPU =~ Intel ]];then
   cp $DIR/brew_list.pl /usr/local/bin/brew_list
  else
   cp $DIR/brew_list.pl /opt/homebrew/bin/brew_list
  fi
   cp $DIR/font.sh ~/.BREW_LIST/font.sh
    cp $DIR/tie.pl ~/.BREW_LIST/tie.pl
else
 cp $DIR/brew_list.pl /home/linuxbrew/.linuxbrew/bin/brew_list
  cp $DIR/font.sh ~/.BREW_LIST/font.sh
   cp $DIR/tie.pl ~/.BREW_LIST/tie.pl
fi

brew_list -new
