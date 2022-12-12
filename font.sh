#!/bin/bash
 NAME=$(uname)
[[ $1 =~ ^[01]$ ]] || ${die:?input 1 error}
[[ ! $2 || $2 =~ ^[12]$ ]] || ${die:?input 2 error}

math_rm(){ [[ $1 ]] && rm -f ~/.BREW_LIST/{master*,*.html,DBM*} || rm -f ~/.BREW_LIST/{master*,*.html}
                       rm -rf ~/.BREW_LIST/{homebrew*,{0..19},WAIT,LOCK,font2.sh,tie2.pl} ~/.JA_BREWG; }
 TI=$(date +%s)
if [[ $1 -eq 1 ]];then
 LS=$(date -r ~/.BREW_LIST/LOCK "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
 if [[ $LS ]];then
  if [[ "$NAME" = Darwin ]];then
   LS=$(( $(date -jf "%Y-%m-%d %H:%M:%S" "$LS" +%s 2>/dev/null)+60 ))
    [[ $LS && $LS -ne 60 && $TI -gt $LS ]] && math_rm
  else
   LS=$(( $(date +%s --date "$LS" 2>/dev/null)+60 ))
    [[ $LS && $LS -ne 60 && $TI -gt $LS ]] && math_rm
  fi
 fi
fi

if [[ $2 ]];then
 if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
   exit 2
 fi
 trap 'math_rm 1; exit 1' 1 2 3 15

  LS1=$(date -r ~/.JA_BREW/ja_brew.txt "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
 if [[ $LS1 ]];then
  if [[ "$NAME" = Darwin ]];then
   LS1=$(( $(date -jf "%Y-%m-%d %H:%M:%S" "$LS1" +%s 2>/dev/null)+60*60*24 ))
  else
   LS1=$(( $(date +%s --date "$LS1" 2>/dev/null)+60*60*24 ))
  fi
  if [[ $TI -gt $LS1 ]];then
   git clone -q https://github.com/konnano/JA_BREW ~/.JA_BREWG 2>/dev/null || { math_rm; ${die:?git clone error}; }
    cp ~/.JA_BREWG/* ~/.JA_BREW
     rm -rf ~/.JA_BREWG ~/.JA_BREW/.git
    [[ "$NAME" = Linux ]] && rm ~/.JA_BREW/ja_cask.txt ~/.JA_BREW/ja_tap.txt
  fi
 fi

 if [[ "$NAME" = Darwin ]];then
  if [[ $2 -eq 1 ]];then
    mkdir -p ~/.BREW_LIST/{0..19}
   curl -sko ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
    { math_rm; ${die:?curl 1 error}; }
   curl -sko ~/.BREW_LIST/Q_CASK.html https://formulae.brew.sh/cask/index.html ||\
    { math_rm; ${die:?curl 2 error}; }
     rmdir ~/.BREW_LIST/0
   curl -skLo ~/.BREW_LIST/master1.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip ||\
    { math_rm; ${die:?curl 3 error}; }
     rmdir ~/.BREW_LIST/1
   curl -skLo ~/.BREW_LIST/master2.zip https://github.com/Homebrew/homebrew-cask-drivers/archive/master.zip ||\
    { math_rm; ${die:?curl 4 error}; }
     rmdir ~/.BREW_LIST/2
   curl -skLo ~/.BREW_LIST/master3.zip https://github.com/Homebrew/homebrew-cask-versions/archive/master.zip ||\
    { math_rm; ${die:?curl 5 error}; }
   zip -q ~/.BREW_LIST/keepme.zip ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ~/.BREW_LIST/master3.zip ||\
    { rm -f keepme.zip; math_rm; ${die:?zip error}; }
     rmdir ~/.BREW_LIST/3
   curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics/install/30d/index.html ||\
    { math_rm; ${die:?curl 6 error}; }
   curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics/install/90d/index.html ||\
    { math_rm; ${die:?curl 7 error}; }
     rmdir ~/.BREW_LIST/4
   curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics/install/365d/index.html ||\
    { math_rm; ${die:?curl 8 error}; }
   curl -sko ~/.BREW_LIST/cna1.html https://formulae.brew.sh/analytics/cask-install/30d/index.html ||\
    { math_rm; ${die:?curl 9 error}; }
     rmdir ~/.BREW_LIST/5
   curl -sko ~/.BREW_LIST/cna2.html https://formulae.brew.sh/analytics/cask-install/90d/index.html ||\
    { math_rm; ${die:?curl a error}; }
   curl -sko ~/.BREW_LIST/cna3.html https://formulae.brew.sh/analytics/cask-install/365d/index.html ||\
    { math_rm; ${die:?curl b error}; }
     rmdir ~/.BREW_LIST/6
   curl -sko ~/.BREW_LIST/err1.html https://formulae.brew.sh/analytics/build-error/30d/index.html ||\
    { math_rm; ${die:?curl c error}; }
   curl -sko ~/.BREW_LIST/err2.html https://formulae.brew.sh/analytics/build-error/90d/index.html ||\
    { math_rm; ${die:?curl d error}; }
   curl -sko ~/.BREW_LIST/err3.html https://formulae.brew.sh/analytics/build-error/365d/index.html ||\
    { math_rm; ${die:?curl e error}; }
     rmdir ~/.BREW_LIST/7
  fi

  if [[ $2 -eq 2 ]];then
   unzip -qj ~/.BREW_LIST/keepme.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip error}; }
  fi

   unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 1 error}; }
   unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 2 error}; }
   unzip -q ~/.BREW_LIST/master3.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 3 error}; }

perl<<"EOF"
   if( `uname -m` =~ /x86_64/ and -d '/usr/local/Homebrew' ){
    $VERS = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-versions';
     $DDIR = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
      $FDIR = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
   }else{
    chomp( $MY_BREW = `dirname \$(dirname \$(which brew) 2>/dev/null) 2>/dev/null` );
    $VERS = 1 if -d "$MY_BREW/Library/Taps/homebrew/homebrew-cask-versions";
     $DDIR = 1 if -d "$MY_BREW/Library/Taps/homebrew/homebrew-cask-drivers";
      $FDIR = 1 if -d "$MY_BREW/Library/Taps/homebrew/homebrew-cask-fonts";
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
    @file1 = sort @file1;

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
    @file2 = sort @file2;

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
    @file3 = sort @file3;

   ( $i1 and $i2 and $i3 ) ? push @file,"#\n",@file1,@file2,@file3 :
   ( $i1 and $i2 ) ? push @file,"3\n2\n",@file3,@file1,@file2 :
   ( $i1 and $i3 ) ? push @file,"4\n1\n",@file2,@file1,@file3 :
   ( $i2 and $i3 ) ? push @file,"5\n0\n",@file1,@file2,@file3 :
    $i1 ? push @file,"6\n1\n",@file2,"2\n",@file3,@file1 :
    $i2 ? push @file,"7\n0\n",@file1,"2\n",@file3,@file2 :
    $i3 ? push @file,"8\n0\n",@file1,"1\n",@file2,@file3 :
          push @file,"9\n0\n",@file1,"1\n",@file2,"2\n",@file3;

   open $FILE1,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die " TAP FILE $!\n";
    print $FILE1 @file;
   close $FILE1;
  rmdir "$ENV{'HOME'}/.BREW_LIST/8"
EOF
  [[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 1 error};

  if [[ $2 -eq 1 ]];then
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

  open $dir1,'<',"$ENV{'HOME'}/.BREW_LIST/cna1.html" or die " cna1 $!\n"; $i1 = 1;
   while( $an1=<$dir1> ){
    next if $an1 =~ /\s--HEAD|\s--with/;
     $HA1{$an1} = $i1++,$AN1 = $an1 if $an1 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $IN1{$AN1} = $an1,$AN1 = 0 if $AN1 and $an1 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir1;
  open $dir2,'<',"$ENV{'HOME'}/.BREW_LIST/cna2.html" or die " cna2 $!\n"; $i2 = 1;
   while( $an2=<$dir2> ){
    next if $an2 =~ /\s--HEAD|\s--with/;
     $HA2{$an2} = $i2++,$AN2 = $an2 if $an2 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $IN2{$AN2} = $an2,$AN2 = 0 if $AN2 and $an2 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir2;
  open $dir3,'<',"$ENV{'HOME'}/.BREW_LIST/cna3.html" or die " cna3 $!\n"; $i3 = 1;
   while( $an3=<$dir3> ){
    next if $an3 =~ /\s--HEAD|\s--with/;
     $HA3{$an3} = $i3++,$AN3 = $an3 if $an3 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $IN3{$AN3} = $an3,$AN3 = 0 if $AN3 and $an3 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir3;
  for($in1=0;$in1<@ANA;$in1++){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN1{$ANA[$in1]} ? "\t$IN1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN2{$ANA[$in1]} ? "\t$IN2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN3{$ANA[$in1]} ? "\t$IN3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir4,'>',"$ENV{'HOME'}/.BREW_LIST/cna.txt" or die " ana4 $!\n";
   print $dir4 @fom;
  close $dir4;
 rmdir "$ENV{'HOME'}/.BREW_LIST/9"
EOF
  [[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 2 error};
  fi
 else
  curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html || \
   { math_rm; ${die:?curl f error}; }
 curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics-linux/install/30d/index.html ||\
   { math_rm; ${die:?curl g error}; }
 curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics-linux/install/90d/index.html ||\
   { math_rm; ${die:?curl h error}; }
 curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics-linux/install/365d/index.html ||\
   { math_rm; ${die:?curl i error}; }
 curl -sko ~/.BREW_LIST/err1.html https://formulae.brew.sh/analytics-linux/build-error/30d/index.html ||\
   { math_rm; ${die:?curl j error}; }
 curl -sko ~/.BREW_LIST/err2.html https://formulae.brew.sh/analytics-linux/build-error/90d/index.html ||\
   { math_rm; ${die:?curl k error}; }
 curl -sko ~/.BREW_LIST/err3.html https://formulae.brew.sh/analytics-linux/build-error/365d/index.html ||\
   { math_rm; ${die:?curl l error}; }
 fi

 if [[ $2 -eq 1 ]];then
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

  open $dir1,'<',"$ENV{'HOME'}/.BREW_LIST/ana1.html" or die " ana1 $!\n"; $i1 = 1;
   while( $an1=<$dir1> ){
    next if $an1 =~ /\s--HEAD|\s--with/;
     $HA1{$an1} = $i1++,$AN1 = $an1 if $an1 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $IN1{$AN1} = $an1,$AN1 = 0 if $AN1 and $an1 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir1;
  open $dir2,'<',"$ENV{'HOME'}/.BREW_LIST/ana2.html" or die " ana2 $!\n"; $i2 = 1;
   while( $an2=<$dir2> ){
    next if $an2 =~ /\s--HEAD|\s--with/;
     $HA2{$an2} = $i2++,$AN2 = $an2 if $an2 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $IN2{$AN2} = $an2,$AN2 = 0 if $AN2 and $an2 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir2;
  open $dir3,'<',"$ENV{'HOME'}/.BREW_LIST/ana3.html" or die " ana3 $!\n"; $i3 = 1;
   while( $an3=<$dir3> ){
    next if $an3 =~ /\s--HEAD|\s--with/;
     $HA3{$an3} = $i3++,$AN3 = $an3 if $an3 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $IN3{$AN3} = $an3,$AN3 = 0 if $AN3 and $an3 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir3;

  open $dir4,'<',"$ENV{'HOME'}/.BREW_LIST/err1.html" or die " ana1 $!\n"; $i1 = 1;
   while( $en1=<$dir4> ){
    next if $en1 =~ /\s--HEAD|\s--with/;
     $EN1 = $en1 if $en1 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $ER1{$EN1} = $en1,$EN1 = 0 if $EN1 and $en1 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir4;
  open $dir5,'<',"$ENV{'HOME'}/.BREW_LIST/err2.html" or die " ana2 $!\n"; $i2 = 1;
   while( $en2=<$dir5> ){
    next if $en2 =~ /\s--HEAD|\s--with/;
     $EN2 = $en2 if $en2 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $ER2{$EN2} = $en2,$EN2 = 0 if $EN2 and $en2 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir5;
  open $dir6,'<',"$ENV{'HOME'}/.BREW_LIST/err3.html" or die " ana3 $!\n"; $i3 = 1;
   while( $en3=<$dir6> ){
    next if $en3 =~ /\s--HEAD|\s--with/;
     $EN3 = $en3 if $en3 =~ s|^\s*<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
      $ER3{$EN3} = $en3,$EN3 = 0 if $EN3 and $en3 =~ s|^\s*<td[^>]+>(.+)</td>\n|$1|;
   }
  close $dir6;

  for($in1=0;$in1<@ANA;$in1++){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN1{$ANA[$in1]} ? "\t$IN1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN2{$ANA[$in1]} ? "\t$IN2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $IN3{$ANA[$in1]} ? "\t$IN3{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $ER1{$ANA[$in1]} ? "\t$ER1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $ER2{$ANA[$in1]} ? "\t$ER2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $ER3{$ANA[$in1]} ? "\t$ER3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir4,'>',"$ENV{'HOME'}/.BREW_LIST/ana.txt" or die " ana4 $!\n";
   print $dir4 @fom;
  close $dir4;
EOF
 [[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 3 error};

  rm -rf  ~/.BREW_LIST/10
  perl ~/.BREW_LIST/tie.pl || { math_rm 1 && ${die:?perl tie1 error}; }

  if [[ "$NAME" = Darwin ]];then
   mv ~/.BREW_LIST/DBMG.db ~/.BREW_LIST/DBM.db
  else
   mv ~/.BREW_LIST/DBMG.dir ~/.BREW_LIST/DBM.dir
   mv ~/.BREW_LIST/DBMG.pag ~/.BREW_LIST/DBM.pag
  fi
 fi
  if [[ $2 -eq 2 ]];then
   perl ~/.BREW_LIST/tie.pl 1 || { math_rm 1 && ${die:?perl tie2 error}; }
  fi
rm -rf ~/.BREW_LIST/19
 math_rm
fi
