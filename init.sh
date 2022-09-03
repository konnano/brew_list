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
 [[ "$CPU" = x86_64 ]] && rm -f /usr/local/bin/bl /usr/local/share/zsh/site-functions/_bl ||\
  rm -f /opt/homebrew/bin/bl /opt/homebrew/share/zsh/site-functions/_bl
  rm -rf ~/.BREW_LIST ~/.JA_BREW
   echo rm all cache
    exit
elif [[ "$NAME" = Linux && "$LINK" = unlink ]];then
  rm -rf /home/linuxbrew/.linuxbrew/bin/bl ~/.BREW_LIST ~/.JA_BREW
   echo rm all cache
    exit
fi

if [[ ! "$LINK" || "$LINK" = JA ]];then
 if [[ "$NAME" = Darwin ]];then
  if [[ "$CPU" = x86_64 ]];then
   [[ ! -d /usr/local/Cellar ]] && echo " Not installed HOME BREW" && exit
   [[ -e /usr/local/bin/bl ]] && echo " exist /usr/local/bin/bl" && exit
    BREW="/usr/local/bin/bl"
  else
   [[ ! -d /opt/homebrew/Cellar ]] && echo " Not installed HOME BREW" && exit
   [[ -e /opt/homebrew/bin/bl ]] && echo " exist /opt/homebrew/bin/bl" && exit
    BREW="/opt/homebrew/bin/bl"
  fi
 else
  [[ ! -d /home/linuxbrew/.linuxbrew/Cellar ]] && echo " Not installed HOME BREW" && exit
  [[ -e /home/linuxbrew/.linuxbrew/bin/bl ]] && \
   echo " exist /home/linuxbrew/.linuxbrew/bin/bl" && exit
    BREW="/home/linuxbrew/.linuxbrew/bin/bl"
 fi

 curl -k https://formulae.brew.sh/formula >/dev/null 2>&1 || \
  { echo -e "\033[31m Not connected\033[00m"; exit 1; }
 trap 'rm -f "$BREW"; exit 1' 1 2 3 15
 DIR=$(cd $(dirname $0); pwd)
 Lang=$(printf $LC_ALL $LC_CTYPE $LANG 2>/dev/null)

 if [[ "$NAME" = Darwin ]];then
  [[ "$CPU" = x86_64 ]] && { cp $DIR/brew_list.pl /usr/local/bin/bl || ${die:?copy 1 error}; } ||\
   { cp $DIR/brew_list.pl /opt/homebrew/bin/bl || ${die:?copy 2 error}; }
   [[ "$LINK" = JA && $Lang =~ [uU][tT][fF]-?8$ ]] && cp -r $DIR/JA_BREW ~/.JA_BREW
 else
  cp $DIR/brew_list.pl /home/linuxbrew/.linuxbrew/bin/bl || ${die:?copy 3 error}
   [[ "$LINK" = JA && $Lang =~ [uU][tT][fF]-?8$ ]] && mkdir -p ~/.JA_BREW && cp $DIR/JA_BREW/ja_brew.txt ~/.JA_BREW
 fi
 bl -new
fi
