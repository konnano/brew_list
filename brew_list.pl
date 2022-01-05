#!/usr/bin/env perl
use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';
my( $OS_Version,$OS_Version2,$CPU,%MAC_OS );

MAIN:{
 my $HOME = "$ENV{'HOME'}/.BREW_LIST";
 my $re  = { 'LEN1'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,'UP'=>0,'UNI'=>[],
             'CEL'=>'/usr/local/Cellar','BIN'=>'/usr/local/opt',
             'HOME'=>$HOME,'TXT'=>"$HOME/brew.txt" };

 my $ref = { 'LEN1'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,'UP'=>0,
             'CEL'=>'/usr/local/Caskroom','LEN2'=>1,'LEN3'=>1,'LEN4'=>1,
             'HOME'=>$HOME,'TXT'=>"$HOME/cask.txt",'Q_TAP'=>"$HOME/Q_TAP.txt"};

 $^O eq 'darwin' ? $re->{'MAC'} = $ref->{'MAC'}= 1 :
  $^O eq 'linux' ? $re->{'LIN'} = 1 : exit;

 my @AR = @ARGV; my $name;
  Died_1() unless $AR[0];
 if( $AR[0] eq '-l' ){      $name = $re;  $re->{'LIST'}  = 1;
 }elsif( $AR[0] eq '-i' ){  $name = $re;  $re->{'PRINT'} = 1;
 }elsif( $AR[0] eq '-c' ){  $name = $ref; $ref->{'LIST'} = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-ci'){  $name = $ref; $ref->{'PRINT'}= 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-ct'){  $name = $ref; $ref->{'LIST'} = $ref->{'TAP'} = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-lx' ){ $name = $re;  $re->{'LIST'}  = 1; $re->{'LINK'} = $re->{'MAC'} ? 1 : 2;
 }elsif( $AR[0] eq '-lb' ){ $name = $re;  $re->{'LIST'}  = 1; $re->{'LINK'} = 3;
 }elsif( $AR[0] eq '-cx' ){ $name = $ref; $ref->{'LIST'} = 1; $ref->{'LINK'}= 4; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-cs' ){ $name = $ref; $ref->{'LIST'} = 1; $ref->{'LINK'}= 5; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-in' ){ $name = $re;  $re->{'LIST'}  = 1; $re->{'LINK'} = 6; $re->{'INF'} = 1;
 }elsif( $AR[0] eq '-de' ){ $name = $re;  $re->{'INF'} = $re->{'DEL'} = 1; $re->{'LINK'} = 7;
 }elsif( $AR[0] eq '-t' ){  $name = $re;  $re->{'INF'} = $re->{'TREE'}= 1;
 }elsif( $AR[0] eq '-d' ){  $name = $re;  $re->{'INF'} = $re->{'DEL'} = 1;
 }elsif( $AR[0] eq '-u' ){  $name = $re;  $re->{'USE'}  = 1;
 }elsif( $AR[0] eq '-ua' ){ $name = $re;  $re->{'USES'} = 1;
 }elsif( $AR[0] eq '-co' ){ $name = $re;  $re->{'COM'}  = 1;
 }elsif( $AR[0] eq '-new' ){$name = $re;  $re->{'NEW'}  = 1;
 }elsif( $AR[0] eq '-o' ){  $re->{'DAT'}= $ref->{'DAT'} = 1;
 }elsif( $AR[0] eq '-g' ){  $re->{'TOP'}= $ref->{'TOP'} = 1;
 }elsif( $AR[0] eq '-' ){   $re->{'BL'} = $ref->{'BL'}  = 1;
 }elsif( $AR[0] eq '-s' ){  $re->{'S_OPT'} = 1;
 }else{  Died_1();
 }

  $CPU = `uname -m` =~ /arm64/ ? 'arm\?' : 'intel\?';
 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
    $OS_Version = 'Linux';
 }else{
  $OS_Version = `sw_vers -productVersion`;
   $OS_Version =~ s/^(10\.1\d)\.?\d*\n/$1/;
    $OS_Version =~ s/^(10\.)([7-9])\.?\d*\n/${1}0$2/;
     $OS_Version =~ s/^11.+\n/11.0/;
      $OS_Version =~ s/^12.+\n/12.0/;
  $OS_Version2 = $OS_Version;
   $OS_Version = "${OS_Version}M1" if $CPU eq 'arm\?';
  $ref->{'VERS'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-versions';
   $ref->{'DDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
    $ref->{'FDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
  %MAC_OS = ('monterey'=>'12.0','big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14',
             'high_sierra'=>'10.13','sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10');
 }
 $re->{'LC'} = $ref->{'LC'} = 1 if `printf \$LC_ALL \$LC_CTYPE \$LANG 2>/dev/null` =~ /utf8$|utf-8$/i;

 if( $re->{'MAC'} and $CPU eq 'arm\?' ){
  $re->{'CEL'} = '/opt/homebrew/Cellar';
   $re->{'BIN'} = '/opt/homebrew/opt';
    $ref->{'CEL'} = '/opt/homebrew/Caskroom';
  $ref->{'VERS'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-versions';
   $ref->{'DDIR'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
    $ref->{'FDIR'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
 }
 exit unless -d $re->{'CEL'};
  print " not exists cask tap\n"
   unless not $ref->{'TAP'} or $ref->{'FDIR'} or $ref->{'DDIR'} or $ref->{'VERS'};

 if( $AR[1] and $AR[1] =~ m!/.*(\\Q|\\E).*/!i ){
  $AR[1] !~ /.*\\Q.+\\E.*/ ? die" nothing in regex\n" :
   $AR[1] =~ s|/(.*)\\Q(.+)\\E(.*)/|/$1\Q$2\E$3/|;
 }
 if( $AR[1] and my( $reg )= $AR[1] =~ m|^/(.+)/$| ){
  die" nothing in regex\n" 
   if system "perl -e '$AR[1]=~/$reg/' 2>/dev/null" or
    $AR[1] =~ m!/\^\*\[\+\*](\+|\*)+/|\[\.\.\.]!;
 }

 if( $re->{'NEW'} or $re->{'MAC'} and not -f "$re->{'HOME'}/DBM.db" or
     $re->{'LIN'} and not -f "$re->{'HOME'}/DBM.pag" or not -d $re->{'HOME'} ){
   die " exist \033[31mLOCK\033[00m\n" if -d "$re->{'HOME'}/LOCK";
    $re->{'NEW'}++; Init_1( $re );
 }elsif( $re->{'COM'} or $re->{'INF'} or $AR[1] and $name->{'LIST'} ){
  if( $re->{'INF'} ){
   $AR[1] ? $re->{'INF'} = lc $AR[1] : Died_1();
   $re->{'CLANG'} = `clang --version|awk '/Apple/'|sed 's/.*-\\([^.]*\\)\\..*/\\1/'` if $re->{'MAC'};
  }else{
   $AR[1] ? $re->{'STDI'} = lc $AR[1] : Died_1();
    $name->{'L_OPT'} = $re->{'STDI'} =~ s|^/(.+)/$|$1| ? $re->{'STDI'} : "\Q$re->{'STDI'}\E";
  }
 }elsif( $re->{'S_OPT'} ){
  $AR[1] ? $ref->{'STDI'} = lc $AR[1] : Died_1();
   $re->{'S_OPT'} = $ref->{'S_OPT'} =
    $ref->{'STDI'} =~ s|^/(.+)/$|$1| ? $ref->{'STDI'} : "\Q$ref->{'STDI'}\E";
 }elsif( $re->{'USE'} ){
  $AR[1] ? $re->{'USE'} = lc $AR[1] : Died_1();
 }elsif( $re->{'USES'} ){
  $AR[1] ? $re->{'USE'} = $re->{'USES'} = lc $AR[1] : Died_1();
 }
 Fork_1( $name,$re,$ref );
}

sub Fork_1{
my( $name,$re,$ref ) = @_;
 if( $re->{'LIN'} ){
  Init_1( $re ); Format_1( $re );
 }elsif( $re->{'S_OPT'} or $re->{'BL'} or $re->{'DAT'} or $re->{'TOP'} ){
  my $pid = fork;
  die " Not fork : $!\n" unless defined $pid;
   if($pid){
    Init_1( $ref );
   }else{
    Init_1( $re );
   }
   if($pid){
    waitpid($pid,0);
    Format_1( $ref );
   }else{
    Format_1( $re ); exit;
   }
 }else{ Init_1( $name ); Format_1( $name );
 }
}

sub Died_1{
 die " Enhanced brew_list : version 1.02_1\n   Option\n  -new\t:  creat new cache
  -l\t:  formula list\n  -i\t:  instaled formula\n  -\t:  brew list command
  -lb\t:  bottled install formula\n  -lx\t:  can't install formula
  -s\t:  type search name\n  -o\t:  outdated\n  -co\t:  library display
  -in\t:  formula require formula\n  -t\t:  formula require formula, display tree
  -u\t:  formula depend on formula\n  -ua\t:  formula depend on formula, all
  -de\t:  uninstalled not require formula\n  -d\t:  uninstalled not require formula, display tree
  -g\t:  Independent formula\n    Only mac : Cask
  -c\t:  cask list\n  -ct\t:  cask tap list\n  -ci\t:  instaled cask
  -cx\t:  can't install cask\n  -cs\t:  some name cask and formula\n";
}

sub Init_1{
my( $re,$list ) = @_;
 if( $re->{'NEW'} ){
  die " \033[31mNot connected\033[00m\n"
   if system 'curl -k https://formulae.brew.sh/formula >/dev/null 2>&1';
  Wait_1( $re ); 
 }
 DB_1( $re );
  DB_2( $re ) unless $re->{'BL'} or $re->{'S_OPT'} or $re->{'COM'};
   Dele_1( $re ) if $re->{'DEL'};
    Info_1( $re ) if $re->{'INF'};
     return if $re->{'TREE'};

 $list = ( $re->{'S_OPT'} or $re->{'BL'} or $re->{'TOP'} ) ?
  Dirs_1( $re->{'CEL'},1 ) : $re->{'USE'} ? [] : Dirs_1( $re->{'CEL'},0,$re );
 @$list = split '\t',$re->{'OS'}{"$re->{'USE'}uses"} if $re->{'USE'} and $re->{'OS'}{"$re->{'USE'}uses"}; 

 $re->{'COM'} ? Command_1( $re,$list ) : ( $re->{'BL'} or $re->{'USE'} ) ?
   Brew_1( $re,$list ) : $re->{'TOP'} ? Top_1( $re,$list ) : File_1( $re,$list );
}

sub Wait_1{
my $re = shift;
 mkdir $re->{'HOME'};
 mkdir "$re->{'HOME'}/WAIT";
  my( $dok,$not,@ten ) = $re->{'LC'} ?
   ( "\r \033[36m✔︎\033[00m : Creat new cache\n","\r \033[31m✖︎\033[00m : Can not Create \n",
    ('⣸','⣴','⣦','⣇','⡏','⠟','⠻','⢹') ) :
   ( "\r \033[36mo\033[00m : Creat new cache\n","\r \033[31mx\033[00m : Can not Create \n",
    ('|','/','-','\\','|','/','-','\\') );
  my $pid = fork;
 die " Wait Not fork : $!\n" unless defined $pid;
  if($pid){
   print STDERR "\x1B[?25l";
   if( $^O eq 'linux' ){ my $i = 0;
     while(1){ $i = $i % 8; my $c = int(rand 6) + 1;
      -d "$re->{'HOME'}/WAIT" ?
       print STDERR "\r \033[3${c}m$ten[$i]\033[00m : Makes new cache" : last;
        $i++; system 'sleep 0.1';
     }
   }else{ my $i = 0; my $ma = ''; my $spa = ' ' x 10;
     while(1){
     printf STDERR "\r[%2d/10] '\033[33m%s\033[00m%s'",$i,$ma,$spa;
      sleep 1 and last unless -d "$re->{'HOME'}/WAIT";
       if( -d "$re->{'HOME'}/$i" ){
        while(1){
         last unless -d "$re->{'HOME'}/$i";
          system 'sleep 0.001';
        } $i++; $ma .= '#'; $spa =~ s/\s//;
       }
     }
   } waitpid($pid,0);
       print STDERR "\x1B[?25h";
     ( $^O eq 'darwin' and -f "$re->{'HOME'}/DBM.db" or
       $^O eq 'linux' and -f "$re->{'HOME'}/DBM.dir" ) ? die $dok : die $not;
  }else{
   Tied_1( $re ); system '~/.BREW_LIST/font.sh'; exit;
  }
}

sub DB_1{
my $re = shift;
 if( $re->{'FOR'} ){
  opendir my $dir,$re->{'BIN'} or die " DB_1 $!\n";
   for my $com(readdir $dir){
    my $hand = readlink "$re->{'BIN'}/$com";
     next if not $hand or $hand !~ m|^\.\./Cellar/|;
    my( $an,$bn ) = $hand =~ m|^\.\./Cellar/(.+)/(.+)|;
    $re->{'HASH'}{$an} = $bn;
   }
  closedir $dir;
 }else{
  my $dirs = Dirs_1( '/usr/local/Caskroom',1 );
  for(my $in=0;$in<@$dirs;$in++){
   my( $name ) = $$dirs[$in] =~ /^\s(.+)\n/;
   if( $name and -d "/usr/local/Caskroom/$name/.metadata" ){
    my $meta = Dirs_1( "/usr/local/Caskroom/$name/.metadata",1 );
     ($re->{'DMG'}{$name}) = $$meta[0] =~ /^\s(.+)\n/;
   }
  }
 }
}

sub DB_2{
my( $re,%NA ) = @_;
 tie my %tap,"NDBM_File","$re->{'HOME'}/DBM",O_RDONLY,0;
   %NA = %tap;
  untie %tap;
 $re->{'OS'} = %NA ? \%NA : die " Not read DBM\n";
}

sub Dirs_1{
my( $url,$ls,$re,$bn ) = @_;
 my $an = [];
 opendir my $dir_1,"$url" or die " Dirs_1 $!\n";
  for my $hand_1(readdir $dir_1){
   next if $hand_1 =~ /^\./;
   $re->{'FILE'} .= " File exists $url/$hand_1\n" if -f "$url/$hand_1" and not $ls;
    if( $ls != 2 ){
     next unless -d "$url/$hand_1";
    }
   $ls == 1 ? push @$an," $hand_1\n" : push @$an,$hand_1;
  }
 closedir $dir_1;
  @$an = sort{$a cmp $b}@$an;
   return $an if $ls;

 for( my $in=0;$in<@$an;$in++ ){
  push @$bn," $$an[$in]\n";
  opendir my $dir_2,"$url/$$an[$in]" or die " Dirs_2 $!\n";
   for my $hand_2(readdir $dir_2){
    next if $hand_2 =~ /^\./;
     push @$bn,"$hand_2\n";
   }
  closedir $dir_2;
 }
 $bn;
}

sub Top_1{
my( $re,$list,%HA,@AN ) = @_;
 for my $ls(@$list){
  $ls =~ s/^\s(.*)\n/$1/;
   Uses_1( $re,$ls,\%HA,\@AN );
    if( @AN < 2 ){
     my @BUI = split '\t',$re->{'OS'}{"${ls}build"} if $re->{'OS'}{"${ls}build"};
      for my $bui(@BUI){
       $ls .= " : $bui" if $re->{'HASH'}{$bui};
      }
     $ls =~ s/^([^:]+)\s:\s(.+)/$1 [build]=> $2/ ? print"$ls\n" : Mine_1( $ls,$re,0 );
    }
  @AN = (); %HA = ();
 }
}

sub Brew_1{
my( $re,$list,%HA,@AN ) = @_;
 return unless @$list;
  for(my $i=0;$i<@$list;$i++){
   my( $tap ) = $list->[$i] =~ /^\s(.*)\n/ ? $1 : $list->[$i];
    (( $re->{'DMG'}{$tap} or $re->{'HASH'}{$tap} ) and not $re->{'USE'} ) ? Mine_1( $tap,$re,0 ) :
     ( $re->{'HASH'}{$tap} and $re->{'USE'} and not $re->{'USES'} ) ? Uses_1( $re,$tap,\%HA,\@AN ) :
       $re->{'USES'} ? push @AN,$tap : 0;
  }
  @AN = sort{$a cmp $b}@AN;
   Mine_1( $_,$re,0 ) for(@AN);
}

sub Uses_1{
my( $re,$tap,$HA,$AN ) = @_;
 my @tap = $tap =~ /\t/ ? split '\t',$tap : $tap;
  for my $ls(@tap){
   $HA->{$ls}++;
    push @$AN,$ls if $re->{'HASH'}{$ls} and $HA->{$ls} < 2;
     Uses_1( $re,$re->{'OS'}{"${ls}uses"},$HA,$AN ) if $re->{'OS'}{"${ls}uses"};
  }
}

sub Dele_1{
my( $re,@AN,%HA,@an,$do ) = @_;
 exit unless $re->{'HASH'}{$re->{'INF'}};
  Uses_1( $re,$re->{'INF'},\%HA,\@AN );
   @AN = sort{$a cmp $b}@AN;
    for my $uses( @AN ){
     next if $uses eq $re->{'INF'};
      push @an,$uses;
    }
   if( @an ){
     print"required formula  ==>  $_\n" for( @an );
      exit;
   }
  %HA= (); @AN =();
  Info_1( $re,0,0,\@AN,\%HA );
   my @list1 = sort{$a cmp $b}@AN;
   for my $brew( @list1 ){
    my @list2 = sort{$a cmp $b}@{$re->{$brew}};
    my $i = 0; my $e = 0;
     for( ;$i<@list2;$i++ ){
      my $flag = 0;
      next if $list2[$i] eq $brew or $list2[$i] eq $re->{'INF'};
       for( ;$e<@list1;$e++ ){
        last if $list1[$e] eq $list2[$i];
        ++$flag and last if $list1[$e] gt $list2[$i];
       }
      last if $flag;
     }
    $re->{"${brew}delet"}++ unless $list2[$i];
    $do++ if $re->{"${brew}delet"};
   }
  if( $re->{'LINK'} and $do ){
   $re->{'DEL'} = $re->{'TREE'} = $re->{'INF'} = 0;
    $re->{'LIST'} = 1;
     Fork_1( $re );
  }elsif( $do ){
   $re->{'COLOR'} = $re->{'TREE'} = 1;
    $re->{'DEL'} = 0;
     Fork_1( $re );
  } 
 exit;
}

sub File_1{
my( $re,$list,$file,$test,$tap1,$tap2,$tap3,@file ) = @_;
  unless( $re->{'TAP'} ){
   open my $BREW,'<',$re->{'TXT'} or die " File_1 $!\n";
    chomp( @$file=<$BREW> );
   close $BREW;
  }
  if( $re->{'CAS'} and -f $re->{'Q_TAP'} and ( $re->{'S_OPT'} or $re->{'TAP'} ) ){
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
             $re->{'NEW'}++; Init_1( $re );
       }
      next;
     }
     push @file,$tap;
    }
   close $BREW;
  push @$file,@file;
 }
 Search_1( $list,$file,0,$re );
}

sub Unic_1{
my( $re,$brew,$spa,$AN,$build ) = @_;
my $name = $brew;
 $name = ( -t STDOUT ) ? "$name \033[33m(require)\033[00m" : "$name (require)"
   if not $re->{'COLOR'} and ( not $re->{'HASH'}{$brew} or
          $re->{'OS'}{"${brew}ver"} and $re->{'OS'}{"${brew}ver"} gt $re->{'HASH'}{$brew} );
 $name = ( -t STDOUT ) ? "$name \033[33m(can delete)\033[00m" : "$name (can delete)"
   if $re->{'COLOR'} and $re->{'HASH'}{$brew} and $re->{"${brew}delet"};

 $re->{'OS'}{"deps$brew"} += ( $re->{'TREE'} and $build ) ?
  push @{$re->{'UNI'}},"${spa}-- $name [build]\n" : $re->{'TREE'} ?
  push @{$re->{'UNI'}},"${spa}-- $name\n" : 1;
 push @$AN,$brew if $re->{'DEL'} and $re->{'OS'}{"deps$brew"} < 2;
}

sub Read_1{
my( $re,$bottle,$brew,$ls ) = @_;
  $re->{'OS'}{"${brew}ver"} = $re->{'HASH'}{$brew} unless $re->{'OS'}{"${brew}ver"};
 ( not $bottle and not $re->{'HASH'}{$brew} or
   not $bottle and $re->{'OS'}{"${brew}ver"} gt $re->{'HASH'}{$brew} ) and
 ( not $re->{'HASH'}{$ls} or $re->{'OS'}{"${ls}ver"} and $re->{'OS'}{"${ls}ver"} gt $re->{'HASH'}{$ls} ) ?
 1 : 0;
}

sub Info_1{
my( $re,$file,$spa,$AN,$HA ) = @_; my $IN = 0;
 print "\033[33mCan't install $re->{'INF'}...\033[00m\n" 
  if not $file and ( $re->{'MAC'} and $re->{'OS'}{"$re->{'INF'}un_xcode"} or
                     $re->{'LIN'} and $re->{'OS'}{"$re->{'INF'}un_Linux"} );

 my $name = $file ? $re->{'OS'}{"${file}core"} :
  $re->{'OS'}{"$re->{'INF'}core"} ? $re->{'OS'}{"$re->{'INF'}core"} : exit;
   ++$re->{'NEW'} and Init_1( $re ) unless $name;
   my( $brew ) = $name =~ m|.+/(.+)\.rb$|;
    my $bottle =  $re->{'OS'}{"$brew$OS_Version"} ? 1 : 0;
     $spa .= $spa ? '   |' : '|';

  if( $re->{'DEL'} ){
   $HA->{$brew}++;
    my( %ha,@an );
     Uses_1( $re,$brew,\%ha,\@an ) if $HA->{$brew} < 2;
      push @{$re->{$brew}},@an if $HA->{$brew} < 2;
  }

 open my $BREW1,'<',$name or die " Info_1 $!\n";
  while(my $data=<$BREW1>){
   if( $re->{'MAC'} ){
     if( $data =~ /^\s*on_linux\s*do/ ){ $IN = 1; next;
     }elsif( $data !~ /^\s*end/ and $IN == 1 ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 1 ){ $IN = 0; next;
     }
   }else{
     if( $data =~ /^\s*on_macos\s+do/ ){ $IN = 2; next;
     }elsif( $data !~ /^\s*end/ and $IN == 2  ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 2 ){ $IN = 0; next;
     } 
   }

   if( $data =~ /^\s*head do/ ){ $IN = 3; next;
   }elsif( $data !~ /^\s*end/ and $IN == 3 ){ next;
   }elsif( $data =~ /^\s*end/ and $IN == 3 ){ $IN = 0; next;
   }

   if( $IN or $data =~ /^\s*if\s+Hardware::CPU/ ){
    $IN = $data =~ /$CPU/ ? 4 : 5 unless $IN;
     if( ( $IN == 4 or $IN == 6 ) and $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
       if( Read_1( $re,$bottle,$brew,$data ) ){
        Unic_1( $re,$data,$spa,$AN,1 );
         Info_1( $re,$data,$spa,$AN,$HA );
       } next;
     }elsif( ( $IN == 4 or $IN == 6 ) and $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
        Unic_1( $re,$data,$spa,$AN,1 );
         Info_1( $re,$data,$spa,$AN,$HA ); next;
     }elsif( $IN == 4 and $data =~ /^\s*else/ ){
         $IN = 7; next;
     }elsif( $IN == 5 and $data =~ /^\s*else/ ){
         $IN = 6; next;
     }elsif( $data =~ /^\s*end/ ){
         $IN = 0; next;
     }elsif( $data !~ /^\s*else/ ){
         next;
     }
   }

   if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
     next;
   }elsif (my( $cpu1,$cpu2 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build\s+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
     if( $cpu2 =~ /$CPU/ and Read_1( $re,$bottle,$brew,$cpu1 ) ){
        Unic_1( $re,$cpu1,$spa,$AN,1 );
         Info_1( $re,$cpu1,$spa,$AN,$HA );
     } next;
   }elsif( my( $cpu3,$cpu4 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build.+unless\s+Hardware::CPU\.([^\s]+).*\n/ ){
     if( $cpu4 !~ /$CPU/ and Read_1( $re,$bottle,$brew,$cpu3 ) ){
        Unic_1( $re,$cpu3,$spa,$AN,1 );
         Info_1( $re,$cpu3,$spa,$AN,$HA );
     } next;
   }elsif( my( $ls1,$ls2,$ls3 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build\s+if\s+MacOS.version\s+([^\s]+)\s+:([^\s]+).*\n/ ){
     if( $re->{'MAC'} and eval "$OS_Version2 $ls2 $MAC_OS{$ls3}" and Read_1( $re,$bottle,$brew,$ls1 ) ){
        Unic_1( $re,$ls1,$spa,$AN,1 );
         Info_1( $re,$ls1,$spa,$AN,$HA );
     } next;
   }elsif( my( $ls4,$ls5,$ls6 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+).*\n/ ){
     if( $re->{'MAC'} and eval "$re->{'CLANG'} $ls5 $ls6" and Read_1( $re,$bottle,$brew,$ls4 ) ){
        Unic_1( $re,$ls4,$spa,$AN,1 );
         Info_1( $re,$ls4,$spa,$AN,$HA );
     } next;
   }elsif( my( $ls7,$ls8 ) =
    $data =~ /^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build,\s+since:\s+:([^\s]+).*\n/ ){
     if( ( $re->{'LIN'} or $OS_Version2 < $MAC_OS{$ls8} ) and Read_1( $re,$bottle,$brew,$ls7 ) ){
        Unic_1( $re,$ls7,$spa,$AN,1 );
         Info_1( $re,$ls7,$spa,$AN,$HA );
     } next;
   }elsif( $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
     if( $re->{'LIN'} and Read_1( $re,$bottle,$brew,$data ) ){
        Unic_1( $re,$data,$spa,$AN,1 );
         Info_1( $re,$data,$spa,$AN,$HA );
     } next;
   }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
     if( Read_1( $re,$bottle,$brew,$data ) ){
        Unic_1( $re,$data,$spa,$AN,1 );
         Info_1( $re,$data,$spa,$AN,$HA );
     } next;
   }

   if( $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*\sif\s).*\n/$1/ ){
        Unic_1( $re,$data,$spa,$AN );
         Info_1( $re,$data,$spa,$AN,$HA );
   }elsif( my( $ls1,$ls2 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+).*\n/ ){
    if( $re->{'LIN'} or $OS_Version2 < $MAC_OS{$ls2} ){
       $ls1 =~ s/^python$/python\@3.9/;
        Unic_1( $re,$ls1,$spa,$AN );
         Info_1( $re,$ls1,$spa,$AN,$HA );
    }
   }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
        Unic_1( $re,$data,$spa,$AN );
         Info_1( $re,$data,$spa,$AN,$HA );
   }elsif( $data =~ /^\s*depends_on.+\s*if\s*/ ){
     if( my( $ls1,$ls2,$ls3 ) =
      $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+).*\n/ ){
       if( $re->{'MAC'} and eval "$OS_Version2 $ls2 $MAC_OS{$ls3}" ){
        Unic_1( $re,$ls1,$spa,$AN );
         Info_1( $re,$ls1,$spa,$AN,$HA );
       }
     }elsif( my($ls4,$ls5,$ls6) =
      $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+).*\n/ ){
       if( $re->{'MAC'} and eval "$re->{'CLANG'} $ls5 $ls6" ){
        Unic_1( $re,$ls4,$spa,$AN );
         Info_1( $re,$ls4,$spa,$AN,$HA );
       }
     }elsif( my( $ls7,$ls8 ) =
      $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
       if( $ls8 =~ /$CPU/ ){
        Unic_1( $re,$ls7,$spa,$AN );
         Info_1( $re,$ls7,$spa,$AN,$HA );
       }
     }
   }
  }
 close $BREW1;
}

sub Mine_1{
my( $name,$re,$ls ) = @_;
 $name = "$name (I)" if( $ls and -t STDOUT );
  $re->{'LEN'}{$name} = length $name;
   push @{$re->{'ARR'}},$name;
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
 if( $dir ){
  my $file = Dirs_1( "$re->{'CEL'}/$dir",2 );
  if( @$file ){
     $re->{'ALL'} .= "     Check folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= "     Check folder $re->{'CEL'} => $dir\n" if $mem;
   for(my $i=0;$i<@$file;$i++){
     $re->{'ALL'} .= @$file-1 == $i ? "    $$file[$i]\n" : "     $$file[$i]" unless $re->{'L_OPT'};
     $re->{'EXC'} .= @$file-1 == $i ? "    $$file[$i]\n" : "     $$file[$i]" if $mem;
   }
  }else{
     $re->{'ALL'} .= "     Empty folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= "     Empty folder $re->{'CEL'} => $dir\n" if $mem;
  }
 }else{
    $re->{'ALL'} .= $re->{'MEM'} unless $re->{'L_OPT'};
    $re->{'EXC'} .= $re->{'MEM'} if $mem;
 }
}

sub Version_1{
my( $ls1,$ls2 ) = @_;
 my @ls1 = split '\.|-|_',$ls1;
 my @ls2 = split '\.|-|_',$ls2;
 my $i = 0;
  for(;$i<@ls2;$i++){
   if( $ls1[$i] and $ls2[$i] =~ /[^\d]/ ){
    return 1 if $ls1[$i] gt $ls2[$i];
   }else{
    return 1 if $ls1[$i] and $ls1[$i] > $ls2[$i];
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
  if( $gz =~ s/^$ls1--([\d._-]+)\.[^\d_-]+$/$1/ or $gz =~ s/^$ls1--([\d._-]+)$/$1/ ){
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

sub Search_1{
my( $list,$file,$in,$re ) = @_;
 for(my $i=0;$i<@$file;$i++){ my $pop = 0;
  my( $brew_1,$brew_2,$brew_3 ) = $file->[$i] =~ /\t/ ? split '\t',$file->[$i] : $file->[$i];
   last if $brew_1 =~ m|^homebrew/| and not $re->{'S_OPT'};
    my $mem = ( $re->{'L_OPT'} and $brew_1 =~ /$re->{'L_OPT'}/o ) ? 1 : 0;

  $brew_1 = $brew_1 eq '0' ? ' ==> homebrew/cask-fonts' :
            $brew_1 eq '1' ? ' ==> homebrew/cask-drivers' :
            $brew_1 eq '2' ? ' ==> homebrew/cask-versions' : $brew_1;

  $brew_2 = $re->{'OS'}{"${brew_1}c_version"} if $re->{'CAS'} and $re->{'OS'}{"${brew_1}c_version"};
  $brew_2 = $brew_2.$re->{'OS'}{"${brew_1}revision"} if $re->{'FOR'} and $re->{'OS'}{"${brew_1}revision"};

  $brew_3 = ( $re->{'CAS'} and $re->{'OS'}{"${brew_1}c_desc"} ) ? $re->{'OS'}{"${brew_1}c_desc"} :
   ( $re->{'CAS'} and $re->{'OS'}{"${brew_1}c_name"} ) ? $re->{'OS'}{"${brew_1}c_name"} : $brew_3;
    $brew_3 =~ s/[“”]//g unless $re->{'LC'};

  if( not $re->{'LINK'} or
      $re->{'LINK'} == 1 and $re->{'OS'}{"${brew_1}un_xcode"} or
      $re->{'LINK'} == 2 and $re->{'OS'}{"${brew_1}un_Linux"} or
      $re->{'LINK'} == 3 and $re->{'OS'}{"$brew_1$OS_Version"} or
      $re->{'LINK'} == 4 and $re->{'OS'}{"${brew_1}un_cask"} or
      $re->{'LINK'} == 5 and $re->{'OS'}{"${brew_1}so_name"} or
      $re->{'LINK'} == 6 and $re->{'OS'}{"deps$brew_1"} or
      $re->{'LINK'} == 7 and $re->{"${brew_1}delet"} ){

    if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
     Tap_1( $list,$re,\$in );
      $i--; next;
    }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
     ( $re->{'DMG'}{$brew_1} or $re->{'HASH'}{$brew_1} ) ?
      Mine_1( $brew_1,$re,1 ) : Mine_1( $brew_1,$re,0 )
       if $re->{'S_OPT'} and $brew_1 =~ /$re->{'S_OPT'}/o;
        $in++; $re->{'IN'}++; $pop = 1;
    }else{
     if( $re->{'S_OPT'} and $brew_1 =~ m|(?!.*/)$re->{'S_OPT'}|o ){
      if( my( $opt ) = $brew_1 =~ m|^homebrew/.+/(.+)| ){
       Mine_1( $brew_1,$re,0 )
        if $opt =~ /\b$re->{'S_OPT'}\b/ and $re->{'S_OPT'} !~ /^(-|\\-)$/;
      }else{ Mine_1( $brew_1,$re,0 ); }
     }
    }
   unless( $re->{'S_OPT'} ){
     if( $re->{'MAC'} ){
      if( $re->{'FOR'} ){
       $re->{'MEM'} = ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg"} ) ?
        " b k     $brew_1\t" : $re->{'OS'}{"$brew_1$OS_Version"} ? " b       $brew_1\t" :
         ( $re->{'OS'}{"${brew_1}un_xcode"} and $re->{'OS'}{"${brew_1}keg"} ) ?
       " x k     $brew_1\t" : $re->{'OS'}{"${brew_1}un_xcode"} ? " x       $brew_1\t" :
       $re->{'OS'}{"${brew_1}keg"} ? "   k     $brew_1\t" : "         $brew_1\t";
      }else{
       $re->{'MEM'} = ( $re->{'OS'}{"${brew_1}un_cask"} and $re->{'OS'}{"${brew_1}so_name"} ) ?
        " x s     $brew_1\t" : $re->{'OS'}{"${brew_1}un_cask"} ? " x       $brew_1\t" :
       $re->{'OS'}{"${brew_1}so_name"} ? "   s     $brew_1\t" :
       ( $re->{'OS'}{"${brew_1}un_cask"} and $re->{'OS'}{"${brew_1}formula"} ) ?
        " x f     $brew_1\t" : $re->{'OS'}{"${brew_1}formula"} ? "   f     $brew_1\t" :
        "         $brew_1\t";
      }
     }else{
       $re->{'MEM'} = ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
       " b k     $brew_1\t" : $re->{'OS'}{"$brew_1$OS_Version"} ? " b       $brew_1\t" :
        ( $re->{'OS'}{"${brew_1}un_Linux"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
       " x k     $brew_1\t" : $re->{'OS'}{"${brew_1}un_Linux"}  ? " x       $brew_1\t" :
       $re->{'OS'}{"${brew_1}keg_Linux"} ? "   k     $brew_1\t" : "         $brew_1\t";
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
            Memo_1( $re,$mem,0 );
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
      Memo_1( $re,$mem,0 ) if $re->{'LIST'} or $pop;
       $re->{'AN'}++;
   }
  }
 }
  if( $list->[$in] ){
   Tap_1( $list,$re,\$in ) while($list->[$in]);
  }
}

sub Tap_1{
my( $list,$re,$in ) = @_;
 my( $tap ) = $list->[$$in] =~ /^\s(.*)\n/;
  my $mem = ( $re->{'L_OPT'} and $tap =~ /$re->{'L_OPT'}/ ) ? 1 : 0;

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

      my $brew = 1;
 if( $re->{'LINK'} and $re->{'LINK'} == 1 and not $re->{'OS'}{"${tap}un_xcode"} or
     $re->{'LINK'} and $re->{'LINK'} == 2 and not $re->{'OS'}{"${tap}un_Linux"} or
     $re->{'LINK'} and $re->{'LINK'} == 3 and not $re->{'OS'}{"$tap$OS_Version"} or
     $re->{'LINK'} and $re->{'LINK'} == 4 and not $re->{'OS'}{"${tap}un_cask"} or
     $re->{'LINK'} and $re->{'LINK'} == 5 and not $re->{'OS'}{"${tap}so_name"} or
     $re->{'LINK'} and $re->{'LINK'} == 6 and not $re->{'OS'}{"deps$tap"} or
     $re->{'LINK'} and $re->{'LINK'} == 7 and not $re->{"${tap}delet"} ){
      $brew = 0;
 }

  if( $re->{'S_OPT'} and $tap =~ /$re->{'S_OPT'}/ and $re->{'DMG'}{$tap} or
      $re->{'S_OPT'} and $tap =~ /$re->{'S_OPT'}/ and $re->{'HASH'}{$tap}){
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
    }elsif( $re->{'FOR'} and $ver ne $re->{'HASH'}{$tap} and
          ( not $re->{'OS'}{"${tap}un_xcode"} or not $re->{'OS'}{"${tap}un_Linux"} ) or
            $re->{'CAS'} and not $re->{'OS'}{"${tap}un_cask"} and $ver ne $re->{'DMG'}{$tap} ){
        $re->{'MEM'} = "         $tap\t$ver\t$com\n";
         Version_2( $re,$tap,$ver );
    }else{
        $re->{'MEM'} = "         $tap\t$ver\t$com\n";
         Type_1( $re,$tap,' i ' );
    }
     if( $brew and not $re->{'TAP'} ){
      Memo_1( $re,$mem,0 );
       $re->{'AN'}++; $re->{'IN'}++;
     }
  }else{
    Memo_1( $re,$mem,$tap );
  }
 $$in++;
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
    $re->{'MEM'} =~ s/^.{9}/ t f $i / : $re->{'OS'}{"${brew_1}un_cask"} ?
    $re->{'MEM'} =~ s/^.{9}/ t   $i / : $re->{'OS'}{"${brew_1}so_name"} ?
    $re->{'MEM'} =~ s/^.{9}/   s $i / : $re->{'OS'}{"${brew_1}formula"} ?
    $re->{'MEM'} =~ s/^.{9}/   f $i / : $re->{'MEM'} =~ s/^.{9}/     $i /; 
  }
 }else{
  ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
   $re->{'MEM'} =~ s/^.{9}/ b k $i / : $re->{'OS'}{"$brew_1$OS_Version"} ?
   $re->{'MEM'} =~ s/^.{9}/ b   $i / : $re->{'OS'}{"${brew_1}keg_Linux"} ?
   $re->{'MEM'} =~ s/^.{9}/   k $i / : $re->{'MEM'} =~ s/^.{9}/     $i /; 
 }
}

sub Command_1{
my( $re,$list,$ls1,$ls2,%HA,%OP ) = @_;
 for(my $in=0;$in<@$list;$in++){
  if( $list->[$in] =~ s/^\s(.*)\n/$1/ and $list->[$in] =~ /^\Q$re->{'STDI'}\E$/o ){
   my $name = $list->[$in];
   exit unless my $num = $re->{'HASH'}{$name};
    for my $dir('bin','sbin'){
     if( -d "$re->{'CEL'}/$name/$num/$dir" ){
      my $com = Dirs_1( "$re->{'CEL'}/$name/$num/$dir",2 );
       print"$re->{'CEL'}/$name/$num/$dir/$_\n" for(@{$com});
     }
    }
    Dirs_2( "$re->{'CEL'}/$name/$num",$re );
     $re->{'CEL'} = "$re->{'CEL'}/\Q$name\E/$num";
    for $ls1(@{$re->{'ARR'}}){
     next if $ls1 =~ m|^$re->{'CEL'}/[^/]+$|o or $ls1 =~ m|^$re->{'CEL'}/s?bin/|o;
     if(not -l $ls1 and $ls1 =~ m|^$re->{'CEL'}/lib/[^/]+dylib$|o){
             print"$ls1\n"; $re->{'IN'} = 1;
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
      ( $re->{'IN'} and  $key =~ m|^$re->{'CEL'}/lib$|o ) ?
      print"$key/ ($HA{$key} other file)\n" : print"$key/ ($HA{$key} file)\n";
     }
    }
   exit;
  }
 }
}

sub Dirs_2{
my( $an,$re ) = @_;
 opendir my $dir,$an or die " N_Dirs $!\n";
  for my $bn(readdir($dir)){
   next if $bn =~ /^\.{1,2}$/;
    ( -d "$an/$bn" and not -l "$an/$bn" ) ?
   Dirs_2( "$an/$bn",$re ) : push @{$re->{'ARR'}},"$an/$bn";
  }
 closedir $dir;
}

sub Format_1{
my( $re,$ls,$sl,$ss,$ze ) = @_;
 if( $re->{'TREE'} ){ Format_2( $re );
 }elsif( $re->{'LIST'} or $re->{'PRINT'} ){
  system " printf '\033[?7l' " if( $re->{'MAC'} and -t STDOUT );
   system 'setterm -linewrap off' if( $re->{'LIN'} and -t STDOUT );
    $re->{'L_OPT'} ? print"$re->{'EXC'}" : print"$re->{'ALL'}" if $re->{'ALL'} or $re->{'EXC'};
     print " item $re->{'AN'} : install $re->{'IN'}\n" if $re->{'ALL'} or $re->{'EXC'};
  system " printf '\033[?7h' " if( $re->{'MAC'} and -t STDOUT );
   system 'setterm -linewrap on' if( $re->{'LIN'} and -t STDOUT );
 }elsif( $re->{'DAT'} ){
  print for( @{$re->{'OUT'}} );
   $re->{'CAS'} = 0;
 }else{
  if( -t STDOUT ){
   my $leng = $re->{'LEN1'};
    my $tput = `tput cols`;
     my $size = int $tput/($leng+2);
      my $in = 1;
   print" ==> Casks\n" if $re->{'CAS'} and @{$re->{'ARR'}} and ${$re->{'ARR'}}[0]!~m|^homebrew/|;
    print" ==> Formulae\n" if $re->{'FOR'} and @{$re->{'ARR'}};
     for my $arr( @{$re->{'ARR'}} ){
      if( $arr =~ m|^homebrew/cask-fonts/| and not $ls ){
       print"\n" if $ze;
        print" ==> brew tap : homebrew/cask-fonts\n";
         $leng = $re->{'LEN2'};
          $size = int $tput/($leng+2);  $in = $ls = 1;
      }elsif( $arr =~ m|^homebrew/cask-drivers/| and not $sl ){
       print"\n" if $ze;
        print" ==> brew tap : homebrew/cask-drivers\n";
         $leng = $re->{'LEN3'};
          $size = int $tput/($leng+2);  $in = $sl = 1;
      }elsif( $arr =~ m|^homebrew/cask-versions/| and not $ss ){
       print"\n" if $ze;
        print" ==> brew tap : homebrew/cask-versions\n";
         $leng = $re->{'LEN4'};
          $size = int $tput/($leng+2);  $in = $ss = 1;
      }
       for(my $i=$re->{'LEN'}{$arr};$i<$leng+2;$i++){
        $arr .= ' ';
       }
      print"$arr";
      print"\n" unless $ze = eval "$in % $size";
      $in++;
     }
    print"\n" if $ze;
   }else{
    print"$_\n" for @{$re->{'ARR'}};
   }
   $re->{'FOR'} = 0 if $re->{'MAC'};
 }
 print "\033[33m$re->{'FILE'}\033[00m" if $re->{'FILE'} and ( $re->{'ALL'} or $re->{'EXC'} );
  Nohup_1( $re ) if $re->{'CAS'} or $re->{'FOR'};
}

sub Format_2{
my $re = shift;
 my( $wap,$leng,@TODO ); my $cou = 0;
 for( @{$re->{'UNI'}} ){ my $an;
  $wap++;
   if( $re->{'LC'} ){
    $_ =~ s/\|/│/g;
    $_ =~ s/│--/├──/g;
   }
   my @an = split '\\s{3}',$_;
   for(@an){ $an++;
     $cou = $an if $cou < $an;
   } $an = 0;
 }
 for(my $i=0;$i<$cou;$i++){ my $in;
  $leng = $in = 0;
  for my $data( @{$re->{'UNI'}} ){ $leng++;
   my @an = split '\\s{3}',$data;
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
   $wap++; my $plus = '';
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
 print"$re->{'INF'}\n" if @{$re->{'UNI'}};
  for( @{$re->{'UNI'}} ){ s/#/ /g; print; }
}

sub Nohup_1{
my $re = shift;
 ++$re->{'NEW'} and Init_1( $re )
  unless -f "$re->{'HOME'}/font.sh" and -f "$re->{'HOME'}/tie.pl";
 my( $time1,$time2 ) =
  ( [localtime],[localtime((stat $re->{'TXT'})[9])] );
   if( $time1->[5] > $time2->[5] or $time1->[4] > $time2->[4] or
       $time1->[3] > $time2->[3] or $time1->[2] > $time2->[2] ){
    system 'nohup ~/.BREW_LIST/font.sh >/dev/null 2>&1 &';
   }
}

sub Tied_1{
my( $re,$i,@file1,@file2 ) = @_;
 while(my $tap = <DATA>){
  ++$i and next if $tap =~ /^__TIE__$/;
   push @file1,$tap unless $i;
    push @file2,$tap if $i;
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
rm -f ~/.BREW_LIST/master* ~/.BREW_LIST/*.html ~/.BREW_LIST/DBM*
rm -rf ~/.BREW_LIST/homebrew-cask-*
rm -rf ~/.BREW_LIST/{0..9} ~/.BREW_LIST/WAIT ~/.BREW_LIST/LOCK
exit' 1 2 3 15

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
    @file1 = sort{$a cmp $b}@file1;

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
    @file2 = sort{$a cmp $b}@file2;

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
    @file3 = sort{$a cmp $b}@file3;

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

rm -rf  ~/.BREW_LIST/6
perl ~/.BREW_LIST/tie.pl

if [[ $NAME = Darwin ]];then
 mv ~/.BREW_LIST/DBMG.db ~/.BREW_LIST/DBM.db
else
 mv ~/.BREW_LIST/DBMG.dir ~/.BREW_LIST/DBM.dir
 mv ~/.BREW_LIST/DBMG.pag ~/.BREW_LIST/DBM.pag
fi

rm -f  ~/.BREW_LIST/master* ~/.BREW_LIST/*.html
rm -rf ~/.BREW_LIST/homebrew-cask-* ~/.BREW_LIST/{0..9} ~/.BREW_LIST/WAIT ~/.BREW_LIST/LOCK
__TIE__
use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my $IN = 0; my $CIN = 0; my $KIN = 0;
my $CPU = `uname -m` =~ /arm64/ ? 'arm\?' : 'intel\?';
my( $re,$OS_Version,$OS_Version2,%MAC_OS,$Xcode,$RPM,$CAT,@BREW,@CASK );

if( $^O eq 'darwin' ){
 $re->{'MAC'} = 1;
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/^(10.1\d)\.?\d*\n/$1/;
   $OS_Version =~ s/^(10\.)([7-9])\.?\d*\n/${1}0$2/;
    $OS_Version =~ s/^11.+\n/11.0/;
     $OS_Version =~ s/^12.+\n/12.0/;
 $OS_Version2 = $OS_Version;
  $OS_Version2 = "${OS_Version}M1" if $CPU eq 'arm\?';

 $Xcode = `xcodebuild -version 2>/dev/null` ?
  `xcodebuild -version|awk '/Xcode/{print \$NF}'` : 0;
    $Xcode =~ s/^(\d\.)/0$1/;

 %MAC_OS = ('monterey'=>'12.0','big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14',
            'high_sierra'=>'10.13','sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10');
 $re->{'CLANG'} = `clang --version|awk '/Apple/'|sed 's/.*-\\([^.]*\\)\\..*/\\1/'`;
 $re->{'CLT'} = `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables|\
                 awk '/version/{print \$2}'|sed 's/\\([0-9]*\\.[0-9]*\\).*/\\1/'`;

  if( $CPU eq 'intel\?' ){
   Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew',1,1 );
     Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/usr/local/Homebrew/Library/Taps',1,0 );
  }else{
   Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
    Dirs_1( '/opt/homebrew/Library/Taps/homebrew',1,1 );
     Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/opt/homebrew/Library/Taps',1,0 );
  }
 rmdir "$ENV{'HOME'}/.BREW_LIST/7";
}else{
 $re->{'LIN'} = 1;
  $RPM = `ldd --version|awk '/ldd/{print \$NF}'`;
   $CAT = `cat ~/.BREW_LIST/brew.txt|awk '/glibc/{print \$2}'`;
    $OS_Version2 = 'Linux';

 Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
  Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps',1,0 );
}

sub Dirs_1{
 my( $dir,$ls,$cask ) = @_;
 my @files = glob "$dir/*";
  for my $card(@files) {
   next if $ls and $card =~ m!/homebrew$|/homebrew-core$|/homebrew-cask$|
                              /homebrew-bundle$|/homebrew-services$!x;
    if( -d $card ){
     Dirs_1( $card,$ls,$cask );
    }else{
     $cask ? push @CASK,"$card\n" : push @BREW,"$card\n" if $card =~ /\.rb$/;
    }
  }
}

tie my %tap,"NDBM_File","$ENV{'HOME'}/.BREW_LIST/DBMG",O_RDWR|O_CREAT,0644;
 for my $dir1(@BREW){ chomp $dir1;
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb|;
   $tap{"${name}core"} = $dir1;
  open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
   while(my $data=<$BREW>){
     if( $data =~ /^\s*bottle\s+do/ ){
      $KIN = 1; next;
     }elsif( $data =~ /^\s*rebuild/ and $KIN == 1 ){
       next;
     }elsif( $data !~ /^\s*end/ and $KIN == 1 ){
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
       $data =~ s/.*x86_64_linux:.*\n/Linux/    ? 1 : 0;
        if( $data =~ /.*,\s+all:/ ){
         $tap{"${name}12.0M1"} = $tap{"${name}12.0"} = 
         $tap{"${name}11.0M1"} = $tap{"${name}11.0"} = $tap{"${name}10.15"} =
         $tap{"${name}10.14"} = $tap{"${name}10.13"} = $tap{"${name}10.12"} =
         $tap{"${name}10.11"} = $tap{"${name}10.10"} = $tap{"${name}Linux"} =
         $tap{"${name}10.09"} = $tap{"${name}10.08"} = $tap{"${name}10.07"} = 1;
        }
       next;
     }elsif( $data =~ /^\s*end/ and $KIN == 1 ){
      $KIN = 0; next;
     }

    if( $re->{'MAC'} ){
      if( $data =~ /^\s*on_linux\s*do/ ){ $IN = 1; next;
      }elsif( $data !~ /^\s*end/ and $IN == 1 ){ next;
      }elsif( $data =~ /^\s*end/ and $IN == 1){ $IN = 0; next;
      }
    }else{
      if( $data =~ /^\s*on_macos\s+do/ ){ $IN = 1; next;
      }elsif( $data !~ /^\s*end/ and $IN == 1  ){ next;
      }elsif( $data =~ /^\s*end/ and $IN == 1){ $IN = 0; next;
      }elsif( $data =~ /^\s*on_linux\s*do/ ){ $IN = 2; next;
      }elsif( $data =~ /^\s*keg_only/ and $IN == 2 ){
        $tap{"${name}keg_Linux"} = 1; next;
      }elsif( $data =~ /^\s*end/ and $IN == 2){ $IN = 0; next;
      }
    }
     if( $data =~ /^\s*head do/ ){ $IN = 3; next;
     }elsif( $data !~ /^\s*end/ and $IN == 3 ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 3){ $IN = 0; next;
     }

     if( $CIN or $data =~ /^\s*if\s+Hardware::CPU/ ){
       $CIN = $data =~ /$CPU/ ? 1 : 2 unless $CIN;
       if(($CIN == 1 or $CIN == 3) and $re->{'MAC'} and
           $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
          $data =~ s/^(\d\.)/0$1/;
           $tap{"${name}un_xcode"} = 1 if $data gt $Xcode;
            $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
          next;
       }elsif(($CIN == 1 or $CIN == 3) and $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*:build).*\n/$1/ ){
          $tap{"${data}uses"} .= "$name\t"; next;
       }elsif( $CIN == 1 and $data =~ /^\s*else/ ){
          $CIN = 4; next;
       }elsif( $CIN == 2 and $data =~ /^\s*else/ ){
          $CIN = 3; next;
       }elsif( $data =~ /^\s*end/ ){
          $CIN = 0; next;
       }elsif( $data !~ /^\s*else/ ){
          next;
       }
     }

      if( my( $ls1,$ls2 ) =
        $data =~ /^\s*depends_on\s+xcode:.+if\s+MacOS::CLT\.version\s+([^\s]+)\s+"([^"]+)"/ ){
         if( $re->{'MAC'} and not $Xcode and  eval "$re->{'CLT'} $ls1 $ls2" ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( my( $ls3,$ls4 ) = 
        $data =~ /^\s*depends_on\s+xcode:.+:build.+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
         if( $re->{'MAC'} and eval "$OS_Version $ls3 $MAC_OS{$ls4}" and not $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( my( $ls5,$ls6,$ls7 ) =
        $data =~ /^\s*depends_on\s+xcode:\s*"([^"]+)"\s*if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
         $data =~ s/^(\d\.)/0$1/;
         if( $re->{'MAC'} and eval "$OS_Version $ls6 $MAC_OS{$ls7}" and $ls5 gt $Xcode ){
         $ls5 =~ s/^(\d\.)/0$1/;
          $tap{"${name}un_xcode"} = 1;
           $tap{"$name$OS_Version2"} = 0;
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ s/^\s*depends_on\s+xcode:\s+:build\s+if\s+Hardware::CPU\.([^\s]+).*\n/$1/ ){
         if( $re->{'MAC'} and $data =~ /$CPU/ and not $Xcode ){
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
         } next;
      }

     if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
         next;
     }elsif( $data =~ /^\s*depends_on\s+"[^"]+"\s+=>\s+\[?:build/ ){
       if( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>\s+:build(?!.*if\s).*\n/$1/ ){
          $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
       }elsif( my( $ds1,$ds2,$ds3 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+)/ ){
         if( $re->{'MAC'} and eval "$re->{'CLANG'} $ds2 $ds3" ){
          $tap{"${ds1}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         }
       }elsif( my( $ds4,$ds5 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build\s+if\s+Hardware::CPU\.([^\s]+)/ ){
         if( $ds5 =~ /$CPU/ ){
          $tap{"${ds4}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         }
       }elsif( my( $ds6,$ds7,$ds8 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
         if( $re->{'MAC'} and eval "$OS_Version $ds7 $MAC_OS{$ds8}" ){
          $tap{"${ds6}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         }
       }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>\s+\[:build.+\n/$1/ ){
          $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
       }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
          $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*\sif\s).*\n/$1/ ){
        $tap{"${data}uses"} .= "$name\t";
     }elsif( my( $ls1,$ls2 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+)/ ){
       if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$ls2} ){
        $tap{"${ls1}uses"} .= "$name\t";
       }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
        $tap{"${data}uses"} .= "$name\t";
     }elsif( $data =~ /^\s*depends_on.+\s+if\s+/ ){
       if( my( $ls1,$ls2,$ls3 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
         if( $re->{'MAC'} and eval "$OS_Version $ls2 $MAC_OS{$ls3}" ){
          $tap{"${ls1}uses"} .= "$name\t";
         }
       }elsif( my($ls4,$ls5,$ls6) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+)/ ){
         if( $re->{'MAC'} and eval "$re->{'CLANG'} $ls5 $ls6" ){
          $tap{"${ls4}uses"} .= "$name\t";
         }
       }elsif( my( $ls7,$ls8 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Hardware::CPU\.([^\s]+)/ ){	
          $tap{"${ls7}uses"} .= "$name\t" if $ls8 =~ /$CPU/;
       }
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
    }elsif( $data =~ s/^\s*depends_on\s+macos:\s+:([^\s]*).*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} > $OS_Version ){
        $tap{"${name}un_xcode"} = 1;
      }
    }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[:([^\s]+),\s+:build].*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} < $OS_Version ){
        $tap{"${name}un_xcode"} = 1;
      }
    }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+:([^\s]+).*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} < $OS_Version ){
        $tap{"${name}un_xcode"} = 1;
      }
    }
   }
  close $BREW;
 }
  if( $RPM and $RPM > $CAT ){
   $tap{'glibcun_Linux'} = 1;
    $tap{'glibcLinux'} = 0;
  }

 if( $re->{'MAC'} ){
 rmdir "$ENV{'HOME'}/.BREW_LIST/8";
  for my $dir2(@CASK){ chomp $dir2;
   my( $name ) = $dir2 =~ m|.+/(.+)\.rb|;
    $tap{"${name}cask"} = $dir2;
     my( $IF1,$IF2,$ELIF,$ELS ) = ( 1,0,0,0 );
   open my $BREW,'<',$dir2 or die " tie Info_2 $!\n";
    while(my $data=<$BREW>){
     if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ ){
       $tap{"${name}un_cask"} = 1 unless eval "$OS_Version $ls1 $MAC_OS{$ls2}";
     }elsif( $data =~ /^\s*depends_on\s+formula:/ ){
       $tap{"${name}formula"} = 1;
       if( my( $ls3 ) = $data =~ /^\s*depends_on\s+formula:.+if\s+Hardware::CPU\.([^\s]+)/ ){
        $tap{"${name}formula"} = 0 if $CPU ne $ls3;
       }
     }elsif( my( $ls4,$ls5 ) = $data =~ /^\s*if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
        $IF1 = 0; $ELIF = $ELS = 1;
       if( eval "$OS_Version $ls4 $MAC_OS{$ls5}" ){
        $ELS = $ELIF = 0; $IF2 = 1;
       }
     }elsif( my( $ls6,$ls7 ) = $data =~ /^\s*elsif\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ and $ELIF ){
       if( eval "$OS_Version $ls6 $MAC_OS{$ls7}" ){
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

  open my $FILE,'<',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE $!\n";
   my @LIST = <$FILE>;
  close $FILE;

  @BREW = sort{$a cmp $b} map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @BREW;
  @CASK = sort{$a cmp $b} map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @CASK;

   my $COU = $IN;
  for(my $i=0;$i<@BREW;$i++){
    for(;$COU<@LIST;$COU++){
     my( $ls1,$ls2,$ls3 ) = split '\t',$LIST[$COU];
      last if $BREW[$i] lt $ls1;
       if( $BREW[$i] eq $ls1 ){
        $tap{"${BREW[$i]}ver"} = $tap{"${BREW[$i]}revision"} ? $ls2.$tap{"${BREW[$i]}revision"} : $ls2;
         last;
       }
    }
    unless( $tap{"${BREW[$i]}ver"} ){
     $tap{"${BREW[$i]}ver"} = ( $tap{"${BREW[$i]}f_version"} and $tap{"${BREW[$i]}revision"} ) ?
      $tap{"${BREW[$i]}f_version"}.$tap{"${BREW[$i]}revision"} : $tap{"${BREW[$i]}f_version"} ?
       $tap{"${BREW[$i]}f_version"} : 0;
    }
    for(;$IN<@CASK;$IN++){
     last if $BREW[$i] lt $CASK[$IN];
      if($BREW[$i] eq $CASK[$IN]){
       $tap{"${CASK[$IN]}so_name"} = 1;
        last;
      }
    }
  }
 }
untie %tap;
