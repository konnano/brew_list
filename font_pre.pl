use strict;
use warnings;

# Cask フォントを QuickLook で表示します、fzfかpecoかpercolが必要です
# パッケージフォントに対応しません、単体フォントのみ、表示しないのもあるので試作品です

my $CPU = `sysctl machdep.cpu.brand_string`;
my $dir = $CPU eq 'arm\?' ?
 '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks' :
 '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks';

my %HA; my @AN;
opendir my $FONT,$dir or die " FONT $!\n";
 for my $com(readdir($FONT)){
  next if $com eq '.' or $com eq '..';
  open my $font,"$dir/$com" or die " File $!";
   my( $name ) = $com =~ /(.+)\.rb/;
   while(my $read = <$font>){
    $read =~ s/^\s*url\s*"([^"]+(?:ttf|otf))".*\n/$1/;
     if( $read =~ /^https:/ ){
     $HA{$name} = $read;
     push @AN,"$name\n";
    }
   }
 }
closedir $FONT;

die " exisit master.ttf\n" if -f 'master.ttf';
 die " exisit Array.txt\n" if -f 'Array.txt';

 @AN = sort{$a cmp $b}@AN;
open my $FI,'>','Array.txt' or die " Array $!\n";
 print $FI @AN;
close $FI;

my $fzf = `if type fzf >/dev/null 2>&1;then
echo fzf
elif type peco >/dev/null 2>&1;then
echo peco
elif type percol >/dev/null 2>&1;then
echo percol
else
exit
fi`;

my $an = `cat Array.txt|$fzf`;
chomp $an;

print" $an\n";
system("curl -sLo master.ttf $HA{$an} 2>/dev/null");
system('qlmanage -p master.ttf >& /dev/null;rm master.ttf');
unlink 'Array.txt';
