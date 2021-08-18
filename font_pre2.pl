use strict;
use warnings;

# ループで Cask フォントを QuickLook 表示します、終了は Ctl+c
# パッケージフォントに対応しません、単体フォントのみ、試作品です
my $TIME = 6; ### 表示タイム　通信環境で設定して下さい

my $CPU = `sysctl machdep.cpu.brand_string`;
$CPU = $CPU =~ /Apple\s+M1/ ? 'arm\?' : 'intel\?';
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
shuf_1(\@AN);

for my $an( @AN ){
 print"$an";
  chomp $an;
 my $pid = fork;
 die " Not fork : $!\n" unless defined $pid;
  if($pid){
   sleep $TIME;
    system("osascript -e 'tell application \"System Events\"
            keystroke (key code 49)
            end tell'");
  }else{
     system("curl -sLo master.ttf $HA{$an} 2>/dev/null");
     system('qlmanage -p master.ttf >& /dev/null');
     exit;
  }
 unlink 'master.ttf';
 sleep 1;
}

sub shuf_1{
 my $arr = shift;
 for(my $i=@$arr-1 ; $i>=0; --$i){
  my $j = int( rand($i+1) );
  next if($i==$j);
  @$arr[$i,$j] = @$arr[$j,$i];
  }
}

