use strict;
use warnings;

# Cask フォントを QuickLook 表示します、fzfかpecoかpercolが必要です
# パッケージフォントに対応しません、単体フォントのみ、試作品です
# perl font_pre.pl|read i 気に入ったら brew install $i でインストールできます(zsh)

$SIG{'HUP'} = $SIG{'TERM'} = $SIG{'PIPE'} = 'exit_1';
sub exit_1{ unlink './Array.txt'; unlink './master.ttf'; exit; }

my $CPU = `sysctl machdep.cpu.brand_string`;
$CPU = $CPU =~ /Apple\s+M1/ ? 'arm' : 'intel';
my $dir = $CPU eq 'arm' ?
 '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks' :
 '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks';

my( %HA,@AN,$VER ); 
opendir my $FONT,$dir or die " FONT $!\n";
 for my $com(readdir($FONT)){
  next if $com eq '.' or $com eq '..';
  open my $font,"$dir/$com" or die " File $!";
   my( $name ) = $com =~ /(.+)\.rb/;
   while(my $read = <$font>){
    $VER = $1 if $read =~ /\s*version\s+"([^"]+)".*/;
     if( $read =~ s/^\s*url\s+"([^"]+(?:ttf|otf))".*\n/$1/ ){
      $read =~ s/\Q#{version}\E/$VER/;
       $HA{$name} = $read;
        push @AN,"$name\n";
     }
   }
  close $font;
 }
closedir $FONT;

my $fzf = `if type fzf >/dev/null 2>&1;then
echo fzf
elif type peco >/dev/null 2>&1;then
echo peco
elif type percol >/dev/null 2>&1;then
echo percol
else
exit
fi`;
exit unless $fzf;

die " exisit master.ttf\n" if -f 'master.ttf';
 die " exisit Array.txt\n" if -f 'Array.txt';

 @AN = sort{$a cmp $b}@AN;
open my $FI,'>','Array.txt' or die " Array $!\n";
 print $FI @AN;
close $FI;

chomp( my $an = `cat Array.txt|$fzf` );
 print" $an\n" if $an;
$HA{$an} ?
 system("curl -sLo './master.ttf' $HA{$an} 2>/dev/null
  sleep 0.1; qlmanage -p './master.ttf' >& /dev/null
   ps x|grep [q]uicklookd|awk 'END {print \$1}'|xargs kill -KILL") :
    unlink './Array.txt' and exit;
unlink 'master.ttf';
 unlink 'Array.txt';
