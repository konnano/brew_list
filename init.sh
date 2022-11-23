#!/bin/bash
 NAME=$(uname)
 MY_BREW=$(dirname $(dirname $(which brew) 2>/dev/null) 2>/dev/null) ||\
  { echo -e "\033[31m Not installed HOME BREW\033[00m"; exit 1; }
if [[ ! "$NAME" = Darwin && ! "$NAME" = Linux ]];then
 echo Not support OS; exit 1
elif [[ "$NAME" = Darwin ]];then
 VER=$(sw_vers -productVersion|\
 sed -E 's/^(1[1-3]).*/\1.0/;s/^(10\.)(1[0-5]).*/\1\2/;s/^(10\.)([1-9])($|\.).*/\10\2/')
 [[ 10.09 > "$VER" ]] && echo Use Tiger Brew && exit 1
fi

 LINK="$1"
if [[ "$LINK" = unlink ]];then
 rm -f $MY_BREW/bin/bl $MY_BREW/share/zsh/site-functions/_bl
  rm -rf ~/.BREW_LIST ~/.JA_BREW
   echo rm all cache
    exit
fi

if [[ ! $LINK || "$LINK" = JA ]];then
   [[ ! -d $MY_BREW/Cellar ]] && echo Not installed HOME BREW && exit 1
   [[ -e $MY_BREW/bin/bl ]] && echo exist $MY_BREW/bin/bl && exit 1

   curl -k https://formulae.brew.sh/formula >/dev/null 2>&1 ||\
    { echo -e "\033[31m Not connected\033[00m"; exit 1; }
   trap 'rm -rf $MY_BREW/bin/bl ~/.BREW_LIST ~/.JA_BREW; exit 1' 1 2 3 15
    DIR=$(cd $(dirname $0); pwd)
   Lang=$(printf $LC_ALL $LC_CTYPE $LANG 2>/dev/null)

   [[ "$LINK" = JA && ! $Lang =~ [uU][tT][fF]-?8$ ]] && echo Not Lang
   if [[ "$NAME" = Darwin ]];then
    cp $DIR/brew_list.pl "$MY_BREW/bin/bl" || ${die:?copy error};
     [[ "$LINK" = JA && $Lang =~ [uU][tT][fF]-?8$ ]] && cp -r $DIR/JA_BREW ~/.JA_BREW
   else
    cp $DIR/brew_list.pl "$MY_BREW/bin/bl" || ${die:?copy error}
     [[ "$LINK" = JA && $Lang =~ [uU][tT][fF]-?8$ ]] && mkdir -p ~/.JA_BREW &&\
      cp $DIR/JA_BREW/ja_brew.txt ~/.JA_BREW
   fi
  bl -new
fi
