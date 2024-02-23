#!/bin/bash
 NAME=$(uname)
[[ $1 =~ ^[01]$ ]] || ${die:?input 1 error}
[[ ! $2 || $2 =~ ^[12]$ ]] || ${die:?input 2 error}

math_rm(){ [[ $1 ]] && rm -f ~/.BREW_LIST/{master*,*.html,DBM*} || rm -f ~/.BREW_LIST/{master*,*.html}
                       rm -rf ~/.BREW_LIST/{homebrew*,{0..19},WAIT,LOCK,TAP,font2.sh,tie2.pl} ~/.JA_BREWG; }
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
    cp ~/.JA_BREWG/* ~/.JA_BREW
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
   curl -skLo ~/.BREW_LIST/master1.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
    { math_rm; ${die:?curl 3 error}; }
     rmdir ~/.BREW_LIST/1
   curl -skLo ~/.BREW_LIST/master2.zip https://github.com/Homebrew/homebrew-cask-versions/archive/master.zip ||\
    { math_rm; ${die:?curl 4 error}; }
   zip -jq ~/.BREW_LIST/keepme.zip ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ||\
    { rm -f keepme.zip; math_rm; ${die:?zip error}; }
     rmdir ~/.BREW_LIST/2
   curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics/install/30d/index.html ||\
    { math_rm; ${die:?curl 5 error}; }
   curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics/install/90d/index.html ||\
    { math_rm; ${die:?curl 6 error}; }
     rmdir ~/.BREW_LIST/3
   curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics/install/365d/index.html ||\
    { math_rm; ${die:?curl 7 error}; }
   curl -sko ~/.BREW_LIST/cna1.html https://formulae.brew.sh/analytics/cask-install/30d/index.html ||\
    { math_rm; ${die:?curl 8 error}; }
     rmdir ~/.BREW_LIST/4
   curl -sko ~/.BREW_LIST/cna2.html https://formulae.brew.sh/analytics/cask-install/90d/index.html ||\
    { math_rm; ${die:?curl 9 error}; }
   curl -sko ~/.BREW_LIST/cna3.html https://formulae.brew.sh/analytics/cask-install/365d/index.html ||\
    { math_rm; ${die:?curl a error}; }
     rmdir ~/.BREW_LIST/5
   curl -sko ~/.BREW_LIST/req1.html https://formulae.brew.sh/analytics/install-on-request/30d/index.html ||\
    { math_rm; ${die:?curl b error}; }
   curl -sko ~/.BREW_LIST/req2.html https://formulae.brew.sh/analytics/install-on-request/90d/index.html ||\
    { math_rm; ${die:?curl c error}; }
   curl -sko ~/.BREW_LIST/req3.html https://formulae.brew.sh/analytics/install-on-request/365d/index.html ||\
    { math_rm; ${die:?curl d error}; }
     rmdir ~/.BREW_LIST/6
   curl -sko ~/.BREW_LIST/err1.html https://formulae.brew.sh/analytics/build-error/30d/index.html ||\
    { math_rm; ${die:?curl e error}; }
   curl -sko ~/.BREW_LIST/err2.html https://formulae.brew.sh/analytics/build-error/90d/index.html ||\
    { math_rm; ${die:?curl f error}; }
   curl -sko ~/.BREW_LIST/err3.html https://formulae.brew.sh/analytics/build-error/365d/index.html ||\
    { math_rm; ${die:?curl g error}; }
     rmdir ~/.BREW_LIST/7
  fi

  if [[ $2 = 2 ]];then
   unzip -jq ~/.BREW_LIST/keepme.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip error}; }
  fi
   unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 1 error}; }
   unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 2 error}; }
   export Perl_B=$(CO=$(command -v brew);echo ${CO%/bin/brew})
perl<<"EOF"
   $MY_HOME = -d "$ENV{'Perl_B'}/Homebrew" ? "$ENV{'Perl_B'}/Homebrew" : $ENV{'Perl_B'};
    $VERS = 1 if -d "$MY_HOME/Library/Taps/homebrew/homebrew-cask-versions";
     $FDIR = 1 if -d "$MY_HOME/Library/Taps/homebrew/homebrew-cask-fonts";

   opendir $dir1,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-fonts-master/Casks" or die " DIR1 $!\n";
    for $hand1( readdir($dir1) ){ next if $hand1 =~ /^\./;
      $hand1 =~ s/(.+)\.rb$/$1/;
       if( $FDIR ){
        push @file1,"$hand1\n";
       }else{ $i1 = 1;
        push @file1,"homebrew/cask-fonts/$hand1\n";
       }
   }
   closedir $dir1;
    @file1 = sort @file1;
   opendir $dir2,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-versions-master/Casks" or die " DIR2 $!\n";
    for $hand2( readdir($dir2) ){ next if $hand2 =~ /^\./;
      $hand2 =~ s/(.+)\.rb$/$1/;
       if( $VERS ){
        push @file2,"$hand2\n";
       }else{ $i2 = 1;
        push @file2,"homebrew/cask-versions/$hand2\n";
       }
    }
   closedir $dir2;
    @file2 = sort @file2;

   ( $i1 and $i2 ) ? push @file,"3\n",@file1,@file2 :
    $i1 ? push @file,"4\n1\n",@file2,@file1 :
    $i2 ? push @file,"5\n0\n",@file1,@file2 :
          push @file,"6\n0\n",@file1,"1\n",@file2;

   open $FILE1,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die " TAP FILE $!\n";
    print $FILE1 @file;
   close $FILE1;
  rmdir "$ENV{'HOME'}/.BREW_LIST/8";
EOF
  (( $? != 0 )) && math_rm 1 && ${die:?perl 1 error}

  if [[ $2 = 1 ]];then
perl<<"EOF"
   open $FILE2,'<',"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html" or die " FILE2 $!\n";
    while($brew=<$FILE2>){
     if( $brew =~ s|^\s*<td><a href[^>]+>(.+)</a></td>\n|$1| ){
      $tap1 = $brew; next;
     }elsif( not $test and $brew =~ s|^\s*<td>(.+)</td>\n|$1| ){
      $tap2 = $brew;
      $tap2 =~ s/&quot;/"/g;
      $tap2 =~ s/&amp;/&/g;
      $tap2 =~ s/&lt;/</g;
      $tap2 =~ s/&gt;/>/g;
      $test = 1; next;
     }elsif( $test and $brew =~ s|^\s*<td>(.+)</td>\n|$1| ){
      $tap3 = $brew;
      $test = 0;
     }
       push @ANA,$tap1 if $tap1;
      push @file4,"$tap1\t$tap3\t$tap2\n" if $tap1;
     $tap1 = $tap2 = $tap3 = '';
    }
   close $FILE2;
   open $FILE3,'>',"$ENV{'HOME'}/.BREW_LIST/cask.txt" or die " FILE5 $!\n";
    print $FILE3 @file4;
   close $FILE3;

   local $/;
  open $dir1,'<',"$ENV{'HOME'}/.BREW_LIST/cna1.html" or die " cna1 $!\n";
   $an1 = <$dir1>; close $dir1;
  @an1 = $an1 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i1=0;$i1<@an1;$i1+=2){ $HA1{$an1[$i1]} = ++$e1; $IN1{$an1[$i1]} = $an1[$i1+1] }

  open $dir2,'<',"$ENV{'HOME'}/.BREW_LIST/cna2.html" or die " cna2 $!\n";
   $an2 = <$dir2>; close $dir2;
  @an2 = $an2 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i2=0;$i2<@an2;$i2+=2){ $HA2{$an2[$i2]} = ++$e2; $IN2{$an2[$i2]} = $an2[$i2+1] }

  open $dir3,'<',"$ENV{'HOME'}/.BREW_LIST/cna3.html" or die " cna3 $!\n";
   $an3 = <$dir3>; close $dir3;
  @an3 = $an3 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i3=0;$i3<@an3;$i3+=2){ $HA3{$an3[$i3]} = ++$e3; $IN3{$an3[$i3]} = $an3[$i3+1] }

  for($in1=0;$in1<@ANA;$in1++){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN1{$ANA[$in1]} ? "\t$IN1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN2{$ANA[$in1]} ? "\t$IN2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN3{$ANA[$in1]} ? "\t$IN3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir4,'>',"$ENV{'HOME'}/.BREW_LIST/cna.txt" or die " cna4 $!\n";
   print $dir4 @fom;
  close $dir4;
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
perl<<"EOF"
   $MY_HOME = -d "$ENV{'Perl_B'}/Homebrew" ? "$ENV{'Perl_B'}/Homebrew" : $ENV{'Perl_B'};
    $LFOD = 1 if -d "$MY_HOME/Library/Taps/homebrew/homebrew-linux-fonts";

   opendir $dir3,"$ENV{'HOME'}/.BREW_LIST/homebrew-linux-fonts-master/Formula" or die " DIR3 $!\n";
    for $hand3( readdir($dir3) ){ next if $hand3 =~ /^\./;
      $hand3 =~ s/(.+)\.rb$/$1/;
       if( $LFOD ){
        push @file3,"$hand3\n";
       }else{ $i3 = 1;
        push @file3,"homebrew/linux-fonts/$hand3\n";
       }
    }
   closedir $dir3;
    @file3 = sort @file3;
     $i3 ? push @file4,"3\n",@file3 : push @file4,"4\n0\n",@file3;

   open $FILE4,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die " LFO FILE $!\n";
    print $FILE4 @file4;
   close $FILE4;
EOF
 fi

 if [[ $2 = 1 ]];then
perl<<"EOF"
  open $FILE1,'<',"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html" or die " FILE6 $!\n";
   while($brew=<$FILE1>){
    if( $brew =~ s|^\s*<td><a href[^>]+>(.+)</a></td>\n|$1| ){
     $tap1 = $brew; next;
    }elsif( not $test and $brew =~ s|^\s*<td>(.+)</td>\n|$1| ){
     $tap2 = $brew;
     $test = 1; next;
    }elsif( $test and $brew =~ s|^\s*<td>(.+)</td>\n|$1| ){
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
   open $FILE2,'>',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE7 $!\n";
    print $FILE2 @file1;
   close $FILE2;

   local $/;
  open $dir1,'<',"$ENV{'HOME'}/.BREW_LIST/ana1.html" or die " ana1 $!\n";
   $an1 = <$dir1>; close $dir1;
  @an1 = $an1 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i1=0;$i1<@an1;$i1+=2){ $HA1{$an1[$i1]} = ++$e1; $IN1{$an1[$i1]} = $an1[$i1+1] }

  open $dir2,'<',"$ENV{'HOME'}/.BREW_LIST/ana2.html" or die " ana2 $!\n";
   $an2 = <$dir2>; close $dir2;
  @an2 = $an2 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i2=0;$i2<@an2;$i2+=2){ $HA2{$an2[$i2]} = ++$e2; $IN2{$an2[$i2]} = $an2[$i2+1] }

  open $dir3,'<',"$ENV{'HOME'}/.BREW_LIST/ana3.html" or die " ana3 $!\n";
   $an3 = <$dir3>; close $dir3;
  @an3 = $an3 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i3=0;$i3<@an3;$i3+=2){ $HA3{$an3[$i3]} = ++$e3; $IN3{$an3[$i3]} = $an3[$i3+1] }

  open $dir4,'<',"$ENV{'HOME'}/.BREW_LIST/req1.html" or die " req1 $!\n";
   $an4 = <$dir4>; close $dir4;
  @an4 = $an4 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i4=0;$i4<@an4;$i4+=2){ $HA4{$an4[$i4]} = ++$e4; $EQ1{$an4[$i4]} = $an4[$i4+1] }

  open $dir5,'<',"$ENV{'HOME'}/.BREW_LIST/req2.html" or die " req2 $!\n";
   $an5 = <$dir5>; close $dir5;
  @an5 = $an5 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i5=0;$i5<@an5;$i5+=2){ $HA5{$an5[$i5]} = ++$e5; $EQ2{$an5[$i5]} = $an5[$i5+1] }

  open $dir6,'<',"$ENV{'HOME'}/.BREW_LIST/req3.html" or die " req3 $!\n";
   $an6 = <$dir6>; close $dir6;
  @an6 = $an6 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i6=0;$i6<@an6;$i6+=2){ $HA6{$an6[$i6]} = ++$e6; $EQ3{$an6[$i6]} = $an6[$i6+1] }

  open $dir7,'<',"$ENV{'HOME'}/.BREW_LIST/err1.html" or die " err1 $!\n";
   $an7 = <$dir7>; close $dir7;
  @an7 = $an7 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i7=0;$i7<@an7;$i7+=2){ $HA7{$an7[$i7]} = ++$e7; $ER1{$an7[$i7]} = $an7[$i7+1] }

  open $dir8,'<',"$ENV{'HOME'}/.BREW_LIST/err2.html" or die " err2 $!\n";
   $an8 = <$dir8>; close $dir8;
  @an8 = $an8 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i8=0;$i8<@an8;$i8+=2){ $HA8{$an8[$i8]} = ++$e8; $ER2{$an8[$i8]} = $an8[$i8+1] }

  open $dir9,'<',"$ENV{'HOME'}/.BREW_LIST/err3.html" or die " err3 $!\n";
   $an9 = <$dir9>; close $dir9;
  @an9 = $an9 =~ m|<td><a[^>]+><code>([^<]+)</code></a></td>[^<]+<td[^>]+>([^<]+)</td>|g;
   for($i9=0;$i9<@an9;$i9+=2){ $HA9{$an9[$i9]} = ++$e9; $ER3{$an9[$i9]} = $an9[$i9+1] }

  for($in1=0;$in1<@ANA;$in1++){
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
  open $dirs,'>',"$ENV{'HOME'}/.BREW_LIST/ana.txt" or die " ana4 $!\n";
   print $dirs @fom;
  close $dirs;
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
