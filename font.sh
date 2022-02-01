#!/bin/bash
 NAME=$(uname)
[[ ! $1 || $1 =~ ^[01]$ ]] || ${die:?input 1 error}
[[ ! $2 || $2 =~ ^[01]$ ]] || ${die:?input 2 error}

if [[ $1 -eq 1 ]];then
 TI=$(date +%s)
 LS=$(date -r ~/.BREW_LIST/LOCK "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
 if [[ $LS ]];then
  if [[ "$NAME" = Darwin ]];then
   LS=$(( $(date -jf "%Y-%m-%d %H:%M:%S" "$LS" +%s 2>/dev/null)+60 )) &&\
    { [[ $LS -eq 60 ]] && exit || [[ $TI -gt $LS ]] && unset LS && rm -rf ~/.BREW_LIST/LOCK; }
  else
   LS=$(( $(date +%s --date "$LS" 2>/dev/null)+60 )) &&\
    { [[ $LS -eq 60 ]] && exit || [[ $TI -gt $LS ]] && unset LS && rm -rf ~/.BREW_LIST/LOCK; }
  fi
 fi
fi

if [[ $2 -eq 1 ]];then
 if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
  exit 2
 fi

 trap 'math_rm 1; exit 1' 1 2 3 15
 math_rm(){ [[ $1 ]] && rm -f ~/.BREW_LIST/{master*,*.html,DBM*} || rm -f ~/.BREW_LIST/{master*,*.html}
                        rm -rf ~/.BREW_LIST/{homebrew*,{0..9},WAIT,LOCK}; }

 if [[ "$NAME" = Darwin ]];then
   mkdir -p ~/.BREW_LIST/{0..9}
 curl -sko ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
  { math_rm; ${die:?curl 1 error}; }
   rmdir ~/.BREW_LIST/0
 curl -sko ~/.BREW_LIST/Q_CASK.html https://formulae.brew.sh/cask/index.html ||\
  { math_rm; ${die:?curl 2 error}; }
   rmdir ~/.BREW_LIST/1
 curl -skLo ~/.BREW_LIST/master1.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
  { math_rm; ${die:?curl 3 error}; }
   rmdir ~/.BREW_LIST/2
 curl -skLo ~/.BREW_LIST/master2.zip https://github.com/Homebrew/homebrew-cask-drivers/archive/master.zip ||\
  { math_rm; ${die:?curl 4 error}; }
   rmdir ~/.BREW_LIST/3
 curl -skLo ~/.BREW_LIST/master3.zip https://github.com/Homebrew/homebrew-cask-versions/archive/master.zip ||\
  { math_rm; ${die:?curl 5 error}; }
   rmdir ~/.BREW_LIST/4

 unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 1 error}; }
 unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 2 error}; }
 unzip -q ~/.BREW_LIST/master3.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 3 error}; }
   rmdir ~/.BREW_LIST/5

perl<<"EOF"
  if( `uname -m` =~ /arm64/ ){
   $VERS = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-versions';
    $DDIR = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
     $FDIR = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
  }else{
   $VERS = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-versions';
    $DDIR = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
     $FDIR = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
  }
   opendir $dir1,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-fonts-master/Casks" or die " DIR1 $!\n";
    for $hand1( readdir($dir1) ){ 
     next if $hand1 =~ /^\./;
      $hand1 =~ s/(.+)\.rb$/$1/;
       if( $FDIR ){
        push @file1,"$hand1\n";
       }else{ $i1 = 1;
        push @file1,"homebrew/cask-fonts/$hand1\n";
       }
    }
   closedir $dir1;
    @file1 = sort{$a cmp $b}@file1;

   opendir $dir2,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-drivers-master/Casks" or die " DIR2 $!\n";
    for $hand2( readdir($dir2) ){ 
     next if $hand2 =~ /^\./;
      $hand2 =~ s/(.+)\.rb$/$1/;
       if( $DDIR ){
        push @file2,"$hand2\n";
       }else{ $i2 = 1;
        push @file2,"homebrew/cask-drivers/$hand2\n";
       }
    }
   closedir $dir2;
    @file2 = sort{$a cmp $b}@file2;

   opendir $dir3,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-versions-master/Casks" or die " DIR3 $!\n";
    for $hand3( readdir($dir3) ){ 
     next if $hand3 =~ /^\./;
      $hand3 =~ s/(.+)\.rb$/$1/;
       if( $VERS ){
        push @file3,"$hand3\n";
       }else{ $i3 = 1;
        push @file3,"homebrew/cask-versions/$hand3\n";
       }
    }
   closedir $dir3;
    @file3 = sort{$a cmp $b}@file3;

   ( $i1 and $i2 and $i3 ) ? push @file,"#\n",@file1,@file2,@file3 :
   ( $i1 and $i2 ) ? push @file,"3\n2\n",@file3,"0\n",@file1,"1\n",@file2 :
   ( $i1 and $i3 ) ? push @file,"4\n1\n",@file2,"0\n",@file1,"2\n",@file3 :
   ( $i2 and $i3 ) ? push @file,"5\n0\n",@file1,"1\n",@file2,"2\n",@file3 :
    $i1 ? push @file,"6\n1\n",@file2,"2\n",@file3,"0\n",@file1 :
    $i2 ? push @file,"7\n0\n",@file1,"2\n",@file3,"1\n",@file2 :
    $i3 ? push @file,"8\n0\n",@file1,"1\n",@file2,"2\n",@file3 :
          push @file,"9\n0\n",@file1,"1\n",@file2,"2\n",@file3;

    open $FILE1,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die " TAP FILE $!\n";
     print $FILE1 @file;
    close $FILE1;

  open $FILE2,'<', "$ENV{'HOME'}/.BREW_LIST/Q_CASK.html" or die " FILE2 $!\n";
   while($brew=<$FILE2>){
    if( $brew =~ s|^\s+<td><a href[^>]+>(.+)</a></td>\n|$1| ){
     $tap1 = $brew; next;
    }elsif( not $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
     $tap2 = $brew;
     $tap2 =~ s/&quot;/"/g;
     $tap2 =~ s/&amp;/&/g;
     $tap2 =~ s/&lt;/</g;
     $tap2 =~ s/&gt;/>/g;
     $test = 1; next;
    }elsif( $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
     $tap3 = $brew;
     $test = 0;
    }
     push @file4,"$tap1\t$tap3\t$tap2\n" if $tap1;
    $tap1 = $tap2 = $tap3 = '';
   }
  close $FILE2;
   open $FILE3,'>',"$ENV{'HOME'}/.BREW_LIST/cask.txt" or die " FILE5 $!\n";
    print $FILE3 @file4;
   close $FILE3;
EOF
[[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 1 error};

 else
  curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html || \
   { math_rm; ${die:?curl 6 error}; }
 fi

perl<<"EOF"
  open $FILE1,'<', "$ENV{'HOME'}/.BREW_LIST/Q_BREW.html" or die " FILE6 $!\n";
   while($brew=<$FILE1>){
    if( $brew =~ s|^\s+<td><a href[^>]+>(.+)</a></td>\n|$1| ){
     $tap1 = $brew; next;
    }elsif( not $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
     $tap2 = $brew;
     $test = 1; next;
    }elsif( $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
     $tap3 = $brew;
     $tap3 =~ s/&quot;/"/g;
     $tap3 =~ s/&amp;/&/g;
     $tap3 =~ s/&lt;/</g;
     $tap3 =~ s/&gt;/>/g;
     $test = 0;
    }
     push @file1,"$tap1\t$tap2\t$tap3\n" if $tap1;
    $tap1 = $tap2 = $tap3 = '';
   }
  close $FILE1;
  @file1 = sort{$a cmp $b}@file1;
   open $FILE2,'>',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE7 $!\n";
    print $FILE2 @file1;
   close $FILE2;
EOF
[[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 2 error};

 rm -rf  ~/.BREW_LIST/6
 perl ~/.BREW_LIST/tie.pl || { math_rm 1 && ${die:?perl tie error}; }

 if [[ "$NAME" = Darwin ]];then
  mv ~/.BREW_LIST/DBMG.db ~/.BREW_LIST/DBM.db
 else
  mv ~/.BREW_LIST/DBMG.dir ~/.BREW_LIST/DBM.dir
  mv ~/.BREW_LIST/DBMG.pag ~/.BREW_LIST/DBM.pag
 fi
 math_rm
fi
