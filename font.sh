#!/bin/bash

NAME=`uname`
if [[ $NAME = Darwin ]];then 
  TI1=(`date +"%Y %-m %-d"`)
 LS1=(`ls -dlT ~/.BREW_LIST/LOCK 2>/dev/null`) && \
 [[ ${TI1[0]} > ${LS1[8]} || ${TI1[1]} > ${LS1[5]} || ${TI1[2]} > ${LS1[6]} ]] && \
 rm -rf ~/.BREW_LIST/LOCK
else
  TI2=(`date +"%Y %m %d"`)
 LS2=(`ls -d --full-time ~/.BREW_LIST/LOCK 2>/dev/null`) && \
 LS2=(`echo ${LS2[5]}|sed 's/-/ /g'`) && \
 [[ ${TI2[0]} > ${LS2[0]} || ${TI2[1]} > ${LS2[1]} || ${TI2[2]} > ${LS2[2]} ]] && \
 rm -rf ~/.BREW_LIST/LOCK
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
       push @file1,"$hand1\n";
    }
   closedir $dir1;
   @file1 = sort{$a cmp $b}@file1;
    open $FILE1,'>',"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt" or die " FILE1 $!\n";
     print $FILE1 @file1;
    close $FILE1;

   opendir $dir2,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-drivers-master/Casks" or die " DIR2 $!\n";
    for my $hand2( readdir($dir2) ){ 
     next if $hand2 =~ /^\./;
      $hand2 =~ s/(.+)\.rb$/$1/;
       push @file2,"$hand2\n";
    }
   closedir $dir2;
   @file2 = sort{$a cmp $b}@file2;
    open $FILE2,'>',"$ENV{'HOME'}/.BREW_LIST/Q_DRIV.txt" or die " FILE2 $!\n";
     print $FILE2 @file2;
    close $FILE2;

   opendir $dir3,"$ENV{'HOME'}/.BREW_LIST/homebrew-cask-versions-master/Casks" or die " DIR3 $!\n";
    for my $hand3( readdir($dir3) ){ 
     next if $hand3 =~ /^\./;
      $hand3 =~ s/(.+)\.rb$/$1/;
       push @file3,"$hand3\n";
    }
   closedir $dir3;
   @file3 = sort{$a cmp $b}@file3;
    open $FILE3,'>',"$ENV{'HOME'}/.BREW_LIST/Q_VERS.txt" or die " FILE3 $!\n";
     print $FILE3 @file3;
    close $FILE3;

  open $FILE4,'<', "$ENV{'HOME'}/.BREW_LIST/Q_CASK.html" or die " FILE4 $!\n";
   while($brew=<$FILE4>){
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
  close $FILE4;
   open $FILE5,'>',"$ENV{'HOME'}/.BREW_LIST/cask.txt" or die " FILE5 $!\n";
    print $FILE5 @file4;
   close $FILE5;
EOF

else
 curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula-linux/index.html ||\
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
