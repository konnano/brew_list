#!/usr/bin/env perl
use strict;
use warnings;
use Encode;
use NDBM_File;
use Fcntl ':DEFAULT';
my( $OS_Version,$Locale,%JA );

MAIN:{
 my $HOME = "$ENV{'HOME'}/.BREW_LIST";
 my $re  = { 'LEN1'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,'UP'=>0,'ARY'=>[],'UNI'=>[],
             'CEL'=>'/usr/local/Cellar','BIN'=>'/usr/local/opt',
             'HOME'=>$HOME,'TXT'=>"$HOME/brew.txt",
             'TAP_S'=>'/usr/local/Homebrew/Library/Taps',
             'CAN'=>"$HOME/ana.txt",'SPA'=>' 'x9 };

 my $ref = { 'LEN1'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,'UP'=>0,'ARY'=>[],
             'CEL'=>'/usr/local/Caskroom','LEN2'=>1,'LEN3'=>1,'LEN4'=>1,
             'HOME'=>$HOME,'TXT'=>"$HOME/cask.txt",'CAN'=>"$HOME/cna.txt",
             'Q_TAP'=>"$HOME/Q_TAP.txt",'SPA'=>' 'x9 };

 $^O eq 'darwin' ? $re->{'MAC'} = $ref->{'MAC'}= 1 :
  $^O eq 'linux' ? $re->{'LIN'} = 1 : exit;
   chomp( my $MY_BREW = `which brew` ) or die " \033[31mNot installed HOME BREW\033[00m\n";
 my @AR = @ARGV; my $name;
  Died_1() unless $AR[0];
 if( $AR[0] eq '-l' ){      $name = $re;  $re->{'LIST'}  = 1;
 }elsif( $AR[0] eq '-i'  ){ $name = $re;  $re->{'PRINT'} = 1;
 }elsif( $AR[0] eq '-c'  ){ $name = $ref; $ref->{'LIST'} = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-ci' ){ $name = $ref; $ref->{'PRINT'}= 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-cd' ){ $name = $ref; $ref->{'DEP'}  = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-ct' ){ $name = $ref; $ref->{'LIST'} = $ref->{'TAP'} = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-lx' ){ $name = $re;  $re->{'LIST'}  = $re->{'LINK'} = $re->{'MAC'} ? 1 : 2;
 }elsif( $AR[0] eq '-lb' ){ $name = $re;  $re->{'LIST'}  = $re->{'LINK'} = 3;
 }elsif( $AR[0] eq '-cx' ){ $name = $ref; $ref->{'LIST'} = $ref->{'LINK'}= 4; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-cs' ){ $name = $ref; $ref->{'LIST'} = $ref->{'LINK'}= 5; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-in' ){ $re->{'LIST'} = $re->{'INF'} = $re->{'LINK'} =
                            $ref->{'LIST'}= $ref->{'INF'}= $ref->{'LINK'}= 6;
 }elsif( $AR[0] eq '-de' ){ $re->{'INF'}  = $re->{'LINK'} = $ref->{'INF'} = $ref->{'LINK'}= 7;
                            $ref->{'DEL'} = $re->{'DEL'} = 1;
 }elsif( $AR[0] eq '-t'  ){ $name = $re;  $re->{'INF'} = $re->{'TREE'}= 1;
 }elsif( $AR[0] eq '-tt' ){ $name = $re;  $re->{'INF'} = $re->{'TREE'}= $re->{'TT'} = 1;
 }elsif( $AR[0] eq '-d'  ){ $name = $re;  $re->{'INF'} = $re->{'DEL'} = 1;
 }elsif( $AR[0] eq '-dd' ){ $name = $re;  $re->{'INF'} = $re->{'DEL'} = $re->{'DD'} = 1;
 }elsif( $AR[0] eq '-ddd'){ $name = $re;  $re->{'INF'} = $re->{'DEL'} = $re->{'DD'} = $re->{'DDD'} = 1;
 }elsif( $AR[0] eq '-ac' ){ $name = $ref; $ref->{'ANA'} = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-ai' ){ $name = $re;  $re->{'ANA'}  = 1;
 }elsif( $AR[0] eq '-u'  ){ $name = $re;  $re->{'USE'}  = 1;
 }elsif( $AR[0] eq '-ua' ){ $name = $re;  $re->{'USES'} = 1;
 }elsif( $AR[0] eq '-ul' ){ $name = $re;  $re->{'uses'} = 1;
 }elsif( $AR[0] eq '-ud' ){ $name = $re;  $re->{'deps'} = 1;
 }elsif( $AR[0] eq '-co' ){ $name = $re;  $re->{'COM'}  = 1;
 }elsif( $AR[0] eq '-new'){ $name = $re;  $re->{'NEW'}  = 1;
 }elsif( $AR[0] eq '-is' ){ $name = $re;  $re->{'IS'}   = 1;
 }elsif( $AR[0] eq '-o'  ){ $re->{'DAT'}= $ref->{'DAT'} = 1;
 }elsif( $AR[0] eq '-g'  ){ $re->{'TOP'}= $ref->{'TOP'} = 1;
 }elsif( $AR[0] eq  '-'  ){ $re->{'BL'} = $ref->{'BL'}  = 1;
 }elsif( $AR[0] eq '-s'  ){ $re->{'S_OPT'} = 1;
 }elsif( $AR[0] eq '-JA' ){ $re->{'JA'} = 1;
 }else{ system "$MY_BREW @AR"; die " \033[33mNot brew argument\033[00m\n" if $?; exit;
 }
  my $UNAME = `uname -m`;
 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
    $re->{'TAP_S'} = '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps';
     $OS_Version = $UNAME =~ /x86_64/ ? 'Linux' : $UNAME =~ /arm64/ ? 'LinuxM1' : 'Linux32';
 }else{
  $OS_Version =  `sw_vers -productVersion`;
   $OS_Version =~ s/^(10\.1[0-5]).*\n/$1/;
    $OS_Version =~ s/^10\.9.*\n/10.09/;
     $OS_Version =~ s/^11.+\n/11.0/;
      $OS_Version =~ s/^12.+\n/12.0/;
  die " Use Tiger Brew\n" if $OS_Version =~ /^10\.[0-8]($|\.)/;
   $OS_Version = "${OS_Version}M1" if $UNAME =~ /arm64/;
  $ref->{'VERS'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-versions/Casks';
   $ref->{'DDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers/Casks';
    $ref->{'FDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks';
 }

 if( $re->{'MAC'} and ( $UNAME =~ /arm64/ or not -d $re->{'CEL'} ) ){
  $re->{'CEL'} = '/opt/homebrew/Cellar';
   $re->{'BIN'} = '/opt/homebrew/opt';
    $ref->{'CEL'} = '/opt/homebrew/Caskroom';
     $re->{'TAP_S'} = '/opt/homebrew/Library/Taps';
  $ref->{'VERS'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-versions/Casks';
   $ref->{'DDIR'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-drivers/Casks';
    $ref->{'FDIR'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts/Casks';
 }
   die " \033[31mNot installed HOME BREW\033[00m\n" unless -d $re->{'CEL'};
   $Locale = `printf \$LC_ALL \$LC_CTYPE \$LANG 2>/dev/null` =~ /utf8$|utf-8$/i;
  if( $re->{'JA'} ){
   die " \033[31mNot connected\033[00m\n"
    if system 'curl -k https://formulae.brew.sh/formula >/dev/null 2>&1';
   die " Not UTF-8 Locale\n" unless $Locale;
    -d "$ENV{'HOME'}/.JA_BREW" ?
    print" exists ~/.JA_BREW\n" : system 'git clone https://github.com/konnano/JA_BREW ~/.JA_BREW'; exit;
  }elsif( -d "$ENV{'HOME'}/.JA_BREW" and $AR[1] and $AR[1] eq 'EN' ){
   $name ? $name->{'EN'} = 1 : ( not $name ) ? $re->{'EN'} = $ref->{'EN'} = 1 : 0;
    $AR[1] = $AR[2] ? $AR[2] : 0; $AR[2] = $AR[3] ? $AR[3] : 0;
  }elsif( not $Locale ){
   $name ? $name->{'EN'} = 1 : ( not $name ) ? $re->{'EN'} = $ref->{'EN'} = 1 : 0;
  }
  unless( not $ref->{'TAP'} or $ref->{'FDIR'} or $ref->{'DDIR'} or $ref->{'VERS'} ){
   print " not exists cask tap\n homebrew/cask-fonts\n homebrew/cask-drivers\n homebrew/cask-versions\n";
    File_1( $ref );
  }

  if( $AR[1] and $AR[1] =~ m[/.*(\\Q|\\E).*/]i ){
   $AR[1] !~ /.*\\Q.+\\E.*/ ? die " nothing in regex\n" : $AR[1] =~ s|/(.*)\\Q(.+)\\E(.*)/|/$1\Q$2\E$3/|;
  }elsif( $AR[1] and my( $reg )= $AR[1] =~ m|^/(.+)/$| ){
   die " nothing in regex\n" if system "perl -e '$AR[1]=~/$reg/' 2>/dev/null";
  }
   $name->{'KEN'} = 1 if $name and $AR[2] and $AR[2] eq '.';
    $ref->{'BIN'} = $re->{'BIN'} if $ref->{'DEP'};
     $re->{'CELS'} = $ref->{'CEL'} if $re->{'MAC'} and
      ( $re->{'TOP'} or $re->{'USE'} or $re->{'DEL'} or $re->{'TREE'} or $re->{'uses'} or $re->{'deps'} );

  if( $re->{'NEW'} or $re->{'MAC'} and not -f "$re->{'HOME'}/DBM.db" or
      $re->{'LIN'} and not -f "$re->{'HOME'}/DBM.pag" or not -d $re->{'HOME'} ){
       $re->{'NEW'}++; Init_1( $re );
  }elsif( $re->{'INF'} ){ $re->{'INF'} = $ref->{'INF'} = $AR[1] ? lc $AR[1] : Died_1();
  }elsif( $re->{'IS'} and $AR[1] ){ $re->{'INF'} = $AR[1];
  }elsif( $re->{'COM'} or $re->{'S_OPT'} or $AR[1] and $name and ( $name->{'LIST'} or $name->{'ANA'} ) ){
   $re->{'STDI'} = $name->{'KEN'} ? $AR[1] : $AR[1] ? lc $AR[1] : Died_1();
    $name->{'L_OPT'} = ( $name->{'KEN'} and -d "$ENV{'HOME'}/.JA_BREW" ) ? decode 'utf-8',$re->{'STDI'} :
     $name->{'KEN'} ? $re->{'STDI'} : $re->{'STDI'} =~ s|^/(.+)/$|$1| ? $re->{'STDI'} : "\Q$re->{'STDI'}\E";
      $re->{'S_OPT'} = $ref->{'S_OPT'} = $name->{'L_OPT'} if $re->{'S_OPT'};
  }elsif( $re->{'USE'} ){
   $re->{'USE'} = $AR[1] ? lc $AR[1] : Died_1();
  }elsif( $re->{'USES'} ){
   $re->{'USE'} = $re->{'USES'} = $AR[1] ? lc $AR[1] : Died_1();
  }
 Fork_1( $name,$re,$ref );
}

sub Fork_1{
my( $name,$re,$ref ) = @_;
 if( $re->{'LIN'} ){
  Init_1( $re ); Format_1( $re );
 }elsif( not $name or $re->{'S_OPT'} ){
  my $pid = fork;
  die " Not fork : $!\n" unless defined $pid;
   if( $pid ){
    $ref->{'PID'} = $pid;
    Init_1( $ref );
   }else{
    Init_1( $re );
   }
   if( $pid ){
    waitpid $pid,0;
    Format_1( $ref );
   }else{
    Format_1( $re ); exit;
   }
 }else{ Init_1( $name ); Format_1( $name );
 }
}

sub Died_1{
 my $LC = `printf \$LC_ALL \$LC_CTYPE \$LANG 2>/dev/null` =~ /ja_JP/;
  my $Lang = ( $LC and -d "$ENV{'HOME'}/.JA_BREW" ) ?
 "\n  # English display in Japanese version is argument EN
  # Uninstall rm -rf ~/.BREW_LIST ~/.JA_BREW ; Then brew uninstall brew_list\n" :
  ( $LC and not -d "$ENV{'HOME'}/.JA_BREW" ) ?
 "\n  # Japanese Language -JA option
  # Uninstall rm -rf ~/.BREW_LIST ~/.JA_BREW ; Then brew uninstall brew_list\n" :
 "\n  # Uninstall rm -rf ~/.BREW_LIST ; Then brew uninstall brew_list\n";

 die " Enhanced brew list : version 1.11_4\n   Option\n  -new\t:  creat new cache
  -l\t:  formula list : First argument Formula search : Second argument '.' Full-text search
  -i\t:  instaled formula list\n  -\t:  brew list command\n  -lb\t:  bottled install formula list
  -lx\t:  can't install formula list\n  -s\t:  type search formula name\n  -o\t:  brew outdated
  -co\t:  formula library display\n  -in\t:  formula require formula list
  -t\t:  formula require formula, display tree\n  -tt\t:  only require formula, display tree
  -u\t:  formula depend on formula\n  -ua\t:  formula depend on formula , all
  -ul\t:  formula depend on formula , item count\n  -ud\t:  formula depend on formula , list
  -g\t:  Independent Formula\n  -de\t:  uninstalled, not require formula
  -d\t:  uninstalled, not require formula, display tree
  -dd\t:  uninstalled, only not require formula, display tree and order\n  -ddd\t:  All deps uninstall
  -is\t:  Display in order of size\n  -g\t:  Independent formula
  -ai\t:  Analytics Data ( not argument or argument 1,2 )\n   Only mac : Cask
  -c\t:  cask list : First argument Formula search : Second argument '.' Full-text search
  -ct\t:  cask tap list : First argument Formula search : Second argument '.' Full-text search
  -ci\t:  instaled cask list\n  -cx\t:  can't install cask list\n  -cs\t:  some name cask and formula
  -cd\t:  Display required list casks\n  -ac\t:  Analytics Data ( not argument or argument 1,2 )
  $Lang";
}

sub Init_1{
my( $re,$list ) = @_;
 if( $re->{'NEW'} ){
  die " \033[31mNot connected\033[00m\n"
   if system 'curl -k https://formulae.brew.sh/formula >/dev/null 2>&1';
    system '~/.BREW_LIST/font.sh 1' if -d "$re->{'HOME'}/LOCK";
     print STDERR " exist \033[31mLOCK\033[00m\n" if -d "$re->{'HOME'}/LOCK";
  $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'TERM'} = sub{ my( $not ) = Doc_1(); die "\x1B[?25h$not" };
   Wait_1( $re );
 }
  if( ( not $re->{'TREE'} or $re->{'TREE'} < 2 ) and not $re->{'ANA'} ){
   DB_1( $re );
    DB_2( $re ) unless $re->{'BL'} or $re->{'S_OPT'} or $re->{'COM'};
  }
   Dele_1( $re ) if $re->{'DEL'} and $re->{'DEL'} < 2;
    Info_1( $re ) if $re->{'INF'};
     return if $re->{'TREE'};
 unless( $re->{'ANA'} or $re->{'COM'} or $re->{'uses'} or $re->{'deps'} ){
  $list = ( $re->{'S_OPT'} or $re->{'BL'} and $re->{'CAS'} ) ? Dirs_1( $re->{'CEL'},1 ) :
   ( $re->{'TOP'} or $re->{'IS'} or $re->{'BL'} ) ? Dirs_1( $re->{'CEL'},3 ) :
     $re->{'USE'} ? [] : Dirs_1( $re->{'CEL'},0,$re );
   @$list = split '\t',$re->{'OS'}{"$re->{'USE'}uses"} if $re->{'USE'} and $re->{'OS'}{"$re->{'USE'}uses"};
    $re->{'cask'} = [] if $re->{'USE'};
   if( $re->{'MAC'} and $re->{'USE'} ){
    my @list1 = split '\t',$re->{'OS'}{"$re->{'USE'}u_form"} if $re->{'OS'}{"$re->{'USE'}u_form"};
    my @list2 = split '\t',$re->{'OS'}{"$re->{'USE'}u_cask"} if $re->{'OS'}{"$re->{'USE'}u_cask"};
     @{$re->{'cask'}} = ( @list1,@list2 );
   }
 }
 $re->{'COM'} ? Command_1( $re ) : ( $re->{'BL'} and $re->{'FOR'} or $re->{'USE'} ) ? Brew_1( $re,$list ) :
  $re->{'TOP'} ? Top_1( $re,$list ) : $re->{'IS'} ? Size_1( $re,$list ) : $re->{'ANA'} ? Ana_1( $re ) :
   $re->{'uses'} ? Brew_2( $re ) : $re->{'deps'} ? Brew_3( $re ) : File_1( $re,$list );
}

sub Ana_1{
 my( $re,@an ) = @_;
 $re->{'NEW'}++, Init_1( $re ) unless -f $re->{'CAN'};
 $re->{'L_OPT'} = 0 if not $re->{'L_OPT'} or $re->{'L_OPT'} and $re->{'L_OPT'} !~ /^[12]$/;
 open my $dir,'<',$re->{'CAN'} or die " ana $!\n";
  while(<$dir>){ chomp;
   my( $ls1,$ls2,$ls3,$ls4 ) = split '\t';
   my $co = $re->{'L_OPT'} == 1 ? $ls2 : $re->{'L_OPT'} == 2 ? $ls3 : $ls4;
   if( $co ){
    $an[$co]  = $ls1;
    $an[$co] .= $ls2 ? "\t$ls2" : "\t";
    $an[$co] .= $ls3 ? "\t$ls3" : "\t";
    $an[$co] .= $ls4 ? "\t$ls4" : "\t";
   }
  }
 close $dir;
  my $ana = (' 'x44)."|     30d  |     90d  |    365d  |\n".('-'x78)."\n";
 for(@an){
  next unless $_;
  my( $ls1,$ls2,$ls3,$ls4 ) = split '\t';
   my $le = int( (44-(length $ls1))/2 );
   $ana .= sprintf "%44s|%7s   |%7s   |%7s   |\n",' 'x$le.$ls1.' 'x$le,$ls2,$ls3,$ls4;
 }
  open my $pipe,'|-','more' or die " can't exec command\n";
   print $pipe $ana;
  close $pipe;
 Nohup_1( $re );
}

sub Size_1{ no warnings 'numeric';
 my( $re,$list,%HA,%AR,$size,@data,$pid,$c ) = @_;
 $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'TERM'} = sub{ rmdir "$re->{'HOME'}/WAIT"; die "\r\x1B[?25h\n"; };
  if( $re->{'INF'} and not $re->{'HASH'}{$re->{'INF'}} ){ exit;
  }elsif( $re->{'INF'} and $re->{'HASH'}{$re->{'INF'}} ){
   @data = split '\t',$re->{"$re->{'INF'}deps"} if $re->{"$re->{'INF'}deps"};
    push @data,$re->{'INF'};
  }
  unless(@data){
   $pid = fork;
    die " IS Not fork : $!\n" unless defined $pid;
  }
  unless( $pid or @data ){ Wait_1( $re,1 );
  }else{
   my @an = @data ? @data : @$list;
    @{$AR{$_}} = glob "$re->{'CEL'}/$_/*" for (@an);
   my $in = int @an/2;
   if( open my $FH,'-|' ){
    for(my $i=0;$i<$in;$i++){
      chomp( my $du = `du -ks $re->{'CEL'}/$an[$i]|awk '{print \$1}'` );
       $HA{"$du\t$an[$i]"} = 1;
    }
     while(<$FH>){ chomp;
      $HA{$_} = 1;
     } close $FH;
     if( $? ){ waitpid $pid,0 if rmdir "$re->{'HOME'}/WAIT"; die " can't open process\n"; }
   }else{
    for(my $i=$in;$i<@an;$i++){
      chomp( my $du = `du -ks $re->{'CEL'}/$an[$i]|awk '{print \$1}'` );
       print "$du\t$an[$i]\n";
    } exit;
   } waitpid $pid,0 if not @data and rmdir "$re->{'HOME'}/WAIT";
  }
  for(sort{$b <=> $a} keys %HA){ my $utime; $c++;
   my( $cou,$name ) = split '\t';
   for my $json(@{$AR{$name}}){
    if( -f "$json/INSTALL_RECEIPT.json" ){
     open my $dir,'<',"$json/INSTALL_RECEIPT.json" or die " JSON $!\n";
      while(<$dir>){
       last if( $utime ) = /^.*"time":[^0-9]*([0-9]+),.*/;
      }
     close $dir;
    }
   } $utime = $utime ? $utime : 0;
     my $time = [localtime($utime)];
    my $timer = sprintf "%04d/%02d/%02d",$time->[5]+=1900,++$time->[4],$time->[3];
   $size += $cou = sprintf "%.3f",$cou/=1024;
  Tap_2( $re,\$name );
format STDOUT =
@||||||||||||||||||||||||||||||||||||||||@||||||||@>>>>>>>>>>>>@|||@>>>>>>>>>>>>>>>>>>>>>
$name,"size  : ","$cou MB","   ","install  :  $timer"
.
write;
  }
  printf" Totsl Size  %.2f MB  item %d\n",$size,$c if -t STDOUT;
 Nohup_1( $re );
}

sub Doc_1{
 my( $dok,$not,@ten ) = $Locale ?
  ( "\r  \033[36m✔︎\033[00m : Creat new cache          \n",
    "\r  \033[31m✖︎\033[00m : Can not Create           \n",('⣸','⣴','⣦','⣇','⡏','⠟','⠻','⢹') ) :
  ( "\r  \033[36mo\033[00m : Creat new cache          \n",
    "\r  \033[31mx\033[00m : Can not Create           \n",('|','/','-','\\','|','/','-','\\') );
 $not,$dok,@ten;
}

sub Wait_1{
my( $re,$loop,$pid ) = @_;
 mkdir $re->{'HOME'};
 mkdir "$re->{'HOME'}/WAIT";
  my( $not,$dok,@ten ) = Doc_1;
  unless( $loop ){
   $pid = fork;
    die " Wait Not fork : $!\n" unless defined $pid;
  }
  if( $pid or $loop ){
   if( ( $loop or not -d "$re->{'HOME'}/LOCK" ) and -t STDOUT ){
    print STDERR "\x1B[?25l";
    if( $^O eq 'linux' or $loop or $re->{'TEN'} ){ my $i = 0;
     my $name = $loop ? 'Please wait' : 'Makes new cache';
      while(1){ $i = $i % 8; my $c = int(rand 6) + 1;
       -d "$re->{'HOME'}/WAIT" ?
        print STDERR "\r  \033[3${c}m$ten[$i]\033[00m : $name" : last;
         $i++; system 'sleep 0.1';
      }
    }else{ my $i = 0; my $ma = '';
      while(1){
      printf STDERR "\r '\033[33m%-20s\033[00m' [%2d/20]",$ma,$i;
       last unless -d "$re->{'HOME'}/WAIT";
        if( -d "$re->{'HOME'}/$i" ){
         while(1){
          last unless -d "$re->{'HOME'}/$i";
         } $i++; $ma .= '#';
        }
      }
    }
    unless( $loop ){
     waitpid $pid,0;
     ( $re->{'MAC'} and -f "$re->{'HOME'}/DBM.db" or
       $re->{'LIN'} and -f "$re->{'HOME'}/DBM.dir" ) ? ( print "\x1B[?25h$dok" and exit ) : die "\x1B[?25h$not";
    }else{ print "\r\x1B[?25h"; }
   } exit;
  }else{
   Tied_1( $re ) unless -d "$re->{'HOME'}/LOCK";
    $re->{'TEN'} ? system '~/.BREW_LIST/font.sh 1 2' : system '~/.BREW_LIST/font.sh 0 1';
     exit;
  }
}

sub DB_1{
my $re = shift;
 if( $re->{'FOR'} or $re->{'DEP' } ){
  opendir my $dir,$re->{'BIN'} or die " DB_1 $!\n";
   for(readdir $dir){
    my $hand = readlink "$re->{'BIN'}/$_";
     next if not $hand or $hand !~ m|^\.\./Cellar/|;
    my( $an,$bn ) = $hand =~ m|^\.\./Cellar/([^/]+)/(.+)|;
     $re->{'HASH'}{$an} = $bn;
   }
  closedir $dir;
 }
 if( $re->{'CAS'} or $re->{'CELS'} ){
  my $mem = $re->{'CEL'}, $re->{'CEL'} = $re->{'CELS'} if $re->{'CELS'};
  my $dirs = Dirs_1( $re->{'CEL'},3 );
  for(my $in=0;$in<@$dirs;$in++){
   if( $$dirs[$in] and -d "$re->{'CEL'}/$$dirs[$in]/.metadata" ){
    my $meta = Dirs_1( "$re->{'CEL'}/$$dirs[$in]/.metadata",3 );
     $re->{'DMG'}{$$dirs[$in]} = $$meta[0];
   }
  } $re->{'CEL'} = $mem if $re->{'CELS'};
 }
}

sub DB_2{
 my $re = shift;
 tie my %tap,'NDBM_File',"$re->{'HOME'}/DBM",O_RDONLY,0 or die " Not read DBM $!\n";
 $re->{'OS'} = \%tap;
}

sub Dirs_1{
my( $url,$ls,$re,$bn ) = @_;
 my $an = [];
 opendir my $dir_1,$url or die " Dirs_1 $!\n";
  for my $hand(readdir $dir_1){
   next if $hand =~ /^\./;
   $re->{'FILE'} .= " File exists $url/$hand\n" if -f "$url/$hand" and not $ls;
    if( $ls != 2 ){ next unless -d "$url/$hand"; }
   $ls == 1 ? push @$an," $hand\n" : push @$an,$hand;
  }
 closedir $dir_1;
  @$an = sort @$an;
   return $an if $ls;

 for(my $in=0;$in<@$an;$in++){
  push @$bn," $$an[$in]\n";
  opendir my $dir_2,"$url/$$an[$in]" or die " Dirs_2 $!\n";
   for(readdir $dir_2){
    next if /^\./;
     push @$bn,"$_\n";
   }
  closedir $dir_2;
 }
 $bn;
}

sub Top_1{
my( $re,$list,%HA,@AN,$top ) = @_;
 for my $ls(@$list){
  Uses_1( $re,$ls,\%HA,\@AN );
   if( @AN and @AN < 2 ){
    my @BUI = split '\t',$re->{'OS'}{"${ls}build"} if $re->{'OS'}{"${ls}build"};
    Tap_2( $re,\$ls ) if $re->{'FOR'};
     for my $bui(@BUI){ my $build = $bui;
      Tap_2( $re,\$bui ) if $re->{'FOR'};
       $ls .= " : $bui" if $re->{'HASH'}{$build};
     }
    $ls =~ s/^([^:]+)\s:\s(.+)/$1 [build] => $2\n/ ? $top .= $ls : Mine_1( $ls,$re,0 );
   }
  @AN = %HA = ();
 }print $top if $top;
}

sub Brew_1{
my( $re,$list,%HA,@AN ) = @_;
 return unless @$list or @{$re->{'cask'}};
  for(my $i=0;$i<@$list;$i++){ my $tap = $list->[$i];
   Tap_2( $re,\$list->[$i] ) if $re->{'FOR'};
    ( ( $re->{'DMG'}{$tap} or $re->{'HASH'}{$tap} ) and not $re->{'USE'} ) ? Mine_1( $list->[$i],$re,0 ) :
    ( ( $re->{'DMG'}{$tap} or $re->{'HASH'}{$tap} ) and $re->{'USE'} and not $re->{'USES'} ) ?
      Uses_1( $re,$tap,\%HA,\@AN ) : $re->{'USES'} ? push @AN,$tap : 0;
  } my @cask;
    $re->{'KAI'} = 1 unless @AN = sort @AN;
    @AN =( ' => Formula',@AN ) if @AN;
   $re->{'DMG'}{$_} ? push @cask,$_ : 0 for( @{$re->{'cask'}} );
  @AN = ( not $re->{'USES'} and @cask ) ? ( @AN,' => Cask',@cask ) :
 ( $re->{'USES'} and @{$re->{'cask'}} ) ? ( @AN,' => Cask',@{$re->{'cask'}} ) : @AN;
 Mine_1( $_,$re,0 ) for(@AN);
}

sub Brew_2{
my( $re,@AN,%HA ) = @_;
 for my $key(sort keys %{$re->{'HASH'}}){
  my @an = split '\t',$re->{'OS'}{"${key}uses"} if $re->{'OS'}{"${key}uses"};
  if( $re->{'MAC'} ){
   my @an1 = split '\t',$re->{'OS'}{"${key}u_form"} if $re->{'OS'}{"${key}u_form"};
   my @an2 = split '\t',$re->{'OS'}{"${key}u_cask"} if $re->{'OS'}{"${key}u_cask"};
    @an = ( @an,@an1,@an2 );
  }
   Uses_1( $re,$_,\%HA,\@AN ) for(@an);
    my $le = int( (36-(length $key))/2 );
   printf"%36s uses  :%4s formula\n",' 'x$le.$key.' 'x$le,@AN+0;
  @AN = %HA = ();
 }
 Nohup_1( $re );
}

sub Brew_3{
my( $re,$ls,@AN,%HA ) = @_;
 $ls ? print" => Cask\n" : print" => Formula\n";
 my $brew = $ls ? 'DMG' : 'HASH';
 for my $key(sort keys %{$re->{$brew}}){
  $re->{'INF'} = $key;
   Info_1( $re,0,0,\@AN,\%HA );
    Tap_2( $re,\$key );
     @AN = sort @AN unless $ls;
    @AN ? print"$key : @AN\n" : print"$key\n";
   $re->{"deps$_"} = 0 for(@AN);
  @AN = %HA = ();
 }
 Brew_3( $re,1 ) unless $ls or $re->{'LIN'} or not $re->{'DMG'};
 Nohup_1( $re );
}

sub Uses_1{
my( $re,$tap,$HA,$AN ) = @_;
 for my $ls(split '\t',$tap){
  $HA->{$ls}++;
   push @$AN,$ls if( $re->{'HASH'}{$ls} or $re->{'DMG'}{$ls} ) and $HA->{$ls} < 2;
   Uses_1( $re,$re->{'OS'}{"${ls}uses"},$HA,$AN ) if $re->{'OS'}{"${ls}uses"} and $re->{'HASH'}{$ls};
   Uses_1( $re,$re->{'OS'}{"${ls}u_form"},$HA,$AN ) if $re->{'OS'}{"${ls}u_form"} and $re->{'HASH'}{$ls};
   Uses_1( $re,$re->{'OS'}{"${ls}u_cask"},$HA,$AN ) if $re->{'OS'}{"${ls}u_cask"} and $re->{'DMG'}{$ls};
 }
}

sub Dele_1{
my( $re,@AN,%HA,@an,$do ) = @_;
 $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'TERM'} = sub{ rmdir "$re->{'HOME'}/WAIT"; die "\x1B[?25h" };
 print" \033[33mexists Formula and Cask...\033[00m\n" if $re->{'FOR'} and $re->{'OS'}{"$re->{'INF'}so_name"};
  waitpid $re->{'PID'},0 if $re->{'PID'} and not $re->{'DMG'}{$re->{'INF'}};
   exit unless $re->{'HASH'}{$re->{'INF'}} or $re->{'DMG'}{$re->{'INF'}};
  Uses_1( $re,$re->{'INF'},\%HA,\@AN ) if $re->{'FOR'};
   $_ eq $re->{'INF'} ? next : push @an,$_ for(sort @AN);
    $re->{'HASH'}{$_} ? print"required formula ==> $_\n" : print"required cask ==> $_\n" for(@an);

 unless( @an ){ @AN = %HA = ();
  unless( $re->{'CAS'} and $re->{'LINK'} ){
  $re->{'PID2'} = fork;
   die " Not fork : $!\n" unless defined $re->{'PID2'};
  }
  unless( $re->{'PID2'} or $re->{'CAS'} and $re->{'LINK'} ){ Wait_1( $re,1 );
  }else{
   Info_1( $re,0,'',\@AN,\%HA );
    my @list1 = sort @AN;
   for my $brew(@list1){
    exit unless ref $re->{$brew};
     my @list2 = sort @{$re->{$brew}};
     my $i = 0; my $e = 0;
     for(;$i<@list2;$i++){ my $flag;
      next if $list2[$i] eq $brew or $list2[$i] eq $re->{'INF'};
       for(;$e<@list1;$e++){
        last if $list1[$e] eq $list2[$i];
        $flag++, last if $list1[$e] gt $list2[$i];
       }
       $flag++ if $list1[$#list1] lt $list2[$i];
      last if $flag;
     }
    $re->{"${brew}delet"} = $do = 1 unless $list2[$i];
   } sleep 1 unless @AN;
    waitpid $re->{'PID2'},0 if not $do and rmdir "$re->{'HOME'}/WAIT";
   if( $re->{'LINK'} and $do ){
    $re->{'DEL'} = $re->{'TREE'} = $re->{'INF'} = 0;
     $re->{'LIST'} = 1;
      waitpid $re->{'PID'},0 if $re->{'PID'};
       Fork_1( $re );
   }elsif( $do ){
    $re->{'COLOR'} = $re->{'TREE'} = $re->{'DEL'} = 2;
     Fork_1( $re );
   }
  }
 }
 Nohup_1( $re );
}

sub File_1{
my( $re,$list,$file ) = @_; my( $i,$e,@tap ) = ( -1,0 );
  unless( $re->{'TAP'} ){
   open my $BREW,'<',$re->{'TXT'} or die " File_1 $!\n";
    chomp( @$file=<$BREW> );
   close $BREW;
  }
  $tap[0] = $file if $re->{'CAS'} and $re->{'S_OPT'} or $re->{'BL'};
  if( $re->{'CAS'} and -f $re->{'Q_TAP'} ){
   open my $BREW,'<',$re->{'Q_TAP'} or die " File_1 $!\n";
    while(my $tap=<$BREW>){ chomp $tap;
     if( $tap =~ /^[3-9#]$/ ){
       if( $re->{'FDIR'} and $re->{'DDIR'} and $re->{'VERS'} and $tap ne '9' or
           $re->{'FDIR'} and $re->{'DDIR'} and not $re->{'VERS'} and $tap ne '8' or
           $re->{'FDIR'} and $re->{'VERS'} and not $re->{'DDIR'} and $tap ne '7' or
           $re->{'DDIR'} and $re->{'VERS'} and not $re->{'FDIR'} and $tap ne '6' or
           $re->{'FDIR'} and not $re->{'DDIR'} and not $re->{'VERS'} and $tap ne '5' or
           $re->{'DDIR'} and not $re->{'FDIR'} and not $re->{'VERS'} and $tap ne '4' or
           $re->{'VERS'} and not $re->{'FDIR'} and not $re->{'DDIR'} and $tap ne '3' or
           not $re->{'VERS'} and not $re->{'FDIR'} and not $re->{'DDIR'} and $tap ne '#' ){
            die " exist \033[31mLOCK\033[00m\n" if -d "$re->{'HOME'}/LOCK";
             $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'TERM'} = sub{ my( $not ) = Doc_1; die "\x1B[?25h$not" };
              $re->{'TEN'} = 1;  Wait_1( $re );
       }
        last if not $re->{'TAP'} and $re->{'CAS'} and ( $re->{'LIST'} or $re->{'PRINT'} or $re->{'DAT'} );
       exit unless not $re->{'TAP'} or $re->{'FDIR'} or $re->{'DDIR'} or $re->{'VERS'};
      next;
     }
      if( $re->{'TAP'} ){
       $i++ if $tap =~ /^[012]$/;
        push @{$tap[$i]},$tap;
      }elsif( $re->{'BL'} or $re->{'S_OPT'} ){
       $e++ if $tap =~ /^[012]$/;
        push @{$tap[$e]},$tap;
      }else{
        push @{$file},$tap;
      }
    }
   close $BREW;
  }elsif( $re->{'TAP'} and not -f $re->{'Q_TAP'} ){
    die " Tap No such file\n";
  }
  if( -d "$ENV{'HOME'}/.JA_BREW" and not $re->{'EN'} and ( $re->{'LIST'} or $re->{'PRINT'} or $re->{'DEP'} ) ){
    no warnings 'closed';
   if( $re->{'FOR'} or $re->{'DEP'} ){
    open my $JA,'<',"$ENV{'HOME'}/.JA_BREW/ja_brew.txt" or print " ### Not exist brew JA_file ###\n";
     while(<$JA>){
     my( $name,$desc ) = split '\t';
      chomp( $JA{$name} = $desc );
     }
    close $JA;
   }
   if( $re->{'CAS'} and ( not $re->{'TAP'} or $re->{'DEP'} ) ){
    open my $JA,'<',"$ENV{'HOME'}/.JA_BREW/ja_cask.txt" or print " ### Not exist cask JA_file ###\n";
     while(<$JA>){
     my( $name,$desc ) = split '\t';
      chomp( $JA{$name} = $desc );
     }
    close $JA;
   }
   if( $re->{'FDIR'} or $re->{'DDIR'} or $re->{'VERS'} ){
    if( $re->{'CAS'} or $re->{'TAP'} or $re->{'DEP'} ){
     open my $JA,'<',"$ENV{'HOME'}/.JA_BREW/ja_tap.txt" or print " ### Not exist tap JA_file ###\n";
      while(<$JA>){
      my( $name,$desc ) = split '\t';
       chomp( $JA{$name} = $desc );
      }
     close $JA;
    }
   }
  }
  Format_3( $file,$re ) if $re->{'DEP'};
   $re->{'AN'} = $re->{'IN'} = $re->{'BN'} = $re->{'CN'} = $re->{'DN'} = $re->{'DI'} = 0;
  if( $re->{'TAP'} ){ my $i = 0; my $e = 0;
   for(@tap){
    Search_1( $list,$_,0,$re );
     unless( $re->{'L_OPT'} ){
      $i = $re->{'AN'} - $i; $e = $re->{'IN'} - $e;
       $re->{'ALL'} .= "$re->{'SPA'} item $i : install $e\n" if $i;
      $i = $re->{'AN'}; $e = $re->{'IN'};
     }elsif( not $re->{'KEN'} ){
      $i = $re->{'BN'} - $i; $e = $re->{'CN'} - $e;
       $re->{'EXC'} .= "$re->{'SPA'} item $i : install $e\n" if $i;
      $i = $re->{'BN'}; $e = $re->{'CN'};
     }else{
      $i = $re->{'DN'} - $i; $e = $re->{'DI'} - $e;
       $re->{'KXC'} .= "$re->{'SPA'} item $i : install $e\n" if $i;
      $i = $re->{'DN'}; $e = $re->{'DI'};
     }
   }
  }elsif( $re->{'CAS'} and $re->{'S_OPT'} or $re->{'BL'} ){
   for(@tap){
    Search_1( $list,$_,0,$re );
   }
  }else{
   Search_1( $list,$file,0,$re );
  }
}

sub Unic_1{
my( $re,$brew,$spa,$AN,$build ) = @_;
 my $name = $$brew;
  $$brew =~ s|.+/([^/]+)|$1|;
   $$brew =  $re->{'OS'}{"$${brew}alia"} ? $re->{'OS'}{"$${brew}alia"} : $$brew;
 $name = -t STDOUT ? "$name \033[33m(require)\033[00m" : "$name (require)"
   if not $re->{'COLOR'} and ( not $re->{'HASH'}{$$brew} and not $re->{'DMG'}{$$brew} or
          $re->{'HASH'}{$$brew} and $re->{'OS'}{"$${brew}ver"} gt $re->{'HASH'}{$$brew} );
 $name = -t STDOUT ? "$name \033[33m(can delete)\033[00m" : "$name (can delete)"
   if $re->{'COLOR'} and $re->{"$${brew}delet"} and ( $re->{'HASH'}{$$brew} or $re->{'DMG'}{$$brew} );

 $re->{"deps$$brew"} +=
  ( $re->{'TREE'} and $build ) ? push @{$re->{'UNI'}},"${spa}-- $name [build]\n" :
    $re->{'TREE'} ? push @{$re->{'UNI'}},"${spa}-- $name\n" : 1;
 push @$AN,$$brew if ( $re->{'DEL'} or $re->{'deps'} ) and $re->{"deps$$brew"} < 2;
  $re->{"$re->{'INF'}deps"} .= "$$brew\t"
   if $re->{"deps$$brew"} < 2 and not $build and ( $re->{'HASH'}{$$brew} or $re->{'DMG'}{$$brew} );
}

sub Info_1{
my( $re,$file,$spa,$AN,$HA ) = @_;
 print " \033[33mCan't install $re->{'INF'}...\033[00m\n" if not $file and $re->{'FOR'} and
  ( ( $re->{'MAC'} and ( $re->{'OS'}{"$re->{'INF'}un_xcode"} or $re->{'OS'}{"$re->{'INF'}un_cask"} ) ) or
    ( $re->{'LIN'} and $re->{'OS'}{"$re->{'INF'}un_Linux"} ) );
 print" \033[33mexists Formula and Cask...\033[00m\n"
  if not $file and $re->{'FOR'} and $re->{'OS'}{"$re->{'INF'}so_name"};
 my $brew = $file ? $file : $re->{'INF'} ? $re->{'INF'} : exit;
  ++$re->{'NEW'} and Init_1( $re ) unless $brew;
   my $bottle =  $re->{'OS'}{"$brew$OS_Version"} ? 1 : 0;
    $spa .= $spa ? '   |' : '|';
 if( $re->{'DEL'} ){ my( %HA_1,@AN_1 );
  $HA->{$brew}++;
   if( $HA->{$brew} < 2 ){
    Uses_1( $re,$brew,\%HA_1,\@AN_1 );
     push @{$re->{$brew}},@AN_1;
   }
 }
 if( $re->{'OS'}{"${brew}deps_b"} ){
  for my $data(split '\t',$re->{'OS'}{"${brew}deps_b"}){
   if( not $re->{'OS'}{"${data}so_name"} and ( not $bottle and not $re->{'HASH'}{$brew} or
       not $bottle and $re->{'OS'}{"${brew}ver"} gt $re->{'HASH'}{$brew} ) and
     ( not $re->{'HASH'}{$data} or $re->{'OS'}{"${data}ver"} gt $re->{'HASH'}{$data} ) ){
       Unic_1( $re,\$data,$spa,$AN,1 );
        Info_1( $re,$data,$spa,$AN,$HA );
   }
  }
 }
 if( $re->{'FOR'} and $re->{'OS'}{"${brew}deps"} ){
  for my $data2(split '\t',$re->{'OS'}{"${brew}deps"}){
    Unic_1( $re,\$data2,$spa,$AN );
     Info_1( $re,$data2,$spa,$AN,$HA );
  }
 }
 if( $re->{'FOR'} and $re->{'OS'}{"${brew}formula"} ){
  for my $data3(split '\t',$re->{'OS'}{"${brew}formula"}){
    Unic_1( $re,\$data3,$spa,$AN );
     Info_1( $re,$data3,$spa,$AN,$HA );
  }
 }
 if( $re->{'OS'}{"${brew}d_cask"} ){
  for my $data4(split '\t',$re->{'OS'}{"${brew}d_cask"}){
   unless( $re->{'FOR'} and $re->{'OS'}{"${data4}so_name"} and not $re->{'TREE'} ){
    Unic_1( $re,\$data4,$spa,$AN );
     Info_1( $re,$data4,$spa,$AN,$HA ) unless $re->{'OS'}{"${data4}so_name"};
   }
  }
 }
}

sub Mine_1{
my( $name,$re,$ls ) = @_;
 $name = "$name (I)" if( $ls and -t STDOUT );
 if( $name !~ m|^ ==> homebrew/| ){
  $re->{'LEN'}{$name} = length $name;
   push @{$re->{'ARR'}},$name;
 }else{
   push @{$re->{'ARR'}},$name; return;
 }
 if( $name =~ m|^homebrew/cask-versions/| ){
   $re->{'LEN4'} = $re->{'LEN'}{$name} if $re->{'LEN4'} < $re->{'LEN'}{$name};
 }elsif( $name =~ m|^homebrew/cask-drivers/| ){
   $re->{'LEN3'} = $re->{'LEN'}{$name} if $re->{'LEN3'} < $re->{'LEN'}{$name};
 }elsif( $name =~ m|^homebrew/cask-fonts/| ){
   $re->{'LEN2'} = $re->{'LEN'}{$name} if $re->{'LEN2'} < $re->{'LEN'}{$name};
 }else{
   $re->{'LEN1'} = $re->{'LEN'}{$name} if $re->{'LEN1'} < $re->{'LEN'}{$name};
 }
}

sub Memo_1{
my( $re,$mem,$dir ) = @_;
 if( defined $dir ){
  my $file = Dirs_1( "$re->{'CEL'}/$dir",2 );
  if( @$file ){
     $re->{'ALL'} .= "     Check folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= "     Check folder $re->{'CEL'} => $dir\n" if $mem;
   for(my $i=0;$i<@$file;$i++){
     $re->{'ALL'} .= $#$file == $i ? "    $$file[$i]\n" : "     $$file[$i]" unless $re->{'L_OPT'};
     $re->{'EXC'} .= $#$file == $i ? "    $$file[$i]\n" : "     $$file[$i]" if $mem;
   }
  }else{
     $re->{'ALL'} .= "     Empty folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= "     Empty folder $re->{'CEL'} => $dir\n" if $mem;
  }
 }else{
    $re->{'ALL'} .= $re->{'MEM'} unless $re->{'L_OPT'};
     if( $re->{'KEN'} and $re->{'L_OPT'} ){
      my( $top,$mee ) = $re->{'MEM'} =~ /^(.{9})(.+)/;
      my( $brew ) = split '\t',$mee;
      my $name = -d "$ENV{'HOME'}/.JA_BREW" ? encode 'utf-8',$re->{'L_OPT'} : $re->{'L_OPT'};
       if( $mee =~ /^ ==>/ or $mee =~ s/(\Q$name\E)/\033[33m$1\033[00m/ig ){
           $mee =~ s/\033\[33m|\033\[00m//g unless -t STDOUT;
          $re->{'DI'}++ if $re->{'HASH'}{$brew} or $re->{'DMG'}{$brew};
         $re->{'DN'}++ if $mee !~ /^ ==>/;
        $re->{'KXC'} .= "$top$mee\n";
       }
     }else{
      $re->{'EXC'} .= $re->{'MEM'} if $mem;
     }
 }
}

sub Version_1{
my( $ls1,$ls2 ) = @_;
 my @ls1 = split '\.|-|_',$ls1;
 my @ls2 = split '\.|-|_',$ls2;
 my $i = 0;
  for(;$i<@ls2;$i++){
   if( $ls1[$i] and $ls2[$i] =~ /[^\d]/ ){
     if( $ls1[$i] gt $ls2[$i] ){ return 1;
     }elsif( $ls1[$i] lt $ls2[$i] ){ return;
     }
   }else{
     if( $ls1[$i] and $ls1[$i] > $ls2[$i] ){ return 1;
     }elsif( $ls1[$i] and $ls1[$i] < $ls2[$i] ){ return;
     }
   }
  }
 $ls1[$i] ? 1 : 0;
}

sub Version_2{
my( $re,$ls1,$ls2 ) = @_;
 $re->{'TAR'} = ( $re->{'MAC'} and $re->{'FOR'} ) ?
  Dirs_1( "$ENV{'HOME'}/Library/Caches/Homebrew",2 ) : ( $re->{'MAC'} and $re->{'CAS'} ) ?
   Dirs_1( "$ENV{'HOME'}/Library/Caches/Homebrew/Cask",2 ) :
    Dirs_1( "$ENV{'HOME'}/.cache/Homebrew",2 ) unless $re->{'TAR'};
 for my $gz( @{$re->{'TAR'}} ){
  if( $gz =~ s/^$ls1--([\d._-]+)\.[^\d_-]+\d?$/$1/ or $gz =~ s/^$ls1--([\d._-]+)$/$1/ ){
    $re->{'GZ'} = ( $re->{'FOR'} and Version_1($gz,$re->{'HASH'}{$ls1}) ) ? 1 :
                  ( $re->{'CAS'} and Version_1($gz,$re->{'DMG'}{$ls1}) )  ? 1 : 0;
    last if $re->{'GZ'};
   }
 }
  $re->{'GZ'} ? Type_1( $re,$ls1,'(i)','e' ) : Type_1( $re,$ls1,'(i)' );
   if( -t STDOUT ){
    $re->{'OUT'}[$re->{'UP'}++] = ( $re->{'FOR'} and $re->{'GZ'} ) ?
     " e $ls1 $re->{'HASH'}{$ls1} < $ls2\n" : ( $re->{'CAS'} and $re->{'GZ'} ) ?
     " e $ls1 $re->{'DMG'}{$ls1} != $ls2 : Cask\n"  : $re->{'FOR'} ?
     "   $ls1 $re->{'HASH'}{$ls1} < $ls2\n" : "   $ls1 $re->{'DMG'}{$ls1} != $ls2 : Cask\n";
   }else{
    $re->{'OUT'}[$re->{'UP'}++] = "$ls1\n" unless $re->{'GZ'};
   }
  $re->{'GZ'} = 0;
}

sub Search_1{ no warnings 'regexp';
my( $list,$file,$in,$re ) = @_;
 for(my $i=0;$i<@$file;$i++){ my $pop = 0;
  my( $brew_1,$brew_2,$brew_3 ) = split '\t',$file->[$i];
   next if $brew_1 =~ m|^homebrew/| and not $re->{'S_OPT'};
    my $mem = ( $re->{'L_OPT'} and ( $brew_1 =~ /$re->{'L_OPT'}/ or $brew_1 =~ /^[012]$/ ) ) ? 1 : 0;

  $brew_1 = $brew_1 eq '0' ? ' ==> homebrew/cask-fonts' :
            $brew_1 eq '1' ? ' ==> homebrew/cask-drivers' :
            $brew_1 eq '2' ? ' ==> homebrew/cask-versions' : $brew_1;
  if( ( $re->{'BL'} or $re->{'S_OPT'} ) and $brew_1 =~ m|^ ==> homebrew/| ){
       Mine_1($brew_1,$re,0); next; }

  $brew_2 = $re->{'OS'}{"${brew_1}c_version"} if $re->{'CAS'} and $re->{'OS'}{"${brew_1}c_version"};
   $brew_2 = $re->{'OS'}{"${brew_1}ver"} ? $re->{'OS'}{"${brew_1}ver"} : $brew_2 if $re->{'FOR'};

  $brew_3 = ( $re->{'CAS'} and $re->{'OS'}{"${brew_1}c_desc"} ) ? $re->{'OS'}{"${brew_1}c_desc"} :
   ( $re->{'TAP'} and $re->{'OS'}{"${brew_1}c_name"} ) ? $re->{'OS'}{"${brew_1}c_name"} : $brew_3 ? $brew_3 : 0;
    $brew_3 = $JA{$brew_1} if $JA{$brew_1};
     $brew_3 =~ s/[“”]//g unless $Locale;

  if( not $re->{'LINK'} or
      $re->{'LINK'} == 1 and $re->{'OS'}{"${brew_1}un_xcode"} or
      $re->{'LINK'} == 2 and $re->{'OS'}{"${brew_1}un_Linux"} or
      $re->{'LINK'} == 3 and $re->{'OS'}{"$brew_1$OS_Version"} or
      $re->{'LINK'} == 4 and $re->{'OS'}{"${brew_1}un_cask"} or
      $re->{'LINK'} == 5 and $re->{'OS'}{"${brew_1}so_name"} or
      $re->{'LINK'} == 6 and $re->{"deps$brew_1"} or
      $re->{'LINK'} == 7 and $re->{"${brew_1}delet"} ){

    if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
     Tap_1( $list,$re,\$in );
      $i--; next;
    }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
     if( $re->{'S_OPT'} ){ my $ls = $brew_1;
      Tap_2( $re,\$ls ) if $re->{'FOR'};
      ( $re->{'DMG'}{$brew_1} or $re->{'HASH'}{$brew_1} ) ?
       Mine_1( $ls,$re,1 ) : Mine_1( $ls,$re,0 ) if $brew_1 =~ /$re->{'S_OPT'}/o;
     }elsif( $re->{'BL'} and $re->{'DMG'}{$brew_1} ){ Mine_1( $brew_1,$re,0 );
     } $pop = ++$in;
        $re->{'IN'}++; $re->{'CN'}++ if $mem;
    }else{
     if( $re->{'S_OPT'} and $brew_1 =~ m|(?!.*/)$re->{'S_OPT'}|o ){
      if( my( $opt ) = $brew_1 =~ m|^homebrew/.+/(.+)| ){
       Mine_1( $brew_1,$re,0 ) if $opt =~ /\b$re->{'S_OPT'}\b/o and $re->{'S_OPT'} !~ /^(-|\\-)$/;
      }else{ Mine_1( $brew_1,$re,0 ); }
     }
    }
   unless( $re->{'S_OPT'} or $re->{'BL'} ){
     if( $re->{'MAC'} ){
      if( $re->{'FOR'} ){
       $re->{'MEM'} = ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg"} ) ?
        " b k     $brew_1\t" : $re->{'OS'}{"$brew_1$OS_Version"} ? " b       $brew_1\t" :
         ( $re->{'OS'}{"${brew_1}un_xcode"} and $re->{'OS'}{"${brew_1}keg"} ) ?
       " x k     $brew_1\t" : $re->{'OS'}{"${brew_1}un_xcode"} ? " x       $brew_1\t" :
       $re->{'OS'}{"${brew_1}keg"} ? "   k     $brew_1\t" : "$re->{'SPA'}$brew_1\t";
      }else{
       $re->{'MEM'} = ( $re->{'OS'}{"${brew_1}un_cask"} and $re->{'OS'}{"${brew_1}so_name"} ) ?
        " x s     $brew_1\t" : ( $re->{'OS'}{"${brew_1}un_cask"} and $re->{'OS'}{"${brew_1}d_cask"} ) ?
        " x c     $brew_1\t" : ( $re->{'OS'}{"${brew_1}un_cask"} and $re->{'OS'}{"${brew_1}formula"} ) ?
        " x f     $brew_1\t" : $re->{'OS'}{"${brew_1}un_cask"} ? " x       $brew_1\t" :
       $re->{'OS'}{"${brew_1}so_name"} ? "   s     $brew_1\t" : $re->{'OS'}{"${brew_1}d_cask"} ?
        "   c     $brew_1\t" :  $re->{'OS'}{"${brew_1}formula"} ?
        "   f     $brew_1\t" : "$re->{'SPA'}$brew_1\t";
      }
     }else{
       $re->{'MEM'} = ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
       " b k     $brew_1\t" : $re->{'OS'}{"$brew_1$OS_Version"} ? " b       $brew_1\t" :
        ( $re->{'OS'}{"${brew_1}un_Linux"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
       " x k     $brew_1\t" : $re->{'OS'}{"${brew_1}un_Linux"}  ? " x       $brew_1\t" :
       $re->{'OS'}{"${brew_1}keg_Linux"} ? "   k     $brew_1\t" : "$re->{'SPA'}$brew_1\t";
     }
    if( $pop ){
     if( not $list->[$in] or $list->[$in] =~ /^\s/ ){
       Memo_1( $re,$mem,$brew_1 );
         $i--; next;
     }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
       Memo_1( $re,$mem,$brew_1 );
       while(1){ $in++;
        last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
       }
     }
     if( $re->{'FOR'} and not $re->{'HASH'}{$brew_1} or
         $re->{'CAS'} and not $re->{'DMG'}{$brew_1} ){
           $re->{'MEM'} =~ s/^.{9}$brew_1\t/      X  $brew_1\tNot Formula\n/;
            Memo_1( $re,$mem );
             $in++; $i--; next;
     }else{
      if( $re->{'FOR'} and $brew_2 ne $re->{'HASH'}{$brew_1} and
        ( not $re->{'OS'}{"${brew_1}un_xcode"} or not $re->{'OS'}{"${brew_1}un_Linux"} ) or
          $re->{'CAS'} and not $re->{'OS'}{"${brew_1}un_cask"} and $brew_2 ne $re->{'DMG'}{$brew_1} ){
         Version_2( $re,$brew_1,$brew_2 );
      }else{
         Type_1( $re,$brew_1,' i ' );
      }
     }
     $in++;
    }
    $re->{'MEM'} .= "$brew_2\t$brew_3\n" if defined $brew_2;
     $re->{'MEM'} =~ s/\t/\n/ unless defined $brew_2;
      Memo_1( $re,$mem ) if $re->{'LIST'} or $pop;
       $re->{'BN'}++ if $mem and $brew_1 !~ m|==> homebrew/|;
        $re->{'AN'}++ if $brew_1 !~ m|==> homebrew/|;
   }
  }
 }
 if( $list->[$in] ){
  Tap_1( $list,$re,\$in ) while($list->[$in]);
 }
 unless( $re->{'LIST'} ){ my @tap = ([],[],[]);
  for(@{$re->{'ARY'}}){
   push @{$tap[2]},$_ if s/^homebrew-cask-versions\n(.+)/$1/;
    push @{$tap[1]},$_ if s/^homebrew-cask-drivers\n(.+)/$1/;
     push @{$tap[0]},$_ if s/^homebrew-cask-fonts\n(.+)/$1/;
  } my( $i,$flag1,$flag2 ); my $e = 0;
  for my $tap( @tap ){ $i++;
   $flag2++, $re->{'ALL'} .= "$re->{'SPA'} in_item $re->{'IN'}\n" if @$tap and $re->{'ALL'} and not $flag2;
   $i++ unless @$tap;
   for(@$tap){
    if( $i == 1 ){ $i++;
      $re->{'ALL'} .= "$re->{'SPA'} ==> homebrew/cask-fonts\n";
    }elsif( $i == 3 ){ $i++;
      $re->{'ALL'} .= "$re->{'SPA'} in_item $e\n" if $e; $e = 0;
      $re->{'ALL'} .= "$re->{'SPA'} ==> homebrew/cask-drivers\n";
    }elsif( $i == 5 ){ $i++;
      $re->{'ALL'} .= "$re->{'SPA'} in_item $e\n" if $e; $e = 0;
      $re->{'ALL'} .= "$re->{'SPA'} ==> homebrew/cask-versions\n";
    }
    if( $i == 2 ){ $e++;
    }elsif( $i == 4 ){ $e++;
    }elsif( $i == 6 ){ $e++; $flag1 = 1;
    } $re->{'ALL'} .= $_;
     $re->{'AN'}++; $re->{'IN'}++;
   }
  } $re->{'ALL'} .= "$re->{'SPA'} in_item $e\n" if $flag1;
 }
}

sub Tap_1{ no warnings 'regexp';
my( $list,$re,$in ) = @_;
 unless( $re->{'CAS'} and $re->{'S_OPT'} or $re->{'BL'} ){
  my( $tap ) = $list->[$$in] =~ /^\s(.*)\n/;
   my $mem = ( $re->{'L_OPT'} and $tap =~ /$re->{'L_OPT'}/ ) ? 1 : 0;
    my( $dirs1 ) = $re->{'OS'}{"${tap}cask"} =~ m|.+/(homebrew-[^/]+)/.+|
    if not $re->{'FOR'} and $re->{'OS'}{"${tap}cask"};

    my $ver = ( $re->{'FOR'} and $re->{'OS'}{"${tap}f_version"}) ?
     $re->{'OS'}{"${tap}f_version"} : ( $re->{'CAS'} and $re->{'OS'}{"${tap}c_version"}) ?
      $re->{'OS'}{"${tap}c_version"} : ( $re->{'FOR'} and $re->{'HASH'}{$tap} ) ?
       $re->{'HASH'}{$tap} : ( $re->{'CAS'} and $re->{'DMG'}{$tap} ) ? $re->{'DMG'}{$tap} : 0;
    $ver = $ver.$re->{'OS'}{"${tap}revision"}
     if $re->{'FOR'} and $ver !~ /_\d+$/ and $re->{'OS'}{"${tap}revision"};

    my $com = ( $re->{'FOR'} and $re->{'OS'}{"${tap}f_desc"} ) ?
     $re->{'OS'}{"${tap}f_desc"} : ( $re->{'FOR'} and $re->{'OS'}{"${tap}f_name"} ) ?
      $re->{'OS'}{"${tap}f_name"} : ( $re->{'CAS'} and $re->{'OS'}{"${tap}c_desc"} ) ?
       $re->{'OS'}{"${tap}c_desc"} : ( $re->{'CAS'} and $re->{'OS'}{"${tap}c_name"} ) ?
        $re->{'OS'}{"${tap}c_name"} : 0;
     $com = $JA{$tap} if $JA{$tap};

      my $brew = 1;
   if( $re->{'LINK'} and $re->{'LINK'} == 1 and not $re->{'OS'}{"${tap}un_xcode"} or
       $re->{'LINK'} and $re->{'LINK'} == 2 and not $re->{'OS'}{"${tap}un_Linux"} or
       $re->{'LINK'} and $re->{'LINK'} == 3 and not $re->{'OS'}{"$tap$OS_Version"} or
       $re->{'LINK'} and $re->{'LINK'} == 4 and not $re->{'OS'}{"${tap}un_cask"} or
       $re->{'LINK'} and $re->{'LINK'} == 5 and not $re->{'OS'}{"${tap}so_name"} or
       $re->{'LINK'} and $re->{'LINK'} == 6 and not $re->{"deps$tap"} or
       $re->{'LINK'} and $re->{'LINK'} == 7 and not $re->{"${tap}delet"} ){
      $brew = 0;
   }
  if( $re->{'S_OPT'} and $tap =~ /$re->{'S_OPT'}/ and $re->{'DMG'}{$tap} or
      $re->{'S_OPT'} and $tap =~ /$re->{'S_OPT'}/ and $re->{'HASH'}{$tap}){
       Tap_2( $re,\$tap ) if $re->{'FOR'};
        Mine_1( $tap,$re,1 );
  }elsif( $list->[$$in + 1] and $list->[$$in + 1] !~ /^\s/ ){ $$in++;
    if( $list->[$$in + 1] and $list->[$$in + 1] !~ /^\s/ ){
     Memo_1( $re,$mem,$tap );
      while(1){ $$in++;
       last if not $list->[$$in + 1] or $list->[$$in + 1] =~ /^\s/;
      }
    }
    if( $re->{'FOR'} and not $re->{'HASH'}{$tap} or
        $re->{'CAS'} and not $re->{'DMG'}{$tap} ){
        $re->{'MEM'} = "      X  $tap\tNot Formula\n";
         Memo_1( $re,$mem ) unless $re->{'FOR'};
    }elsif( $re->{'FOR'} and $ver ne $re->{'HASH'}{$tap} and
          ( not $re->{'OS'}{"${tap}un_xcode"} or not $re->{'OS'}{"${tap}un_Linux"} ) or
            $re->{'CAS'} and not $re->{'OS'}{"${tap}un_cask"} and $ver ne $re->{'DMG'}{$tap} ){
        $re->{'MEM'} = "$re->{'SPA'}$tap\t$ver\t$com\n";
         Version_2( $re,$tap,$ver );
    }else{
        $re->{'MEM'} = "$re->{'SPA'}$tap\t$ver\t$com\n";
         Type_1( $re,$tap,' i ' );
    }
       push @{$re->{'ARY'}},"$dirs1\n".$re->{'MEM'} if $dirs1;
     if( $brew and not @{$re->{'ARY'}} ){
      Memo_1( $re,$mem );
       $re->{'AN'}++; $re->{'IN'}++;
      $re->{'BN'}++, $re->{'CN'}++ if $mem;
     }
  }else{
    Memo_1( $re,$mem,$tap );
  }
 }
 $$in++;
}

sub Tap_2{
my( $re,$tap ) = @_;
 Tap_3( $re->{'TAP_S'},$re ) unless $re->{'TAP2'};
  for(@{$re->{'TAP2'}}){ $$tap = $_ if m|/$$tap|; }
}

sub Tap_3{
my( $dir,$re ) = @_;
 for(glob "$dir/*"){
  next if m|/homebrew$|;
   Tap_3( $_,$re ) if -d;
  push @{$re->{'TAP2'}},$_ if s|.+/Taps/([^/]+)/homebrew-([^/]+)/(?:[^/]+/)*([^/]+)\.rb$|$1/$2/$3|;
 }
}

sub Type_1{
my( $re,$brew_1,$i,$e ) = @_;
 if( $re->{'MAC'} ){
  if( $re->{'FOR'} ){
   ( $re->{'OS'}{"${brew_1}un_xcode"} and $re->{'OS'}{"${brew_1}keg"} ) ?
    $re->{'MEM'} =~ s/^.{9}/ t k $i / : $re->{'OS'}{"${brew_1}un_xcode"} ?
    $re->{'MEM'} =~ s/^.{9}/ t   $i / :
   ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg"} ) ?
    $re->{'MEM'} =~ s/^.{9}/ b k $i / : ( $e and $re->{'OS'}{"${brew_1}keg"} ) ?
    $re->{'MEM'} =~ s/^.{9}/ e k $i / :  $re->{'OS'}{"$brew_1$OS_Version"} ?
    $re->{'MEM'} =~ s/^.{9}/ b   $i / : $re->{'OS'}{"${brew_1}keg"} ?
    $re->{'MEM'} =~ s/^.{9}/   k $i / : $e ? $re->{'MEM'} =~ s/^.{9}/ e   $i / :
    $re->{'MEM'} =~ s/^.{9}/     $i /;
  }else{
   ( $re->{'OS'}{"${brew_1}un_cask"} and  $re->{'OS'}{"${brew_1}so_name"} ) ?
    $re->{'MEM'} =~ s/^.{9}/ t s $i / :
   ( $re->{'OS'}{"${brew_1}un_cask"} and  $re->{'OS'}{"${brew_1}formula"} ) ?
    $re->{'MEM'} =~ s/^.{9}/ t f $i / :
   ( $re->{'OS'}{"${brew_1}un_cask"} and  $re->{'OS'}{"${brew_1}d_cask"} ) ?
    $re->{'MEM'} =~ s/^.{9}/ t c $i / : $re->{'OS'}{"${brew_1}un_cask"} ?
    $re->{'MEM'} =~ s/^.{9}/ t   $i / : $re->{'OS'}{"${brew_1}so_name"} ?
    $re->{'MEM'} =~ s/^.{9}/   s $i / : $re->{'OS'}{"${brew_1}formula"} ?
    $re->{'MEM'} =~ s/^.{9}/   f $i / : $re->{'OS'}{"${brew_1}d_cask"} ?
    $re->{'MEM'} =~ s/^.{9}/   c $i / : $re->{'MEM'} =~ s/^.{9}/     $i /;
  }
 }else{
  ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
   $re->{'MEM'} =~ s/^.{9}/ b k $i / : $re->{'OS'}{"$brew_1$OS_Version"} ?
   $re->{'MEM'} =~ s/^.{9}/ b   $i / : $re->{'OS'}{"${brew_1}keg_Linux"} ?
   $re->{'MEM'} =~ s/^.{9}/   k $i / : $re->{'MEM'} =~ s/^.{9}/     $i /;
 }
}

sub Command_1{
my( $re,$ls1,$ls2,%HA,%OP ) = @_;
 exit unless my $num = $re->{'HASH'}{$re->{'STDI'}};
 Dirs_2( "$re->{'CEL'}/$re->{'STDI'}/$num",$re );
 $re->{'CEL'} = "$re->{'CEL'}/\Q$re->{'STDI'}\E/$num";
  for $ls1(@{$re->{'ARR'}}){
   next if $ls1 =~ m[^$re->{'CEL'}/[^.][^/]+$|^$re->{'CEL'}/\.brew]o;
   if( $ls1 =~ m[^$re->{'CEL'}/\.|^$re->{'CEL'}/s?bin/]o ){
           print"$ls1\n";
   }elsif(not -l $ls1 and $ls1 =~ m|^$re->{'CEL'}/lib/[^/]+dylib$|o){
           print"$ls1\n"; $re->{'INN'} = 1;
   }else{ $ls2 = $ls1;
     $ls1 =~ s|^($re->{'CEL'}/[^/]+/[^/]+)/.+(/.+)|$1$2|o;
       $HA{$ls1}++ if $ls1 =~ s|(.+)/.+|$1|;
     $ls2 =~ s|^$re->{'CEL'}/[^/]+/[^/]+/(.+)|$1|o;
       $OP{$ls1} = $ls2;
   }
  }
  for my $key(sort keys %HA){
   if( $HA{$key} == 1 ){
     $OP{$key} =~ /^$re->{'CEL'}/o ? print"$OP{$key}\n" : print"$key/$OP{$key}\n";
   }else{
     ( $re->{'INN'} and  $key =~ m|^$re->{'CEL'}/lib$|o ) ?
     print"$key/ ($HA{$key} other file)\n" : print"$key/ ($HA{$key} file)\n";
   }
  }
 Nohup_1( $re );
}

sub Dirs_2{
my( $an,$re ) = @_;
 opendir my $dir,$an or die " N_Dirs $!\n";
  for my $bn(sort readdir($dir)){
   next if $bn =~ /^\.{1,2}$/;
    ( -d "$an/$bn" and not -l "$an/$bn" ) ?
   Dirs_2( "$an/$bn",$re ) : push @{$re->{'ARR'}},"$an/$bn";
  }
 closedir $dir;
}

sub Format_1{
 my $re = shift;
 if( $re->{'TREE'} ){ Format_2( $re );
 }elsif( $re->{'LIST'} or $re->{'PRINT'} ){
  waitpid $re->{'PID2'},0 if $re->{'LINK'} and $re->{'LINK'} == 7 and rmdir "$re->{'HOME'}/WAIT";
  $re->{'ZEN'} = $re->{'ALL'} ? $re->{'ALL'} : $re->{'EXC'} ? $re->{'EXC'} : $re->{'KXC'} ? $re->{'KXC'} : 0;
  if( $re->{'CAS'} ){
    $re->{'ZEN'} = $re->{'ZEN'} =~ m|^\s{10}==>.*\n\s{10}==>.*\n\s{10}==>.*\n$| ? 0 :
    $re->{'ZEN'} =~ m|^(\s{10}==>.*\n)([^=]+)(\s{10}==>.*\n)([^=]+)\s{10}==> .*\n$| ? "$1$2$3$4" :
    $re->{'ZEN'} =~ m|^(\s{10}==>.*\n)([^=]+)\s{10}==>.*\n(\s{10}==> .*\n)([^=]+)$| ? "$1$2$3$4" :
    $re->{'ZEN'} =~ m|^\s{10}==>.*\n(\s{10}==>.*\n)([^=]+)(\s{10}==> .*\n)([^=]+)$| ? "$1$2$3$4" :
    $re->{'ZEN'} =~ m|^(\s{10}==>.*\n)([^=]+)\s{10}==>.*\n\s{10}==> .*\n$| ? "$1$2" :
    $re->{'ZEN'} =~ m|^\s{10}==>.*\n(\s{10}==>.*\n)([^=]+)\s{10}==> .*\n$| ? "$1$2" :
    $re->{'ZEN'} =~ m|^\s{10}==>.*\n\s{10}==>.*\n(\s{10}==> .*\n)([^=]+)$| ? "$1$2" :
    $re->{'ZEN'} =~ m|^\s{10}==>.*\n(\s{10}==> .*\n)([^=]+)$| ? "$1$2" :
    $re->{'ZEN'} =~ m|^(\s{10}==> .*\n)([^=]+)\s{10}==>.*\n$| ? "$1$2" :
    $re->{'ZEN'} =~ m|^\s{10}==>.*\n\s{10}==>.*\n$| ? 0 :
    $re->{'ZEN'} =~ m|^\s{10}==>.*\n$| ? 0 :
    $re->{'ZEN'} if $re->{'TAP'} and ( $re->{'EXC'} or $re->{'KXC'} );
   $re->{'ZEN'} =~ s/(.+)\n\s{10}item.+:.+/$1/
    if $re->{'ZEN'} !~ /item.+:\sinstall[^:]+item.+:\sinstall/;
  }
  if( $re->{'ZEN'} ){
   system " printf '\033[?7l' " if( $re->{'MAC'} and -t STDOUT );
    system 'setterm -linewrap off' if( $re->{'LIN'} and -t STDOUT );
     print" ==> Formula$re->{'SPA'}\n" if $re->{'LINK'} and $re->{'LINK'} > 5 and $re->{'FOR'};
     print" ==> Cask$re->{'SPA'}\n" if $re->{'LINK'} and $re->{'LINK'} > 5 and $re->{'CAS'};
     print $re->{'ZEN'};
     $re->{'ALL'} ? print " item $re->{'AN'} : install $re->{'IN'}\n" :
     $re->{'EXC'} ? print " item $re->{'BN'} : install $re->{'CN'}\n" :
     $re->{'KXC'} ? print " item $re->{'DN'} : install $re->{'DI'}\n" : 0;
   system " printf '\033[?7h' " if( $re->{'MAC'} and -t STDOUT );
    system 'setterm -linewrap on' if( $re->{'LIN'} and -t STDOUT );
  }
 }elsif( $re->{'DAT'} ){
  print for(@{$re->{'OUT'}});
   $re->{'CAS'} = 0;
 }else{
  if( -t STDOUT ){ my( $ls,$sl,$ss,$ze );
   my $leng = $re->{'LEN1'};
    my $tput = `tput cols`;
     my $size = int $tput/($leng+2);
      my $in = 1;
   print" ==> Casks\n" if $re->{'CAS'} and @{$re->{'ARR'}} and $re->{'ARR'}[0] !~ m|homebrew/|;
    print" ==> Formula\n" if $re->{'FOR'} and @{$re->{'ARR'}} and not $re->{'USE'};
     for(my $e=0;$e<@{$re->{'ARR'}};$e++ ){
      if( $re->{'ARR'}[$e] =~ m[^ ==> homebrew/|^ => Formula|^ => Cask]){
       ( not $re->{'KAI'} and $re->{'ARR'}[$e] =~ /^ => Cask/ ) ?
        print"\n$re->{'ARR'}[$e]\n" :
        print"$re->{'ARR'}[$e]\n" if $re->{'ARR'}[$e+1] and $re->{'ARR'}[$e+1] !~ m|^ ==> homebrew/|;
         $in = 1;
      }else{
       if( $re->{'ARR'}[$e] =~ m|^homebrew/cask-fonts/| and not $ls ){
        print"\n" if $ze;
         print" ==> brew tap : homebrew/cask-fonts\n";
          $leng = $re->{'LEN2'};
           $size = int $tput/($leng+2);  $in = $ls = 1;
       }elsif( $re->{'ARR'}[$e] =~ m|^homebrew/cask-drivers/| and not $sl ){
        print"\n" if $ze;
         print" ==> brew tap : homebrew/cask-drivers\n";
          $leng = $re->{'LEN3'};
           $size = int $tput/($leng+2);  $in = $sl = 1;
       }elsif( $re->{'ARR'}[$e] =~ m|^homebrew/cask-versions/| and not $ss ){
        print"\n" if $ze;
         print" ==> brew tap : homebrew/cask-versions\n";
          $leng = $re->{'LEN4'};
           $size = int $tput/($leng+2);  $in = $ss = 1;
       }
       for(my $i=$re->{'LEN'}{$re->{'ARR'}[$e]};$i<$leng+2;$i++){
        $re->{'ARR'}[$e] .= ' ';
       }
        print $re->{'ARR'}[$e];
        unless( $ze = eval "$in % $size" ){
         $re->{'KAI'} = print"\n";
        }elsif( $re->{'ARR'}[$e+1] and $re->{'ARR'}[$e+1] =~ m|^ ==> homebrew/| ){
         print"\n"; $ze = 0;
        }else{
         $re->{'KAI'} = 0;
        }
       $in++;
      }
     }
    print"\n" if $ze;
  }else{
   for(@{$re->{'ARR'}}){
    next if m[^ ==> homebrew/|^ => Formula|^ => Cask];
     print"$_\n";
   }
  }
  $re->{'FOR'} = 0 if $re->{'MAC'};
 }
 print "\033[33m$re->{'FILE'}\033[00m" if $re->{'FILE'} and ( $re->{'ALL'} or $re->{'EXC'} or $re->{'KXC'} );
  Nohup_1( $re ) if $re->{'CAS'} or $re->{'FOR'};
}

sub Format_2{
my $re = shift;
 if( $re->{'TT'} or $re->{'DD'} ){ my( $mm,@tt ); my $e = 0;
  for(my $i=$#{$re->{'UNI'}};$i>=0;$i--){
   $mm = () = ${$re->{'UNI'}}[$i] =~ /\|/g;
   if( $mm == $e or ${$re->{'UNI'}}[$i] =~ /require/ or ${$re->{'UNI'}}[$i] =~ /can delete/ ){
    push @tt,${$re->{'UNI'}}[$i];
     $e = $mm - 1;
   }
  } @{$re->{'UNI'}} = reverse @tt;
 }
 my( $wap,$leng,@TODO,@SC,%ha,@cn ); my $cou = 0;
  $cn[0] = $re->{'INF'};
 for(@{$re->{'UNI'}}){ $wap++;
   if( $re->{'DD'} ){
    my @bn = split '\|';
     $bn[$#bn] =~ s/^-+\s+([^\s]+).+\(can delete\).*\n/$1/ ?
      push @{$SC[$#bn-1]},$bn[$#bn] : push @{$SC[$#bn-1]},0;
       $ha{$bn[$#bn]}++;
        push @cn,$bn[$#bn] if $ha{$bn[$#bn]} < 2;
   }
   s/\|/│/g, s/│--/├──/g if $Locale;
   my @an = split '\\s{3}';
  $cou = @an if $cou < @an;
 }
 unless( $re->{'DDD'} ){
  for(my $i=0;$i<$cou;$i++){
   my $in = $leng = 0;
   for(@{$re->{'UNI'}}){ $leng++;
    my @an = split '\\s{3}';
    for(@an){
     $TODO[$in] = $leng if $an[$i] and $an[$i] =~ /├──|\|--/;
     if( not $an[$i] and $TODO[$in] or
        $wap == $leng and $an[$i] and $an[$i] !~ /├──|\|--/ ){
       $TODO[++$in] = $leng;
      $wap != $leng ? $in++ : last;
     }
    }
   }
    $wap = $leng = 0;
   for(my $p=0;$p<@{$re->{'UNI'}};$p++){
    $wap++; my $plus;
    my @an = split '\\s{3}',${$re->{'UNI'}}[$p];
     for(my $e=0;$e<@an;$e++){
       if( $TODO[$leng] and $TODO[$leng] < $wap and $TODO[$leng+1] >= $wap ){
        $an[$i] =~ s/│$|\|$/#/ if $an[$i];
       }
      $an[$e] =~ s/\|--/`--/ or $an[$e] =~ s/├──/└──/ if $TODO[$leng] and $TODO[$leng] == $wap;
       $leng += 2 if $TODO[$leng+1] and $TODO[$leng+1] == $wap;
      $plus .= "   $an[$e]";
     }
     $plus =~ s/^\s{3}//;
    ${$re->{'UNI'}}[$p] = $plus;
   }
  }
  waitpid $re->{'PID2'},0 if $re->{'DEL'} and rmdir "$re->{'HOME'}/WAIT";
  print"$re->{'INF'}",$re->{'SPA'}x2,"\n" if @{$re->{'UNI'}};
  if( not $re->{'DD'} or -t STDOUT ){
   for(@{$re->{'UNI'}}){ s/#/ /g; print; }
  }
 }
 if( $re->{'DD'} ){ my( %HA,@AR,@AR2,$flag );
  for(my $i=$#SC;$i>=0;$i--){
   for my $key(sort @{$SC[$i]}){
     $HA{$key}++;
    push @{$AR2[$i]},"$key\t" if $key and $HA{$key} < 2;
   }
   push @{$AR2[$i]},0 unless @{$AR2[$i]}[0];
  } my $m = 0;
   $_->[0] ? push @{$AR[$m++]},@{$_} : next for(@AR2);
  if( $re->{'DDD'} ){ my $i;
   waitpid $re->{'PID2'},0 if rmdir "$re->{'HOME'}/WAIT";
   for(@cn){
    my $file = Dirs_1( "$re->{'CEL'}/$_",2 );
     $i++, print" check $re->{'CEL'}/$_  \033[33mbrew cleanup...\033[00m\n" if @$file > 1;
   } exit if $i;
    print STDERR "$re->{'INF'} : deps All delete [y/n]:";
    <STDIN> =~ /^y\n$/ ? system "brew uninstall $re->{'INF'}" : exit;
  }
  for(my $e=0;$e<@AR;$e++){ $flag++;
   if( $re->{'DDD'} ){
    system "brew uninstall @{$AR[$e]}";
   }else{
    -t STDOUT ? printf "%2s : @{$AR[$e]}\n",$flag : print "@{$AR[$e]}\n";
   }
  }
 }
}

sub Format_3{
 my( $file,$re,$line1,$line2,$flag1,$flag2,$ca,$fo ) = @_;
  if( $Locale ){ $line1 = '├──'; $line2 = '└──';
  }else{ $line1 = '|--'; $line2 = '`--'; }

  for(my $m=0;$m<@$file;$m++){
   if( $$file[$m] eq 1 and $$file[$m+1] !~ m|^homebrew/| ){
    $fo .= "  == homebrew/cask-drivers ==\n"; $ca .= "  == homebrew/cask-drivers ==\n";
   }elsif( $$file[$m] eq 2 and $$file[$m+1] !~ m|^homebrew/| ){
    $fo .= "  == homebrew/cask-versions ==\n"; $ca .= "  == homebrew/cask-versions ==\n";
   }  next if $$file[$m] =~ m[^[012]$|^homebrew/];

   my( $name,$ver,$desc ) = split '\t',$$file[$m];
    my @cas = split '\t',$re->{'OS'}{"${name}d_cask"} if $re->{'OS'}{"${name}d_cask"};
    my @fom = split '\t',$re->{'OS'}{"${name}formula"} if $re->{'OS'}{"${name}formula"};
     my $desc1 = $JA{$name} ? $JA{$name} : $re->{'OS'}{"${name}c_desc"} ? $re->{'OS'}{"${name}c_desc"} :
      $desc ? $desc : $re->{'OS'}{"${name}c_name"} ? $re->{'OS'}{"${name}c_name"} : '';
       $name = " \033[33mCan't install $name...\033[00m\n".$name if $re->{'OS'}{"${name}un_cask"};
        my $dn = $re->{'DMG'}{$name} ? ' (I)' : '';

    for(my $i=0;$i<@cas;$i++){ my $tap = $cas[$i];
      $tap =~ s|.+/(.+)|$1|;
       my $in = $re->{'DMG'}{$tap} ? ' (I)' : '';
     my $desc2 = $JA{$tap} ? $JA{$tap} : $re->{'OS'}{"${tap}c_desc"} ?
      $re->{'OS'}{"${tap}c_desc"} : $re->{'OS'}{"${tap}c_name"} ? $re->{'OS'}{"${tap}c_name"} : '';
     $ca .= ( $flag1 and $flag1 eq $name and $i == $#cas and @fom ) ? "$line1 c $cas[$i]$in\t$desc2\n\n" :
            ( $flag1 and $flag1 eq $name and $i == $#cas ) ? "$line2 c $cas[$i]$in\t$desc2\n\n" :
            ( $#cas > 0 or @fom ) ? "$name$dn\t$desc1\n$line1 c $cas[$i]$in\t$desc2\n" :
                                    "$name$dn\t$desc1\n$line2 c $cas[$i]$in\t$desc2\n\n";
        $flag1 = $name;
    }
   if( $re->{'OS'}{"${name}d_cask"} and $re->{'OS'}{"${name}formula"} ){
    for(my $e=0;$e<@fom;$e++){  my $in = $re->{'HASH'}{$fom[$e]} ? ' (I)' : '';
     my $desc3 = $JA{$fom[$e]} ? $JA{$fom[$e]} : $re->{'OS'}{"${fom[$e]}f_desc"} ?
      $re->{'OS'}{"${fom[$e]}f_desc"} : $re->{'OS'}{"${fom[$e]}f_name"} ? $re->{'OS'}{"${fom[$e]}f_name"} : '';
     $ca .= $e == $#fom ? "$line2 f $fom[$e]$in\t$desc3\n\n" : "$line1 f $fom[$e]$in\t$desc3\n";
    }
   }
   unless( $re->{'OS'}{"${name}d_cask"} ){
    for(my $d=0;$d<@fom;$d++){
     my $mem = $re->{'OS'}{"${fom[$d]}alia"} ? $re->{'OS'}{"${fom[$d]}alia"} : $fom[$d];
      my $in = $re->{'HASH'}{$mem} ? ' (I)' : '';
     my $desc4 = $JA{$mem} ? $JA{$mem} : $re->{'OS'}{"${mem}f_desc"} ?
      $re->{'OS'}{"${mem}f_desc"} : $re->{'OS'}{"${mem}f_name"} ? $re->{'OS'}{"${mem}f_name"} : '';
     $fo .= ( $flag2 and $flag2 eq $name and $d == $#fom ) ? "$line2 f $fom[$d]$in\t$desc4\n\n" :
              $#fom > 0 ? "$name$dn\t$desc1\n$line1 f $fom[$d]$in\t$desc4\n" :
                          "$name$dn\t$desc1\n$line2 f $fom[$d]$in\t$desc4\n\n";
        $flag2 = $name;
    }
   }
  }
   system " printf '\033[?7l' " if -t STDOUT;
  print"  ### require Cask and Formula ###\n$ca  ### require Formula ###\n$fo";
   system " printf '\033[?7h' " if -t STDOUT;
 Nohup_1( $re );
}

sub Nohup_1{
my $re = shift;
 ++$re->{'NEW'} and Init_1( $re )
  unless -f "$re->{'HOME'}/font.sh" and -f "$re->{'HOME'}/tie.pl";
 my( $time1,$time2 ) = -f $re->{'TXT'} ?
  ( [localtime],[localtime((stat $re->{'TXT'})[9])] ) : ([0,0,0,0,0,1],[0,0,0,0,0,0]);
   if( $time1->[5] > $time2->[5] or $time1->[4] > $time2->[4] or
       $time1->[3] > $time2->[3] or $time1->[2] > $time2->[2] ){
    system 'nohup ~/.BREW_LIST/font.sh 1 1 >/dev/null 2>&1 &';
   }
 exit;
}

sub Tied_1{
my( $re,$i,@file1,@file2 ) = @_;
 while(my $tap = <DATA>){
  $i++, next if $tap =~ /^__TIE__$/;
   $i ? push @file2,$tap : push @file1,$tap;
 }
 open my $file1,'>',"$re->{'HOME'}/font.sh" or die " Tied1 $!\n";
  print $file1 @file1;
 close $file1;
 open my $file2,'>',"$re->{'HOME'}/tie.pl"  or die " Tied2 $!\n";
  print $file2 @file2;
 close $file2;
  chmod 0755,"$re->{'HOME'}/font.sh";
}
__END__
#!/bin/bash
 NAME=$(uname)
[[ $1 =~ ^[01]$ ]] || ${die:?input 1 error}
[[ ! $2 || $2 =~ ^[12]$ ]] || ${die:?input 2 error}

math_rm(){ [[ $1 ]] && rm -f ~/.BREW_LIST/{master*,*.html,DBM*} || rm -f ~/.BREW_LIST/{master*,*.html}
                       rm -rf ~/.BREW_LIST/{homebrew*,{0..19},WAIT,LOCK} ~/.JA_BREWG; }
if [[ $1 -eq 1 ]];then
 TI=$(date +%s)
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
   git clone https://github.com/konnano/JA_BREW ~/.JA_BREWG || { math_rm; ${die:?git clone error}; }
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
   zip -q ~/.BREW_LIST/keepme.zip ~/.BREW_LIST/master1.zip ~/.BREW_LIST/master2.zip ~/.BREW_LIST/master3.zip ||\
    { rm -f keepme.zip; math_rm; ${die:?zip error}; }
   curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics/install/30d/index.html ||\
    { math_rm; ${die:?curl 6 error}; }
     rmdir ~/.BREW_LIST/4
   curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics/install/90d/index.html ||\
    { math_rm; ${die:?curl 7 error}; }
     rmdir ~/.BREW_LIST/5
   curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics/install/365d/index.html ||\
    { math_rm; ${die:?curl 8 error}; }
     rmdir ~/.BREW_LIST/6
   curl -sko ~/.BREW_LIST/cna1.html https://formulae.brew.sh/analytics/cask-install/30d/index.html ||\
    { math_rm; ${die:?curl 9 error}; }
     rmdir ~/.BREW_LIST/7
   curl -sko ~/.BREW_LIST/cna2.html https://formulae.brew.sh/analytics/cask-install/90d/index.html ||\
    { math_rm; ${die:?curl a error}; }
     rmdir ~/.BREW_LIST/8
   curl -sko ~/.BREW_LIST/cna3.html https://formulae.brew.sh/analytics/cask-install/365d/index.html ||\
    { math_rm; ${die:?curl b error}; }
     rmdir ~/.BREW_LIST/9
  fi

  if [[ $2 -eq 2 ]];then
   unzip -qj ~/.BREW_LIST/keepme.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip error}; }
  fi

   unzip -q ~/.BREW_LIST/master1.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 1 error}; }
   unzip -q ~/.BREW_LIST/master2.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 2 error}; }
   unzip -q ~/.BREW_LIST/master3.zip -d ~/.BREW_LIST || { math_rm; ${die:?unzip 3 error}; }
    rm -rf ~/.BREW_LIST/10

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
EOF
  [[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 1 error};

  if [[ $2 -eq 1 ]];then
perl<<"EOF"
   open $FILE2,'<',"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html" or die " FILE2 $!\n";
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
     $HA1{$an1} = $i1++ if $an1 =~ s|^\s+<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
   }
  close $dir1;
  open $dir2,'<',"$ENV{'HOME'}/.BREW_LIST/cna2.html" or die " cna2 $!\n"; $i2 = 1;
   while( $an2=<$dir2> ){
    next if $an2 =~ /\s--HEAD|\s--with/;
     $HA2{$an2} = $i2++ if $an2 =~ s|^\s+<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
   }
  close $dir2;
  open $dir3,'<',"$ENV{'HOME'}/.BREW_LIST/cna3.html" or die " cna3 $!\n"; $i3 = 1;
   while( $an3=<$dir3> ){
    next if $an3 =~ /\s--HEAD|\s--with/;
     $HA3{$an3} = $i3++ if $an3 =~ s|^\s+<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
   }
  close $dir3;
  for($in1=0;$in1<@ANA;$in1++){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir4,'>',"$ENV{'HOME'}/.BREW_LIST/cna.txt" or die " ana4 $!\n";
   print $dir4 @fom;
  close $dir4;
 rmdir "$ENV{'HOME'}/.BREW_LIST/11"
EOF
  [[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 2 error};
  fi
 else
  curl -so ~/.BREW_LIST/Q_BREW.html https://formulae.brew.sh/formula/index.html || \
   { math_rm; ${die:?curl c error}; }
 curl -sko ~/.BREW_LIST/ana1.html https://formulae.brew.sh/analytics-linux/install/30d/index.html ||\
   { math_rm; ${die:?curl d error}; }
 curl -sko ~/.BREW_LIST/ana2.html https://formulae.brew.sh/analytics-linux/install/90d/index.html ||\
   { math_rm; ${die:?curl e error}; }
 curl -sko ~/.BREW_LIST/ana3.html https://formulae.brew.sh/analytics-linux/install/365d/index.html ||\
   { math_rm; ${die:?curl f error}; }
 fi

 if [[ $2 -eq 1 ]];then
perl<<"EOF"
  open $FILE1,'<',"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html" or die " FILE6 $!\n";
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
     $HA1{$an1} = $i1++ if $an1 =~ s|^\s+<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
   }
  close $dir1;
  open $dir2,'<',"$ENV{'HOME'}/.BREW_LIST/ana2.html" or die " ana2 $!\n"; $i2 = 1;
   while( $an2=<$dir2> ){
    next if $an2 =~ /\s--HEAD|\s--with/;
     $HA2{$an2} = $i2++ if $an2 =~ s|^\s+<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
   }
  close $dir2;
  open $dir3,'<',"$ENV{'HOME'}/.BREW_LIST/ana3.html" or die " ana3 $!\n"; $i3 = 1;
   while( $an3=<$dir3> ){
    next if $an3 =~ /\s--HEAD|\s--with/;
     $HA3{$an3} = $i3++ if $an3 =~ s|^\s+<td><a[^>]+><code>(.+)</code></a></td>\n|$1|;
   }
  close $dir3;
  for($in1=0;$in1<@ANA;$in1++){
   $fom[$in1]  = $ANA[$in1];
   $fom[$in1] .= $HA1{$ANA[$in1]} ? "\t$HA1{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA2{$ANA[$in1]} ? "\t$HA2{$ANA[$in1]}" : "\t";
   $fom[$in1] .= $HA3{$ANA[$in1]} ? "\t$HA3{$ANA[$in1]}\n" : "\t\n";
  }
  open $dir4,'>',"$ENV{'HOME'}/.BREW_LIST/ana.txt" or die " ana4 $!\n";
   print $dir4 @fom;
  close $dir4;
EOF
 [[ $? -ne 0 ]] && math_rm 1 && ${die:?perl 3 error};

  rm -rf  ~/.BREW_LIST/12
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
 math_rm
fi
__TIE__
use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my( $IN,$KIN,$SPA ) = ( 0,0,0 );
chomp( my $UNAME = `uname -m` );
my $CPU = $UNAME =~ /arm64/ ? 'arm\?' : 'intel\?';
my( $re,$OS_Version,$OS_Version2,%MAC_OS,%HAN,$Xcode,$RPM,$CAT,@BREW,@CASK );

if( $^O eq 'darwin' ){ $re->{'MAC'} = 1;
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/^(10\.1[0-5]).*\n/$1/;
   $OS_Version =~ s/^10\.9.*\n/10.09/;
    $OS_Version =~ s/^11.+\n/11.0/;
     $OS_Version =~ s/^12.+\n/12.0/;
 $OS_Version2 = $OS_Version;
  $OS_Version2 = "${OS_Version}M1" if $CPU eq 'arm\?';

unless( $ARGV[0] ){
 $Xcode = `xcodebuild -version 2>/dev/null` ?
  `xcodebuild -version|awk '/Xcode/{print \$NF}'` : 0;
    $Xcode =~ s/^(\d\.)/0$1/;
 $re->{'CLANG'} = `/usr/bin/clang --version|sed '/Apple/!d' 2>/dev/null` ?
                  `/usr/bin/clang --version|sed '/Apple/!d;s/.*clang-\\([^.]*\\).*/\\1/'` : 0;
 $re->{'CLT'} = `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null` ?
                `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables|\
                 sed '/version/!d;s/[^0-9]*\\([0-9]*\\.[0-9]*\\).*/\\1/'` : 0;
}
  %MAC_OS = ('monterey'=>'12.0','big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14',
             'high_sierra'=>'10.13','sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10',
             'mavericks'=>'10.09','mountain_lion'=>'10.08','lion'=>'10.07');
     %HAN = ('newer'=>'>','older'=>'<');

  if( $CPU eq 'intel\?' and -d '/usr/local/Cellar' ){
   unless( $ARGV[0] ){ $re->{'CEL'} = '/usr/local/Cellar';
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
     Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
       Dirs_1( '/usr/local/Homebrew/Library/Taps',1,0 );
   }
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew',1,1 );
  }else{
   unless( $ARGV[0] ){ $re->{'CEL'} = 'opt/homebrew/Cellar';
    Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
     Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
       Dirs_1( '/opt/homebrew/Library/Taps',1,0 );
   }
    Dirs_1( '/opt/homebrew/Library/Taps/homebrew',1,1 );
  }
 rmdir "$ENV{'HOME'}/.BREW_LIST/13";
}else{ $re->{'LIN'} = 1;
 $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
  $RPM = `ldd --version 2>/dev/null` ? `ldd --version|awk '/ldd/{print \$NF}'` : 0;
   $CAT = `cat ~/.BREW_LIST/brew.txt 2>/dev/null` ? `cat ~/.BREW_LIST/brew.txt|awk '/glibc\t/{print \$2}'` : 0;
    $OS_Version2 = $UNAME =~ /x86_64/ ? 'Linux' : $UNAME =~ /arm64/ ? 'LinuxM1' : 'Linux32';
 Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
  Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
   Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps',1,0 );
}

sub Dirs_1{
my( $dir,$ls,$cask ) = @_;
 for(glob "$dir/*"){
  next if $ls and m[/homebrew$|/homebrew-core$|/homebrew-cask$|/homebrew-bundle$|/homebrew-services$];
   ( -d ) ? Dirs_1( $_,$ls,$cask ) : ( -l ) ? push @{$re->{'ALIA'}},$_ :
   ( /\.rb$/ and $cask ) ? push @CASK,$_ : ( /\.rb$/ ) ? push @BREW,$_ : 0;
 }
}

 my $DBM = $ARGV[0] ? 'DBM' : 'DBMG';
tie my %tap,'NDBM_File',"$ENV{'HOME'}/.BREW_LIST/$DBM",O_RDWR|O_CREAT,0666 or die " tie DBM $!\n";
unless( $ARGV[0] ){
 for my $alias(@{$re->{'ALIA'}}){
  my $hand = readlink $alias;
  $alias =~ s|.+/(.+)|$1|;
   $hand =~ s|.+/(.+)\.rb|$1|;
  $tap{"${alias}alia"} = $hand;
 } my( $in,$e ) = int @BREW/4;
 for my $dir1(@BREW){
  if( $re->{'MAC'} ){ $e++;
   $e == $in ? rmdir "$ENV{'HOME'}/.BREW_LIST/14" :
   $e == $in*2 ? rmdir "$ENV{'HOME'}/.BREW_LIST/15" :
   $e == $in*3 ? rmdir "$ENV{'HOME'}/.BREW_LIST/16" : 0;
  }
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb|;
   $tap{"${name}core"} = $dir1;
  open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
   while(my $data=<$BREW>){
     if( $data =~ /^\s*bottle\s+do/ ){
      $KIN = 1; next;
     }elsif( $data =~ /^\s*rebuild/ and $KIN == 1 ){
       next;
     }elsif( $data !~ /^\s*end/ and $KIN == 1 ){
       if( $data =~ /.*,\s+all:/ ){
        $tap{"${name}12.0M1"} = $tap{"${name}12.0"} =
        $tap{"${name}11.0M1"} = $tap{"${name}11.0"} = $tap{"${name}10.15"} =
        $tap{"${name}10.14"} = $tap{"${name}10.13"} = $tap{"${name}10.12"} =
        $tap{"${name}10.11"} = $tap{"${name}10.10"} = $tap{"${name}10.09"} =
        $tap{"${name}Linux"} = 1;
       }
        $tap{"$name$data"} =
        $data =~ s/.*arm64_monterey:.*\n/12.0M1/ ? 1 :
        $data =~ s/.*monterey:.*\n/12.0/         ? 1 :
        $data =~ s/.*arm64_big_sur:.*\n/11.0M1/  ? 1 :
        $data =~ s/.*big_sur:.*\n/11.0/          ? 1 :
        $data =~ s/.*catalina:.*\n/10.15/        ? 1 :
        $data =~ s/.*mojave:.*\n/10.14/          ? 1 :
        $data =~ s/.*high_sierra:.*\n/10.13/     ? 1 :
        $data =~ s/.*sierra:.*\n/10.12/          ? 1 :
        $data =~ s/.*el_capitan:.*\n/10.11/      ? 1 :
        $data =~ s/.*yosemite:.*\n/10.10/        ? 1 :
        $data =~ s/.*x86_64_linux:.*\n/Linux/    ? 1 : next; # x86_64
       next;
     }elsif( $data =~ /^\s*end/ and $KIN == 1 ){
      $KIN = 0; next;
     }
   if( $data !~ /^\s*end/ and $IN ){ $SPA++ if $data =~ /\s+do$/; next;
   }elsif( $data =~ /^\s*end/ and $SPA > 1 and $IN ){ $SPA--; next;
   }elsif( $data =~ /^\s*end/ and $IN ){ $SPA = $IN = 0; next;
   }
    if( $re->{'MAC'} ){
      $SPA = $IN = 1, next if $data =~ /^\s*on_linux\s+do/;
    }else{
      $SPA = $IN = 1, next if $data =~ /^\s*on_macos\s+do/;
    }
     if( $data =~ /^\s*head\s+do/ ){ $SPA = $IN = 1; next;
     }elsif( $data =~ /^\s*on_intel\s+do/ and $UNAME =~ /arm64/ or
             $data =~ /^\s*on_arm\s+do/ and $UNAME =~ /x86_64/ ){ $SPA = $IN = 1; next;
     }elsif( my( $ha1,$ha2 ) = $data =~ /^\s*on_([^\s]+)\s+:or_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $re->{'LIN'} or eval "$MAC_OS{$ha1} $HAN{$ha2} $OS_Version"; next;
     }elsif( my( $ha3,$ha4 ) = $data =~ /^\s+on_system\s+:linux,\s+macos:\s+:(.+)_or_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $re->{'MAC'} and eval "$MAC_OS{$ha3} $HAN{$ha4} $OS_Version"; next;
     }

      if( my( $ls1,$ls2 ) =
        $data =~ /^\s*depends_on\s+xcode:.+if\s+MacOS::CLT\.version\s+([^\s]+)\s+"([^"]+)"/ ){
         if( $re->{'MAC'} and
             not $Xcode and $ls1 =~ /^[<=>]+$/ and $ls2 =~ /^\d+\.\d+$/ and eval "$re->{'CLT'} $ls1 $ls2" ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ s/^\s*depends_on\s+xcode:.+"([^"]+)",\s+:build.*\n/$1/ ){
         $data =~ s/^(\d\.)/0$1/;
         if( $re->{'MAC'} and $data gt $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ /^\s*depends_on\s+xcode:\s+:build/ ){
         if( $re->{'MAC'} and not $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ s/^\s*depends_on\s+xcode:\s*"([^"]+)".*\n/$1/ ){
        $data =~ s/^(\d\.)/0$1/;
         if( $re->{'MAC'} and $data gt $Xcode ){
           $tap{"${name}un_xcode"} = 1;
            $tap{"$name$OS_Version2"} = 0;
         }elsif( $re->{'LIN'} ){
           $tap{"${name}un_Linux"} = 1;
            $tap{"${name}Linux"} = 0; # bottle
         } next;
      }elsif( $data =~ s/\s*depends_on\s+arch:\s+:([^\s]+).*\n/$1/ and $UNAME ne $data ){
          $tap{"${name}un_xcode"} = $tap{"${name}un_Linux"} =1;
          $tap{"$name$OS_Version2"} = $tap{"${name}Linux"} = 0;
           next;
      }

     if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
         next;
     }elsif( $re->{'MAC'} and my( $ds,$ds1,$ds2,$ds3 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build.+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+).+CPU\.([^\s]+)/ ){
        if( $ds1 =~ /^[<=>]+$/ and $ds2 =~ /^\d+$/ and eval "$re->{'CLANG'} $ds1 $ds2" and $CPU eq $ds3 ){
         $tap{"${ds}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds\t";
        }
     }elsif( $re->{'MAC'} and my( $ds4,$ds5,$ds6 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
        if( $ds5 =~ /^[<=>]+$/ and $ds6 =~ /^\d+$/ and eval "$re->{'CLANG'} $ds5 $ds6" ){
         $tap{"${ds4}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds4\t";
        }
     }elsif( $re->{'MAC'} and my( $ds7,$ds8,$ds9 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
        if( $ds8 =~ /^[<=>]+$/ and $ds9 =~ /^\d+$/ and eval "$re->{'CLANG'} $ds8 $ds9" ){
         $tap{"${ds7}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds7\t";
        }
     }elsif( $re->{'MAC'} and $data =~ s/^\s*depends_on\s+"([^"]+)".+MacOS\.version\.outdated_release\?\n/$1/ ){
       push @{$re->{'OS'}},"$name,$data";
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
       $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
        $tap{"${name}deps_b"} .= "$data\t";
     }elsif( my( $us1,$us2 ) =
       $data =~ /^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build,\s+since:\s+:([^\s]+)/ ){
        if( $re->{'LIN'} or $OS_Version < $MAC_OS{$us2} ){
         $tap{"${us1}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$us1\t";
        }
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
        $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         $tap{"${name}deps_b"} .= "$data\t";
     }elsif( my( $us3,$us4 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+)/ ){
       if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$us4} ){
        $tap{"${us3}uses"} .= "$name\t";
         $tap{"${name}deps"} .= "$us3\t";
       }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
     }elsif( $re->{'LIN'} and
             my( $us5,$us6 ) = $data =~ /^\s*depends_on\s+"([^"]+)".+OS::Linux[^\s]+\s+([^\s]+).+/ ){
      if( $us6 =~ /^[<=>]$/ and eval "$RPM $us6 $CAT" ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
      }
     }elsif( $re->{'LIN'} and
             my( $us7 ) = $data =~ /^\s*depends_on\s+"([^"]+)".*\["glibc"]\.any_version_installed/ ){
      if( `which /home/linuxbrew/.linuxbrew/bin/glibc 2>/dev/null` ){
       $tap{"${us7}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$us7\t";
      }
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
         push @{$re->{'OS'}},"$name,$data,1";
     }

      if( $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_version"} = $data;
      }elsif( $data =~ s/^\s*desc\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_desc"} = $data;
      }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_name"} = $data;
      }elsif( $data =~ s/^\s*revision\s+(\d+).*\n/$1/ ){
        $tap{"${name}revision"} = "_$data";
      }

    if( $data =~ /^\s*keg_only.*macos/ ){
      $tap{"${name}keg"} = 1;
    }elsif( $data =~ /^\s*keg_only/ ){
      $tap{"${name}keg_Linux"} = $tap{"${name}keg"} = 1;
    }elsif( $data =~ /^\s*depends_on\s+:macos/ ){
      $tap{"${name}un_Linux"} = 1; $tap{"${name}Linux"} = 0;
    }elsif( $data =~ /^\s*depends_on\s+:linux/ ){
      $tap{"${name}un_xcode"} = 1;
    }elsif( my( $cs1,$cs2,$cs3 ) =
           $data =~ /^\s*depends_on\s+macos:\s+:([^\s]*)\s+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
     $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and
      $cs2 =~ /^[<=>]$/ and $cs3 =~ /^\d+$/ and eval "$re->{'CLANG'} $cs2 $cs3" and $MAC_OS{$cs1} > $OS_Version;
       $tap{"${name}USE_OS"} = $cs1;
    }elsif( $data =~ s/^\s*depends_on\s+macos:\s+:([^\s]*).*\n/$1/ ){
      $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and $OS_Version and $MAC_OS{$data} > $OS_Version;
       $tap{"${name}USE_OS"} = $data;
    }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[?:([^,\s]+).*\n/$1/ ){
      $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and $OS_Version and $MAC_OS{$data} < $OS_Version;
    }
   }
  close $BREW;
 }
 if( $re->{'MAC'} ){ my %HA;
  rmdir "$ENV{'HOME'}/.BREW_LIST/17";
  for(@{$re->{'OS'}}){
   my( $name,$data,$ls ) = split ',';
   if( not $ls and $MAC_OS{$tap{"${data}USE_OS"}} <= $OS_Version ){
    $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
     $tap{"${name}deps_b"} .= "$data\t";
   }elsif( $ls and $tap{"${data}USE_OS"} and $MAC_OS{$tap{"${data}USE_OS"}} > $OS_Version ){
    Uses_1( $name,\%HA );
   }
  }
 }
 sub Uses_1{
 my( $name,$HA ) = @_;
  for my $ls(split '\t',$name){
   $HA->{$ls}++;
   if( $HA->{$ls} < 2 ){
    $tap{"$ls$OS_Version2"} = 0 if $tap{"$ls$OS_Version2"};
     $tap{"${ls}un_xcode"} = 1;
   }
   Uses_1( $tap{"${ls}uses"},$HA ) if $tap{"${ls}uses"}
  }
 }
 sub Glob_1{
 my( $brew,$mine,$loop,$in ) = @_;
  my @GLOB = $brew ? glob "$re->{'CEL'}/$brew/*" : glob "$re->{'CEL'}/*/*";
  for(@GLOB){ my($name) = m|$re->{'CEL'}/([^/]+)/.*|;
   if( -f "$_/INSTALL_RECEIPT.json" ){
    open my $CEL,'<',"$_/INSTALL_RECEIPT.json" or die " GLOB $!\n";
     while(<$CEL>){
      unless( /\n/ or /^}$/ ){
       s/.+"runtime_dependencies":\[([^]]*)].+/$1/;
       my @HE = /{"full_name":"([^"]+)","version":"[^"]+"}/g;
       for my $ls1(@HE){ my %HA;
        if( $tap{"${ls1}uses"} ){
         for(split '\t',$tap{"${ls1}uses"}){ $HA{$_}++; }
        }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls1 eq $mine;
         }else{ next unless Glob_1( $ls1,$name,1 );
          $tap{"${ls1}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls1\t";
         }
        }
       }
      }else{ my %HA;
       if( /runtime_dependencies/ or $in ){ $in = /]/ ? 0 : 1;
        my( $ls2 ) = /"full_name":\s*"([^"]+)".*/ ? $1 : next;
        if( $tap{"${ls2}uses"} ){
         for(split '\t',$tap{"${ls2}uses"}){ $HA{$_}++; }
        }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls2 eq $mine;
         }else{ next unless Glob_1( $ls2,$name,1 );
          $tap{"${ls2}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls2\t";
         }
        }
       }
      }
     }
    close $CEL;
   }
  }1;
 } Glob_1;
 if( $RPM and $RPM gt $CAT ){
  $tap{'glibcun_Linux'} = 1;
   $tap{'glibcLinux'} = 0;
 }
}

 if( $re->{'MAC'} ){
 rmdir "$ENV{'HOME'}/.BREW_LIST/18";
 my( $IN,$in,$e ) = ( 0,int @CASK/2,0 );
  for my $dir2(@CASK){
   rmdir "$ENV{'HOME'}/.BREW_LIST/19" if $in == $e++;
   my( $name ) = $dir2 =~ m|.+/(.+)\.rb|;
    $tap{"${name}cask"} = $dir2;
     my( $IF1,$IF2,$ELIF,$ELS ) = ( 1,0,0,0 );
    $tap{"${name}d_cask"} = $tap{"${name}formula"} = '';
   open my $BREW,'<',$dir2 or die " tie Info_2 $!\n";
    while(my $data=<$BREW>){
     if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ ){
       $tap{"${name}un_cask"} = 1 unless $ls1 !~ /^[<=>]+$/ or eval "$OS_Version $ls1 $MAC_OS{$ls2}";
     }elsif( $data =~ s/^\s*depends_on\s+formula:\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}formula"} .= "$data\t";
        $tap{"${data}u_form"} .= "$name\t";
     }elsif( $data =~ /^\s*depends_on\s+cask:\s+/ or $IN ){
      if( $data =~ /^\s*depends_on\s+cask:\s+\[/ ){ $IN = 1; next; }
       if( $data =~ /^\s*\]/ ){ $IN = 0; next; }
      $data =~ s/^\s*"([^"]+)".*\n/$1/;
       $data =~ s/^\s*depends_on\s+cask:\s+"([^"]+)".*\n/$1/;
        $tap{"${name}d_cask"} .= "$data\t";
         $data =~ s|.+/([^/]+)|$1|;
          $tap{"${data}u_cask"} .= "$name\t";
     }elsif( my( $ls4,$ls5 ) = $data =~ /^\s*if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
       $IF1 = 0; $ELIF = $ELS = 1;
       if( $ls4 =~ /^[<=>]+$/ and eval "$OS_Version $ls4 $MAC_OS{$ls5}" ){
        $ELS = $ELIF = 0; $IF2 = 1;
       }
     }elsif( my( $ls6,$ls7 ) = $data =~ /^\s*elsif\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ and $ELIF ){
       if( $ls6 =~ /^[<=>]+$/ and eval "$OS_Version $ls6 $MAC_OS{$ls7}" ){
        $ELS = $ELIF  = 0; $IF2 = 1;
       }
     }elsif( $data =~ /^\s*else/ and $ELS ){
       $IF2 = 1;
     }elsif(( $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ or
              $data =~ s/^\s*version\s+:([^\s]+).*\n/$1/ ) and ( $IF1 or $IF2 )){
       $tap{"${name}c_version"} = $data;
        $IF1 = $IF2 = 0;
     }elsif( $data =~ s/^\s*desc\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_desc"} = $data;
     }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_name"} = $data;
     }
    }
   close $BREW;
  }
 }
unless( $ARGV[0] ){
 open my $FILE,'<',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE $!\n";
  my @LIST = <$FILE>;
 close $FILE;

 @BREW = sort map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @BREW;
 @CASK = sort map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @CASK if $re->{'MAC'};

  my $COU = $IN = 0;
 for(my $i=0;$i<@BREW;$i++){
   for(;$COU<@LIST;$COU++){
    my( $ls1,$ls2,$ls3 ) = split '\t',$LIST[$COU];
     last if $BREW[$i] lt $ls1;
      if( $BREW[$i] eq $ls1 ){
       $tap{"${BREW[$i]}ver"} = $tap{"${BREW[$i]}revision"} ? $ls2.$tap{"${BREW[$i]}revision"} : $ls2;
       $COU++; last;
      }
   }
   unless( $tap{"${BREW[$i]}ver"} ){
    $tap{"${BREW[$i]}ver"} = ( $tap{"${BREW[$i]}f_version"} and $tap{"${BREW[$i]}revision"} ) ?
     $tap{"${BREW[$i]}f_version"}.$tap{"${BREW[$i]}revision"} : $tap{"${BREW[$i]}f_version"} ?
      $tap{"${BREW[$i]}f_version"} : 0;
   }
   if( $re->{'MAC'} ){
     for(;$IN<@CASK;$IN++){
      last if $BREW[$i] lt $CASK[$IN];
       if($BREW[$i] eq $CASK[$IN]){
        $tap{"${CASK[$IN]}so_name"} = 1;
        $IN++; last;
       }
     }
   }
 }
}
untie %tap;
