#!/bin/bash
 NAME=`uname`
if [[ ! $NAME = Darwin && ! $NAME = Linux ]];then
 exit
elif [[ $NAME = Darwin ]];then
 VER=`sw_vers -productVersion|sed -E 's/^(1[1-2]).*/\1.0/'|\
                              sed -E 's/^(10\.)(1[0-5]).*/\1\2/'|\
                              sed -E 's/^(10\.)([0-9])($|\.).*/\10\2/'`
 [[ 10.09 > $VER ]] && echo ' Use Tiger Brew' && exit
 CPU=`uname -m`
fi

if [[ $NAME = Darwin && $1 = unlink ]];then
 if [[ $CPU =~ x86_64 ]];then
  rm -f /usr/local/bin/brew_list
 else
  rm -f /opt/homebrew/bin/brew_list
 fi
  rm -rf ~/.BREW_LIST
   echo rm all cache
    exit
elif [[ $NAME = Linux && $1 = unlink ]];then
 rm -rf /home/linuxbrew/.linuxbrew/bin/brew_list ~/.BREW_LIST
   echo rm all cache
    exit
fi

if [[ ! $1 ]];then
 if [[ $NAME = Darwin ]];then
  if [[ $CPU =~ x86_64 &&  -e /usr/local/bin/brew_list ]];then
   echo exist /usr/local/bin/brew_list  
    exit
  elif [[ $CPU =~ arm64 && -e /opt/homebrew/bin/brew_list ]];then 
   echo exist /opt/homebrew/bin/brew_list
    exit
  fi
 elif [[ $NAME = Linux && -e /home/linuxbrew/.linuxbrew/bin/brew_list ]];then
  echo exist /home/linuxbrew/.linuxbrew/bin/brew_list
   exit
 fi

 curl -k https://formulae.brew.sh/formula >/dev/null 2>&1 || \
  { echo -e "\033[31m Not connected\033[00m"; exit; }
 DIR=$(cd $(dirname $0); pwd)

 if [[ $NAME = Darwin ]];then
  if [[ $CPU =~ x86_64 ]];then
   cp $DIR/brew_list.pl /usr/local/bin/brew_list
  else
   cp $DIR/brew_list.pl /opt/homebrew/bin/brew_list
  fi
 else
  cp $DIR/brew_list.pl /home/linuxbrew/.linuxbrew/bin/brew_list
 fi
 brew_list -new
fi
