#!/bin/bash

if [ `uname` = Darwin -a $1 -a $1 = unlink ];then
 rm -f /usr/local/bin/brew_list
  rm -rf ~/.BREW_LIST
   exit
elif [ `uname` = Linux -a $1 -a $1 = unlink ];then
 rm -f /home/linuxbrew/.linuxbrew/bin/brew_list
  rm -rf ~/.BREW_LIST
   exit
fi

if [ `uname` = Darwin -a -e '/usr/local/bin/brew_list' ];then
 echo exist /usr/local/bin/brew_list
  exit
elif [ `uname` = Linux -a -e '/home/linuxbrew/.linuxbrew/bin/brew_list' ];then
 echo exist /home/linuxbrew/.linuxbrew/bin/brew_list
  exit
fi

DIR=$(cd $(dirname $0); pwd)

mkdir -p ~/.BREW_LIST

if [ `uname` = Darwin ];then
 cp $DIR/brew_list.pl /usr/local/bin/brew_list
  cp $DIR/font.sh ~/.BREW_LIST/font.sh
   cp $DIR/tie.pl ~/.BREW_LIST/tie.pl
elif [ `uname` = Linux ];then
 cp $DIR/brew_list.pl /home/linuxbrew/.linuxbrew/bin/brew_list
  cp $DIR/font.sh ~/.BREW_LIST/font.sh
   cp $DIR/tie.pl ~/.BREW_LIST/tie.pl
fi

brew_list -new
