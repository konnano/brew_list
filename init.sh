#!/bin/bash
 NAME=$(uname)
 MY_BREW=$(CO=$(command -v brew);echo ${CO%/bin/brew})
 [[ -d "$MY_BREW/Homebrew" ]] && MY_HOME="$MY_BREW/Homebrew"
 [[ ! $MY_BREW ]] && echo -e "\033[31m Not installed HOME BREW\033[00m" && exit 1
if [[ ! $NAME = Darwin && ! $NAME = Linux ]];then
 echo Not support OS; exit 1
elif [[ $NAME = Darwin ]];then
 VER=$(sw_vers -productVersion|
       sed -E 's/^(1[1-5]).*/\1.0/;s/^(10\.1)([0-5]).*/\1\2/;s/^(10\.)([1-9])\..*/\10\2/')
 [[ 10.11 > $VER ]] && echo Use Tiger Brew && exit 1
fi

 LINK=$1;
if [[ $LINK = unlink ]];then
 [[ ! -d $MY_BREW/Cellar ]] && ${die:?Not exists directory : brew}
 rm -f $MY_BREW/bin/bl $MY_BREW/share/zsh/site-functions/_bl
  rm -rf ~/.BREW_LIST ~/.JA_BREW
   echo rm all cache
    if [[ -d "$MY_HOME/Library/Taps/homebrew/homebrew-core" ]];then
    read -p 'untap homebrew/cask homebrew/core ? [y/n]:' i
     case $i in
      y)
        sed -i.txt '/export *HOMEBREW_NO_INSTALL_FROM_API=1/d' ~/$(echo .${SHELL##*/}rc)
        unset HOMEBREW_NO_INSTALL_FROM_API
        brew untap homebrew/cask 2>/dev/null
        brew untap homebrew/core ;;
      *) exit ;;
     esac
    fi
 exit
fi

if [[ ! $LINK || $LINK = JA ]];then
   [[ ! -d $MY_BREW/Cellar ]] && ${die:?Not installed brew}
   if [[ -f $MY_BREW/bin/bl ]];then
    read -p 'exist $MY_BREW/bin/bl bl upgrade [y/n]:' i
     case $i in
      y)      ;;
      *) exit ;;
     esac
   fi
   [[ $NAME = Darwin ]] && T='-t1' || T='-w1'
   ping $T -c1 formulae.brew.sh >/dev/null 2>&1 ||\
    { echo -e "\033[31m Not connected\033[00m"; exit 1; }
   trap 'rm -rf $MY_BREW/bin/bl ~/.BREW_LIST ~/.JA_BREW; exit 1' 1 2 3 15
    DIR=$(cd $(dirname $0); pwd)
   Lang=$(printf $LC_ALL $LC_CTYPE $LANG 2>/dev/null)

   [[ $LINK = JA && ! $Lang =~ [uU][tT][fF]-?8$ ]] && echo Not Lang
   if [[ $NAME = Darwin ]];then
    cp $DIR/bl $MY_BREW/bin/bl || ${die:?copy error}
     [[ $LINK = JA && $Lang =~ [uU][tT][fF]-?8$ ]] && cp -r $DIR/JA_BREW ~/.JA_BREW
   else
    cp $DIR/bl $MY_BREW/bin/bl || ${die:?copy error}
     [[ $LINK = JA && $Lang =~ [uU][tT][fF]-?8$ ]] && mkdir -p ~/.JA_BREW &&\
      cp $DIR/JA_BREW/ja_brew.txt ~/.JA_BREW
   fi
  bl -new
fi
