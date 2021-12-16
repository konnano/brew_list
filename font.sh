#!/bin/bash
NAME=`uname`

timer_1(){
 TI2=(`echo $1|sed 's/:/ /g'`)
 LS3=(`echo $2|sed 's/:/ /g'`)
 TI2=`echo ${TI2[0]}*3600+${TI2[1]}*60+${TI2[2]}|bc`
 LS3=`echo ${LS3[0]}*3600+${LS3[1]}*60+${LS3[2]}+60|bc`
  [[ $TI2 -gt $LS3 ]] && rm -rf ~/.BREW_LIST/LOCK
}

if [[ $NAME = Darwin ]];then
 TI1=(`date +"%Y %-m %-d %T"`)
 LS1=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`) && \
 [[ ${TI1[0]} > ${LS1[8]} || ${TI1[1]} > ${LS1[5]} || ${TI1[2]} > ${LS1[6]} ]] && \
 rm -rf ~/.BREW_LIST/LOCK
  [[ $LS1 ]] && timer_1 ${TI1[3]} ${LS1[7]}
else
 TI1=(`date +"%Y %m %d %T"`)
 LS1=(`ls -d --full-time ~/.BREW_LIST/LOCK 2>/dev/null`) && \
 LS2=(`echo ${LS1[5]}|sed 's/-/ /g'`) && \
 [[ ${TI1[0]} > ${LS2[0]} || ${TI1[1]} > ${LS2[1]} || ${TI1[2]} > ${LS2[2]} ]] && \
 rm -rf ~/.BREW_LIST/LOCK
  [[ $LS1 ]] && timer_1 ${TI1[3]} ${LS1[6]}
fi

if ! mkdir ~/.BREW_LIST/LOCK 2>/dev/null;then
 exit
fi

trap '
rm -f ~/.BREW_LIST/master* ~/.BREW_LIST/*.html
rm -rf ~/.BREW_LIST/homebrew-cask-*
rm -f ~/.BREW_LIST/Q_*.txt ~/.BREW_LIST/DB
rm -rf ~/.BREW_LIST/{0..9} ~/.BREW_LIST/WAIT ~/.BREW_LIST/LOCK
exit' 1 2 3 15 20

if [[ $NAME = Darwin ]];then
  mkdir -p ~/.BREW_LIST/{0..9}
curl -sko ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html || \
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
  rmdir ~/.BREW_LIST/0
curl -sko ~/.BREW_LIST/Q_CASK.html https://formulae.brew.sh/cask/index.html || \
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
  rmdir ~/.BREW_LIST/1
curl -skLo ~/.BREW_LIST/master1.zip https://github.com/Homebrew/homebrew-cask-fonts/archive/master.zip || \
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
  rmdir ~/.BREW_LIST/2
curl -skLo ~/.BREW_LIST/master2.zip https://github.com/Homebrew/homebrew-cask-drivers/archive/master.zip || \
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
  rmdir ~/.BREW_LIST/3
curl -skLo ~/.BREW_LIST/master3.zip https://github.com/Homebrew/homebrew-cask-versions/archive/master.zip || \
 { rm -rf ~/.BREW_LIST/LOCK; exit; }
  rmdir ~/.BREW_LIST/4

/usr/bin/unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST || \
 { rm -rf ~/.BREW_LIST/master* ~/.BREW_LIST/homebrew-cask* ~/.BREW_LIST/LOCK; exit; }
/usr/bin/unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST || \
 { rm -rf ~/.BREW_LIST/master* ~/.BREW_LIST/homebrew-cask* ~/.BREW_LIST/LOCK; exit; }
/usr/bin/unzip -q ~/.BREW_LIST/master3.zip -d ~/.BREW_LIST || \
 { rm -rf ~/.BREW_LIST/master* ~/.BREW_LIST/homebrew-cask* ~/.BREW_LIST/LOCK; exit; }
  rmdir ~/.BREW_LIST/5

perl<<"EOF"
   opendir $dir1,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-fonts-master/Casks" or die " DIR1 $!\n";
    for $hand1( readdir($dir1) ){ 
     next if $hand1 =~ /^\./;
      $hand1 =~ s/(.+)\.rb$/$1/;
       if( -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts' ){
        push @file1,"$hand1\n";
       }else{ $i1 = 1;
        push @file1,"homebrew/cask-fonts/$hand1\n";
       }
    }
   closedir $dir1;
    @file1 = sort{$a cmp $b}@file1;

   opendir $dir2,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-drivers-master/Casks" or die " DIR2 $!\n";
    for my $hand2( readdir($dir2) ){ 
     next if $hand2 =~ /^\./;
      $hand2 =~ s/(.+)\.rb$/$1/;
       if( -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers' ){
        push @file2,"$hand2\n";
       }else{ $i2 = 1;
        push @file2,"homebrew/cask-drivers/$hand2\n";
       }
    }
   closedir $dir2;
    @file2 = sort{$a cmp $b}@file2;

   opendir $dir3,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-versions-master/Casks" or die " DIR3 $!\n";
    for my $hand3( readdir($dir3) ){ 
     next if $hand3 =~ /^\./;
      $hand3 =~ s/(.+)\.rb$/$1/;
       if( -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-versions' ){
        push @file3,"$hand3\n";
       }else{ $i3 = 1;
        push @file3,"homebrew/cask-versions/$hand3\n";
       }
    }
   closedir $dir3;
    @file3 = sort{$a cmp $b}@file3;

   ( $i1 and $i2 and $i3 ) ? push @file,"#\n",@file1,@file2,@file3 :
   ( $i1 and $i2 ) ? push @file,"3\n2\n",@file3,@file1,@file2 :
   ( $i1 and $i3 ) ? push @file,"4\n1\n",@file2,@file1,@file3 :
   ( $i2 and $i3 ) ? push @file,"5\n0\n",@file1,@file2,@file3 :
   ( $i1 ) ? push @file,"6\n1\n",@file2,"2\n",@file3,@file1 :
   ( $i2 ) ? push @file,"7\n0\n",@file1,"2\n",@file3,@file2 :
   ( $i3 ) ? push @file,"8\n0\n",@file1,"1\n",@file2,@file3 :
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

else
 curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html ||\
  { rm -rf ~/.BREW_LIST/LOCK; exit; }
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

 rm -rf ~/.BREW_LIST/6
 rm -f ~/.BREW_LIST/DBM.*
 perl ~/.BREW_LIST/tie.pl

 rm -f ~/.BREW_LIST/DB
if [[ $NAME = Darwin ]];then
 ln -s ~/.BREW_LIST/DBM.db ~/.BREW_LIST/DB
else
 ln -s ~/.BREW_LIST/DBM.dir ~/.BREW_LIST/DB
fi

rm -f ~/.BREW_LIST/master* ~/.BREW_LIST/*.html
rm -rf ~/.BREW_LIST/homebrew-cask-*
rm -rf ~/.BREW_LIST/{0..9} ~/.BREW_LIST/WAIT ~/.BREW_LIST/LOCK
