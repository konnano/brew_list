use strict;
use warnings;

# ループで Cask フォントを QuickLook 表示します
# パッケージフォントに対応しません、単体フォントのみ、試作品です
# 終了は QuickLook で Spaceキー 親プロセス sleep 待ちで少し時間かかります

my $TIME = 6; ### 表示タイム　通信環境で設定して下さい
$SIG{'HUP'} = $SIG{'TERM'} = $SIG{'PIPE'} = $SIG{'INT'} = 'exit_1';
sub exit_1{ sleep 1; rmdir './FONT_EXIT'; unlink './master.ttf'; exit; }

my $CPU = `sysctl machdep.cpu.brand_string`;
$CPU = $CPU =~ /Apple\s+M1/ ? 'arm\?' : 'intel\?';
my $dir = $CPU eq 'arm\?' ?
 '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks' :
 '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks';

my( %HA,@AN,$VER ); 
opendir my $FONT,$dir or die " FONT $!\n";
 for my $com(readdir($FONT)){
  next if $com eq '.' or $com eq '..';
  open my $font,"$dir/$com" or die " font $!";
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

die " exisit master.ttf\n" if -f 'master.ttf';
 die " exisit FONT_EXIT\n" if -d 'FONT_EXIT';
  shuf_1(\@AN);

for my $an( @AN ){
 if( -d './FONT_EXIT' ){
  rmdir './FONT_EXIT';
   exit;
 }
  print"$an";
   chomp $an;
 my $pid = fork;
 die " Not fork : $!\n" unless defined $pid;
  if($pid){
   sleep $TIME;
    unless( -d './FONT_EXIT' ){
     system("osascript -e 'tell application \"System Events\"
             keystroke (key code 49)
             end tell'");
    }
  }else{
   my $time = time;
    ( mkdir './FONT_EXIT' and die "  \033[31mNot connected\033[37m\n" )
     if system("curl -sLo master.ttf $HA{$an}");
      system('qlmanage -p master.ttf >& /dev/null');
       ( print" wait\n" and mkdir './FONT_EXIT' ) if $TIME > time - $time;
        exit;
  }
 sleep 1;
 unlink './master.ttf';
}

sub shuf_1{
 my $arr = shift;
 for(my $i=@$arr-1 ; $i>=0; --$i){
  my $j = int( rand($i+1) );
  next if($i==$j);
  @$arr[$i,$j] = @$arr[$j,$i];
  }
}
