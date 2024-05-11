#!/bin/bash
 NAME=$(uname)
[[ $1 =~ ^[01]$ ]] || ${die:?input 1 error}
[[ ! $2 || $2 =~ ^[12]$ ]] || ${die:?input 2 error}; CO=$3

math_rm(){ [[ $1 ]] && rm -f ~/.BREW_LIST/{*.html,DBM*} || rm -f ~/.BREW_LIST/*.html
                       rm -rf ~/.BREW_LIST/{homebrew*,{0..19},parse,cparse,WAIT$CO,LOCK,TAP,font2.sh,tie2.pl} ~/.JA_BREWG; }
 TI=$(date +%s)
if [[ $1 = 1 ]];then
 LS=$(date -r ~/.BREW_LIST/LOCK "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
 if [[ $LS ]];then
  if [[ $NAME = Darwin ]];then
   LS1=$(( $(date -jf "%Y-%m-%d %H:%M:%S" "$LS" +%s 2>/dev/null)+60 ))
    (( $LS1 != 60 && $TI > $LS1 )) && math_rm
  else
   LS1=$(( $(date +%s --date "$LS" 2>/dev/null)+60 ))
    (( $LS1 != 60 && $TI > $LS1 )) && math_rm
  fi
 fi
fi

if [[ $2 ]];then
 if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
   exit 2
 fi
 trap 'math_rm 1; exit 1' 1 2 3 15

  LS2=$(date -r ~/.JA_BREW/ja_brew.txt "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
 if [[ $LS2 ]];then
  if [[ $NAME = Darwin ]];then
   LS3=$(( $(date -jf "%Y-%m-%d %H:%M:%S" "$LS2" +%s 2>/dev/null)+86400 ))
  else
   LS3=$(( $(date +%s --date "$LS2" 2>/dev/null)+86400 ))
  fi
  if (( $TI > $LS3 ));then
   git clone -q https://github.com/konnano/JA_BREW ~/.JA_BREWG 2>/dev/null || { math_rm; ${die:?git clone error}; }
    cp ~/.JA_BREWG/* ~/.JA_BREW/
     rm -rf ~/.JA_BREWG ~/.JA_BREW/.git
    [[ $NAME = Linux ]] && rm ~/.JA_BREW/ja_cask.txt ~/.JA_BREW/ja_tap.txt
    [[ $NAME = Darwin ]] && rm ~/.JA_BREW/ja_linux.txt
  fi
 fi

 if [[ $NAME = Darwin ]];then
  if [[ $2 = 1 ]];then
    mkdir -p ~/.BREW_LIST/{0..19}
    rm -f ~/.BREW_LIST/keepme.zip
   curl -sko ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
    { math_rm; ${die:?curl 1 error}; }
   curl -sko ~/.BREW_LIST/Q_CASK.html https://formulae.brew.sh/cask/index.html ||\
    { math_rm; ${die:?curl 2 error}; }
     rmdir ~/.BREW_LIST/0
   curl -skLo ~/.BREW_LIST/master.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
    { math_rm; ${die:?curl 3 error}; }
   curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics/install/30d/index.html ||\
    { math_rm; ${die:?curl 5 error}; }
     rmdir ~/.BREW_LIST/1
   curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics/install/90d/index.html ||\
    { math_rm; ${die:?curl 6 error}; }
   curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics/install/365d/index.html ||\
    { math_rm; ${die:?curl 7 error}; }
     rmdir ~/.BREW_LIST/2
   curl -sko ~/.BREW_LIST/cna1.html https://formulae.brew.sh/analytics/cask-install/30d/index.html ||\
    { math_rm; ${die:?curl 8 error}; }
   curl -sko ~/.BREW_LIST/cna2.html https://formulae.brew.sh/analytics/cask-install/90d/index.html ||\
    { math_rm; ${die:?curl 9 error}; }
     rmdir ~/.BREW_LIST/3
   curl -sko ~/.BREW_LIST/cna3.html https://formulae.brew.sh/analytics/cask-install/365d/index.html ||\
    { math_rm; ${die:?curl a error}; }
   curl -sko ~/.BREW_LIST/req1.html https://formulae.brew.sh/analytics/install-on-request/30d/index.html ||\
    { math_rm; ${die:?curl b error}; }
     rmdir ~/.BREW_LIST/4
   curl -sko ~/.BREW_LIST/req2.html https://formulae.brew.sh/analytics/install-on-request/90d/index.html ||\
    { math_rm; ${die:?curl c error}; }
   curl -sko ~/.BREW_LIST/req3.html https://formulae.brew.sh/analytics/install-on-request/365d/index.html ||\
    { math_rm; ${die:?curl d error}; }
     rmdir ~/.BREW_LIST/5
   curl -sko ~/.BREW_LIST/err1.html https://formulae.brew.sh/analytics/build-error/30d/index.html ||\
    { math_rm; ${die:?curl e error}; }
   curl -sko ~/.BREW_LIST/err2.html https://formulae.brew.sh/analytics/build-error/90d/index.html ||\
    { math_rm; ${die:?curl f error}; }
     rmdir ~/.BREW_LIST/6
   curl -sko ~/.BREW_LIST/err3.html https://formulae.brew.sh/analytics/build-error/365d/index.html ||\
    { math_rm; ${die:?curl g error}; }
     rmdir ~/.BREW_LIST/7
  fi
   unzip -q ~/.BREW_LIST/master.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 1 error}; }
   export Perl_B=$(CO=$(command -v brew);echo ${CO%/bin/brew})
    [[ ! $Perl_B ]] && { math_rm; ${die:?brew path not found}; }
perl<<"EOF"
   $MY_HOME = -d "$ENV{'Perl_B'}/Homebrew" ? "$ENV{'Perl_B'}/Homebrew" : $ENV{'Perl_B'};
    $FDIR = 1 if -d "$MY_HOME/Library/Taps/homebrew/homebrew-cask-fonts/Casks";

    opendir $dir,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-fonts-master/Casks" or die " TAP DIR $!\n";
     for $hand( readdir $dir ){ next if index($hand,'.') == 0;
      $hand =~ s/(.+)\.rb$/$1/;
       if( $FDIR ){
        push @file1,"$hand\n";
       }else{ $i1 = 1;
        push @file1,"homebrew/cask-fonts/$hand\n";
       }
     }
    closedir $dir;
    @file1 = sort @file1;

    $i1 ? push @file,"3\n1\n",@file1 :
          push @file,"4\n0\n",@file1 ;

   open $FILE1,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die " TAP FILE $!\n";
    print $FILE1 @file;
   close $FILE1;
  rmdir "$ENV{'HOME'}/.BREW_LIST/8";
EOF
  (( $? != 0 )) && math_rm 1 && ${die:?perl 1 error}

  if [[ $2 = 1 ]];then
perl<<"EOF"
   open $FILE1,'<',"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html" or die " CASK FILE 1 $!\n";
    while($brew=<$FILE1>){
     if( $brew =~ s|^\s*<td><a href[^>]+>([^<]*)</a></td>\n|$1| ){
      $tap1 = $brew; next;
     }elsif( not $test and $brew =~ s|^\s*<td>([^<]*)</td>\n|$1| ){
      $tap2 = $brew;
      $test = 1; next;
     }elsif( $test and $test == 1 and $brew =~ s|^\s*<td>([^<]*)</td>\n|$1| ){
      $tap3 = $brew;
      $tap3 =~ s/&quot;/"/g;
      $tap3 =~ s/&amp;/&/g;
      $tap3 =~ s/&lt;/</g;
      $tap3 =~ s/&gt;/>/g;
      $test = 2; next;
     }elsif( $test and $test == 2 and $brew =~ m|^\s*<td>[^<]*</td>\n| ){
      $test = 0;
     }
       push @ANA,$tap1 if $tap1;
      push @file1,"$tap1\t$tap2\t$tap3\n" if $tap1;
     $tap1 = $tap2 = $tap3 = '';
    }
   close $FILE1;
   open $FILE2,'>',"$ENV{'HOME'}/.BREW_LIST/cask.txt" or die " CASK FILE 2 $!\n";
    print $FILE2 @file1;
   close $FILE2;

   @cna = (['cna1','HA1','IN1'],['cna2','HA2','IN2'],['cna3','HA3','IN3']);
   local $/;
  for $ha( @cna ){ $e = 0;
   open $dir1,'<',"$ENV{'HOME'}/.BREW_LIST/$ha->[0].html" or die " cna1 $!\n";
    $an = <$dir1>; close $dir1;
   @an = $an =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
    for( $i=0;$i<@an;$i+=2 ){ ${$ha->[1]}{$an[$i]} = ++$e; ${$ha->[2]}{$an[$i]} = $an[$i+1] }
  }

  for( $in1=0;$in1<@ANA;$in1++ ){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN1{$ANA[$in1]} ? "\t$IN1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN2{$ANA[$in1]} ? "\t$IN2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN3{$ANA[$in1]} ? "\t$IN3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir2,'>',"$ENV{'HOME'}/.BREW_LIST/cna.txt" or die " cna2 $!\n";
   print $dir2 @fom;
  close $dir2;
 rmdir "$ENV{'HOME'}/.BREW_LIST/9";
EOF
  (( $? != 0 )) && math_rm 1 && ${die:?perl 2 error}
  fi
 else
  if [[ $2 = 1 ]];then
   curl -sko ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
    { math_rm; ${die:?curl h error}; }
   curl -skLo ~/.BREW_LIST/font.zip https://github.com/Homebrew/homebrew-linux-fonts/archive/master.zip ||\
     { math_rm; ${die:?curl i error}; }
   curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics/install/30d/index.html ||\
     { math_rm; ${die:?curl j error}; }
   curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics/install/90d/index.html ||\
     { math_rm; ${die:?curl k error}; }
   curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics/install/365d/index.html ||\
     { math_rm; ${die:?curl l error}; }
   curl -sko ~/.BREW_LIST/req1.html https://formulae.brew.sh/analytics/install-on-request/30d/index.html ||\
     { math_rm; ${die:?curl m error}; }
   curl -sko ~/.BREW_LIST/req2.html https://formulae.brew.sh/analytics/install-on-request/90d/index.html ||\
     { math_rm; ${die:?curl n error}; }
   curl -sko ~/.BREW_LIST/req3.html https://formulae.brew.sh/analytics/install-on-request/365d/index.html ||\
     { math_rm; ${die:?curl o error}; }
   curl -sko ~/.BREW_LIST/err1.html https://formulae.brew.sh/analytics/build-error/30d/index.html ||\
     { math_rm; ${die:?curl p error}; }
   curl -sko ~/.BREW_LIST/err2.html https://formulae.brew.sh/analytics/build-error/90d/index.html ||\
     { math_rm; ${die:?curl q error}; }
   curl -sko ~/.BREW_LIST/err3.html https://formulae.brew.sh/analytics/build-error/365d/index.html ||\
     { math_rm; ${die:?curl r error}; }
  fi
   unzip -q ~/.BREW_LIST/font.zip -d ~/.BREW_LIST || { math_rm 1; ${die:?unzip 3 error}; }
   export Perl_B=$(CO=$(command -v brew);echo ${CO%/bin/brew})
    [[ ! $Perl_B ]] && { math_rm; ${die:?brew path not found}; }
perl<<"EOF"
   $MY_HOME = -d "$ENV{'Perl_B'}/Homebrew" ? "$ENV{'Perl_B'}/Homebrew" : $ENV{'Perl_B'};
    $LFOD = 1 if -d "$MY_HOME/Library/Taps/homebrew/homebrew-linux-fonts/Formula";

   opendir $dir1,"$ENV{'HOME'}/.BREW_LIST/homebrew-linux-fonts-master/Formula" or die " LINUX DIR $!\n";
    for $hand1( readdir $dir1 ){ next if index($hand1,'.') == 0;
      $hand1 =~ s/(.+)\.rb$/$1/;
       if( $LFOD ){
        push @file1,"$hand1\n";
       }else{ $i1 = 1;
        push @file1,"homebrew/linux-fonts/$hand1\n";
       }
    }
   closedir $dir1;
    @file1 = sort @file1;
     $i1 ? push @file2,"3\n",@file1 : push @file2,"4\n0\n",@file1;

   open $FILE1,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die " LINUX FILE $!\n";
    print $FILE1 @file2;
   close $FILE1;
EOF
 fi

 if [[ $2 = 1 ]];then
perl<<"EOF"
  open $FILE1,'<',"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html" or die " BREW FILE 1 $!\n";
   while($brew=<$FILE1>){
    if( $brew =~ s|^\s*<td><a href[^>]+>([^<]*)</a></td>\n|$1| ){
     $tap1 = $brew; next;
    }elsif( not $test and $brew =~ s|^\s*<td>([^<]*)</td>\n|$1| ){
     $tap2 = $brew;
     $test = 1; next;
    }elsif( $test and $brew =~ s|^\s*<td>([^<]*)</td>\n|$1| ){
     $tap3 = $brew;
     $tap3 =~ s/&quot;/"/g;
     $tap3 =~ s/&amp;/&/g;
     $tap3 =~ s/&lt;/</g;
     $tap3 =~ s/&gt;/>/g;
     $test = 0;
    }
      push @ANA,$tap1 if $tap1;
     push @file1,"$tap1\t$tap2\t$tap3\n" if $tap1;
    $tap1 = $tap2 = $tap3 = '';
   }
  close $FILE1;
  @file1 = sort @file1;
   open $FILE2,'>',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " BREW FILE 2 $!\n";
    print $FILE2 @file1;
   close $FILE2;

   @ana = (['ana1','HA1','IN1'],['ana2','HA2','IN2'],['ana3','HA3','IN3'],
           ['req1','HA4','EQ1'],['req2','HA5','EQ2'],['req3','HA6','EQ3'],
           ['err1','HA7','ER1'],['err2','HA8','ER2'],['err3','HA9','ER3']);
   local $/;
  for $ha( @ana ){ $e = 0;
   open $dir1,'<',"$ENV{'HOME'}/.BREW_LIST/$ha->[0].html" or die " ana1 $!\n";
    $an = <$dir1>; close $dir1;
   @an = $an =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
    for( $i=0;$i<@an;$i+=2 ){ ${$ha->[1]}{$an[$i]} = ++$e; ${$ha->[2]}{$an[$i]} = $an[$i+1] }
  }

  for( $in1=0;$in1<@ANA;$in1++ ){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN1{$ANA[$in1]} ? "\t$IN1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN2{$ANA[$in1]} ? "\t$IN2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN3{$ANA[$in1]} ? "\t$IN3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA4{$ANA[$in1]} ? "\t$HA4{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA5{$ANA[$in1]} ? "\t$HA5{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA6{$ANA[$in1]} ? "\t$HA6{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $EQ1{$ANA[$in1]} ? "\t$EQ1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $EQ2{$ANA[$in1]} ? "\t$EQ2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $EQ3{$ANA[$in1]} ? "\t$EQ3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA7{$ANA[$in1]} ? "\t$HA7{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA8{$ANA[$in1]} ? "\t$HA8{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA9{$ANA[$in1]} ? "\t$HA9{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $ER1{$ANA[$in1]} ? "\t$ER1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $ER2{$ANA[$in1]} ? "\t$ER2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $ER3{$ANA[$in1]} ? "\t$ER3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir2,'>',"$ENV{'HOME'}/.BREW_LIST/ana.txt" or die " ana2 $!\n";
   print $dir2 @fom;
  close $dir2;
 rmdir "$ENV{'HOME'}/.BREW_LIST/10";
EOF
 (( $? != 0 )) && math_rm 1 && ${die:?perl 3 error}

  perl ~/.BREW_LIST/tie.pl || { math_rm 1 && ${die:?perl tie1 error}; }

  if [[ $NAME = Darwin ]];then
   mv ~/.BREW_LIST/DBMG.db ~/.BREW_LIST/DBM.db
  else
   mv ~/.BREW_LIST/DBMG.dir ~/.BREW_LIST/DBM.dir
   mv ~/.BREW_LIST/DBMG.pag ~/.BREW_LIST/DBM.pag
  fi
 fi
  if [[ $2 = 2 ]];then
   perl ~/.BREW_LIST/tie.pl 1 || { math_rm 1 && ${die:?perl tie2 error}; }
  fi
 rm -rf ~/.BREW_LIST/19
 math_rm
fi
