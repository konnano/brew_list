#!/bin/bash
 NAME=$(uname)
if [[ ! "$NAME" = Darwin && ! "$NAME" = Linux ]];then
 ${die:?Not support OS}
elif [[ "$NAME" = Darwin ]];then
 VER=$(sw_vers -productVersion|\
 sed -E 's/^(1[1-2]).*/\1.0/;s/^(10\.)(1[0-5]).*/\1\2/;s/^(10\.)([0-9])($|\.).*/\10\2/')
 [[ 10.09 > "$VER" ]] && echo ' Use Tiger Brew' && exit 1
 CPU=$(uname -m)
fi
 LINK="$1"
if [[ "$NAME" = Darwin && "$LINK" = unlink ]];then
 [[ "$CPU" = x86_64 ]] && rm -f /usr/local/bin/brew_list || rm -f /opt/homebrew/bin/brew_list
  rm -rf ~/.BREW_LIST
   echo rm all cache
    exit
elif [[ "$NAME" = Linux && "$LINK" = unlink ]];then
  rm -rf /home/linuxbrew/.linuxbrew/bin/brew_list ~/.BREW_LIST
   echo rm all cache
    exit
fi

if [[ ! "$LINK" ]];then
 if [[ "$NAME" = Darwin ]];then
  if [[ "$CPU" = x86_64 ]];then
   [[ ! -d /usr/local/Cellar ]] && echo " Not installed HOME BREW" && exit
   [[ -e /usr/local/bin/brew_list ]] && echo " exist /usr/local/bin/brew_list" && exit
  else
   [[ ! -d /opt/homebrew/Cellar ]] && echo " Not installed HOME BREW" && exit
   [[ -e /opt/homebrew/bin/brew_list ]] && echo " exist /opt/homebrew/bin/brew_list" && exit
  fi
 else
  [[ ! -d /home/linuxbrew/.linuxbrew/Cellar ]] && echo " Not installed HOME BREW" && exit
  [[ -e /home/linuxbrew/.linuxbrew/bin/brew_list ]] && \
   echo " exist /home/linuxbrew/.linuxbrew/bin/brew_list" && exit
 fi

 curl -k https://formulae.brew.sh/formula >/dev/null 2>&1 || \
  { echo -e "\033[31m Not connected\033[00m"; exit 1; }
 DIR=$(cd $(dirname $0); pwd)

 if [[ "$NAME" = Darwin ]];then
  [[ "$CPU" = x86_64 ]] && { cp $DIR/brew_list.pl /usr/local/bin/brew_list || ${die:?copy 1 error}; } ||\
   { cp $DIR/brew_list.pl /opt/homebrew/bin/brew_list || ${die:?copy 2 error}; }
 else
  cp $DIR/brew_list.pl /home/linuxbrew/.linuxbrew/bin/brew_list || ${die:?copy 3 error}
 fi
 brew_list -new
fi
