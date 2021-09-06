#!/usr/bin/env perl
use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';
my( $OS_Version,$OS_Version2,$CPU,$Files,%MAC_OS );

sub Main_1{
 my $re  = {
  'LEN1'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,'UP'=>0,
   'CEL'=>'/usr/local/Cellar','BIN'=>'/usr/local/opt',
    'TXT'=>"$ENV{'HOME'}/.BREW_LIST/brew.txt"};

 my $ref = {
  'LEN1'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,'UP'=>0,
   'CEL'=>'/usr/local/Caskroom','LEN2'=>1,'LEN3'=>1,'LEN4'=>1,
    'TXT'=>"$ENV{'HOME'}/.BREW_LIST/cask.txt",
     'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
      'DRI'=>"$ENV{'HOME'}/.BREW_LIST/Q_DRIV.txt",
       'VER'=>"$ENV{'HOME'}/.BREW_LIST/Q_VERS.txt"};

 $^O eq 'darwin' ? $re->{'MAC'} = $ref->{'MAC'}= 1 :
  $^O eq 'linux' ? $re->{'LIN'} = 1 : exit;
  %MAC_OS = ('big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14','high_sierra'=>'10.13',
             'sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10');

 $ref->{'FDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
 $ref->{'DDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
 $ref->{'VERS'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-versions';

 my @AR = @ARGV; my $name;
  Died_1() unless $AR[0];
 if( $AR[0] eq '-l' ){      $name = $re;  $re->{'LIST'}  = 1;
 }elsif( $AR[0] eq '-i' ){  $name = $re;  $re->{'PRINT'} = 1;
 }elsif( $AR[0] eq '-c' ){  $name = $ref; $ref->{'LIST'} = 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-ci'){  $name = $ref; $ref->{'PRINT'}= 1; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-lx' ){ $name = $re;  $re->{'LIST'}  = 1; $re->{'LINK'} = $re->{'MAC'} ? 1 : 2;
 }elsif( $AR[0] eq '-lb' ){ $name = $re;  $re->{'LIST'}  = 1; $re->{'LINK'}  = 3;
 }elsif( $AR[0] eq '-cx' ){ $name = $ref; $ref->{'LIST'} = 1; $ref->{'LINK'} = 4; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-cs' ){ $name = $ref; $ref->{'LIST'} = 1; $ref->{'LINK'} = 5; Died_1() if $re->{'LIN'};
 }elsif( $AR[0] eq '-in' ){ $name = $re;  $re->{'LIST'}  = 1; $re->{'LINK'}  = 6; $re->{'INF'} = 1;
 }elsif( $AR[0] eq '-t' ){  $name = $re;  $re->{'LIST'} = $re->{'INF'} = $re->{'TREE'} = 1;
 }elsif( $AR[0] eq '-co' ){ $name = $re;  $re->{'COM'} = 1;
 }elsif( $AR[0] eq '-new' ){$name = $re;  $re->{'NEW'} = 1;
 }elsif( $AR[0] eq '-o' ){  $re->{'DAT'}= $ref->{'DAT'}= 1;
 }elsif( $AR[0] eq '-' ){   $re->{'BL'} = $ref->{'BL'} = 1;
 }elsif( $AR[0] eq '-s' ){  $re->{'S_OPT'} = 1;
 }else{  Died_1();
 }

 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
    $OS_Version = 'Linux';
 }else{
  $OS_Version = `sw_vers -productVersion`;
   $OS_Version =~ s/^(10\.\d+)\.?\d*\n/$1/;
    $OS_Version =~ s/^11.+/11.0/;
     $CPU = `sysctl machdep.cpu.brand_string`;
      $CPU = $CPU =~ /Apple\s+M1/ ? 'arm\?' : 'intel\?';
       $OS_Version2 = $OS_Version;
        $OS_Version = "${OS_Version}M1" if $CPU eq 'arm\?';
 }

 if( $CPU and $CPU eq 'arm\?' ){
  $re->{'CEL'} = '/opt/homebrew/Cellar';
   $re->{'BIN'} = '/opt/homebrew/opt';
    $ref->{'CEL'} = '/opt/homebrew/Caskroom';
     $ref->{'FDIR'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
      $ref->{'DDIR'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-drivers';
       $ref->{'VERS'} = 1 if -d '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-versions';
 }
 exit unless -d $re->{'CEL'};

 if( $AR[1] and $AR[1] =~ m!/.*(\\Q|\\E).*/!i ){
  $AR[1] !~ /.*\\Q.+\\E.*/ ? die" nothing in regex\n" :
   $AR[1] =~ s|/(.*)\\Q(.+)\\E(.*)/|/$1\Q$2\E$3/|;
 }

 if( $AR[1] and my( $reg )= $AR[1] =~ m|^/(.+)/$| ){
  die" nothing in regex\n" 
   if system("perl -e '$AR[1]=~/$reg/' 2>/dev/null") or
    $AR[1] =~ m!/\^*[+*]+/|\[\.\.]!;
 }

 if( $re->{'NEW'} or not -f "$ENV{'HOME'}/.BREW_LIST/DB" ){
  $name->{'NEW'} = 1; $re->{'S_OPT'} = $re->{'BL'} = $re->{'DAT'} = 0;
   die " exist \033[31mLOCK\033[37m\n" if -d "$ENV{HOME}/.BREW_LIST/LOCK";
    print" wait\n";
 }elsif( $re->{'COM'} or $re->{'INF'} or $AR[1] and $name->{'LIST'} ){
  if( $re->{'INF'} ){
   $AR[1] ? $re->{'INF'} = lc $AR[1] : Died_1();
   $re->{'CLANG'}=`clang --version|awk '/Apple/{print \$NF}'|sed 's/.*-\\([^.]*\\)\..*/\\1/'` if $re->{'MAC'};
    if( $re->{'TREE'} ){
     unlink "$ENV{'HOME'}/.BREW_LIST/tree.txt";
      open $Files,'>',"$ENV{'HOME'}/.BREW_LIST/tree.txt" or die " tree $!\n";
    }
  }else{	
   $AR[1] ? $re->{'STDI'} = lc $AR[1] : Died_1();
    $name->{'L_OPT'} = $re->{'STDI'} =~ s|^/(.+)/$|$1| ? $re->{'STDI'} : "\Q$re->{'STDI'}\E";
  }
 }elsif( $re->{'S_OPT'} ){
  $AR[1] ? $ref->{'STDI'} = lc $AR[1] : Died_1();
   $re->{'S_OPT'} = $ref->{'S_OPT'} =
    $ref->{'STDI'} =~ s|^/(.+)/$|$1| ? $ref->{'STDI'} : "\Q$ref->{'STDI'}\E";
 }

 if( $re->{'LIN'} ){
  Init_1( $re ); Format_1( $re );
 }elsif( $re->{'S_OPT'} or $re->{'BL'} or $re->{'DAT'} ){
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
} Main_1;

sub Died_1{
 die "   Option : -new creat new cache
  -l formula list : -i instaled formula : - brew list command
  -lb bottled install formula : -lx can't install formula
  -s type search name : -o outdated : -co library display
  -in formula require formula : -t formula require formula, display tree
   Only mac : Cask
  -c cask list : -ci instaled cask
  -cx can't install cask : -cs some name cask and formula\n";
}

sub Init_1{
 my( $re,$list,$ls ) = @_;
 if( $re->{'NEW'} ){
   if( system('curl https://formulae.brew.sh/formula >/dev/null 2>&1') ){
    print " \033[31mNot connected\033[37m\n"; exit;
   }
  Wait_1();
 }
 $list = ( $re->{'S_OPT'} or $re->{'BL'} ) ?
  Dirs_1( $re->{'CEL'},1 ) : Dirs_1( $re->{'CEL'},0,$re );

 DB_1( $re );
  DB_2( $re ) if $re->{'LIST'} or $re->{'PRINT'} or $re->{'DAT'};
   Info_1( $re ) if $re->{'INF'};

 $re->{'COM'} ? Command_1( $re,$list ) : $re->{'BL'} ?
  Brew_1( $re,$list ) : $re->{'TREE'} ?
   return : File_1( $re,$list );
}

sub Wait_1{
 mkdir "$ENV{HOME}/.BREW_LIST/WAIT" unless -d "$ENV{HOME}/.BREW_LIST/WAIT";
  my $pid = fork;
   die " Wait Not fork : $!\n" unless defined $pid;
  if($pid){ $|=1;
    while(1){
     -d "$ENV{HOME}/.BREW_LIST/WAIT" ? ( print '.' and sleep 1 ) : last;
    }
   waitpid($pid,0);
   -f "$ENV{'HOME'}/.BREW_LIST/DB" ? die "\n Creat new cache\n" : die"\n Can not Created\n";
  }else{
   system('~/.BREW_LIST/font.sh'); exit;
  }
}

sub DB_1{
my $re = shift;
 if( $re->{'FOR'} ){
  opendir my $dir,$re->{'BIN'} or die " DB_1 $!\n";
   for my $com(readdir($dir)){
    my $hand = readlink("$re->{'BIN'}/$com");
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
 tie my %tap,"NDBM_File","$ENV{'HOME'}/.BREW_LIST/DBM",O_RDONLY,0;
   %NA = %tap;
  untie %tap;
 $re->{'OS'} = %NA ? \%NA : die " Not read DBM\n";
}

sub Brew_1{
my( $re,$list ) = @_;
 for(my $i=0;$i<@$list;$i++){  my( $tap ) = $list->[$i] =~ /^\s(.*)\n/;
  Mine_1( $tap,$re,0 ) if $re->{'DMG'}{$tap} or $re->{'HASH'}{$tap};
 }
}

sub File_1{
my( $re,$list,$file,$test,$tap1,$tap2,$tap3 ) = @_;
 open my $BREW,'<',$re->{'TXT'} or die " File_1 $!\n";
  @$file = <$BREW>;
 close $BREW;
 if( $re->{'CAS'} and $re->{'S_OPT'} and -f $re->{'FON'} and -f $re->{'DRI'} and -f $re->{'VER'} ){

   if( $re->{'FDIR'} and $re->{'DDIR'} and $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'FON'},0) };
     push @$file,@{ File_2( $re->{'DRI'},0) };
      push @$file,@{ File_2( $re->{'VER'},0) };
       @$file = sort{$a cmp $b}@$file;

   }elsif( not $re->{'FDIR'} and $re->{'DDIR'} and $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'DRI'},0) };
     push @$file,@{ File_2( $re->{'VER'},0) };
      @$file = sort{$a cmp $b}@$file;
      push @$file,@{ File_2( $re->{'FON'},1) };

   }elsif( not $re->{'FDIR'} and not $re->{'DDIR'} and $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'VER'},0) };
     @$file = sort{$a cmp $b}@$file;
      push @$file,@{ File_2( $re->{'FON'},1) };
       push @$file,@{ File_2( $re->{'DRI'},2) };

   }elsif( not $re->{'FDIR'} and  $re->{'DDIR'} and not $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'DRI'},0) };
     @$file = sort{$a cmp $b}@$file;
      push @$file,@{ File_2( $re->{'FON'},1) };
       push @$file,@{ File_2( $re->{'VER'},3) };

   }elsif( not $re->{'FDIR'} and not $re->{'DDIR'} and not $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'FON'},1) };
     push @$file,@{ File_2( $re->{'DRI'},2) };
      push @$file,@{ File_2( $re->{'VER'},3) };

   }elsif( $re->{'FDIR'} and not $re->{'DDIR'} and $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'FON'},0) };
     push @$file,@{ File_2( $re->{'VER'},0) };
      @$file = sort{$a cmp $b}@$file;
       push @$file,@{ File_2( $re->{'DRI'},2) };

   }elsif( $re->{'FDIR'} and not $re->{'DDIR'} and not $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'FON'},0) };
     @$file = sort{$a cmp $b}@$file;
      push @$file,@{ File_2( $re->{'DRI'},2) };
       push @$file,@{ File_2( $re->{'VER'},3) };

   }elsif( $re->{'FDIR'} and $re->{'DDIR'} and not $re->{'VERS'} ){
    push @$file,@{ File_2( $re->{'FON'},0) };
     push @$file,@{ File_2( $re->{'DRI'},0) };
      @$file = sort{$a cmp $b}@$file;
       push @$file,@{ File_2( $re->{'VER'},3) };
   }
 }
 Search_1( $list,$file,0,$re );
}

sub File_2{
my( $dir,$ls,$file ) = @_;
 open my $BREW,'<',$dir or die " File_2 $!\n";
  while(my $brew = <$BREW>){ chomp $brew;
   $ls == 1 ? push @$file,"homebrew/cask-fonts/$brew" :
   $ls == 2 ? push @$file,"homebrew/cask-drivers/$brew" :
   $ls == 3 ? push @$file,"homebrew/cask-versions/$brew" :
   push @$file,$brew;
  }
 close $BREW;
$file;
}

sub Read_1{
 my( $re,$bottle,$brew,$ls ) = @_;
  $re->{'OS'}{"${brew}ver"} = $re->{'HASH'}{$ls} unless $re->{'OS'}{"${brew}ver"};
 ( not $bottle and not $re->{'HASH'}{$brew} or
   not $bottle and ( $re->{'OS'}{"${brew}ver"} gt $re->{'HASH'}{$brew} ) ) and
 ( not $re->{'HASH'}{$ls} or $re->{'OS'}{"${ls}ver"} gt $re->{'HASH'}{$ls} ) ?
  return 1 : return 0;
}

sub Info_1{
my( $re,$file,$spa ) = @_; my $IN = 0;
 print "\033[33mCan't install $re->{'INF'}...\033[37m\n" 
  if not $file and ( $re->{'MAC'} and $re->{'OS'}{"$re->{'INF'}un_xcode"} or
                     $re->{'LIN'} and $re->{'OS'}{"$re->{'INF'}un_Linux"} );

 my $name = $file ? $re->{'OS'}{"${file}core"} :
  $re->{'OS'}{"$re->{'INF'}core"} ? $re->{'OS'}{"$re->{'INF'}core"} : exit;
   my( $brew ) = $name =~ m|.+/(.+)\.rb$|;
    my $bottle =  $re->{'OS'}{"$brew$OS_Version"} ? 1 : 0;
     $spa .= $spa ? '   |' : '|';

 open my $BREW1,'<',$name or die " Info_1 $!\n";
  while(my $data=<$BREW1>){
   if( $re->{'MAC'} ){
     if( $data =~ /^\s*on_linux\s*do/ ){ $IN = 1; next;
     }elsif( $data !~ /^\s*end/ and $IN == 1 ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 1){ $IN = 0; next;
     }
   }else{
     if( $data =~ /^\s*on_macos\s+do/ ){ $IN = 2; next;
     }elsif( $data !~ /^\s*end/ and $IN == 2  ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 2){ $IN = 0; next;
     } 
   }

   if( $data =~ /^\s*head do/ ){ $IN = 3; next;
   }elsif( $data !~ /^\s*end/ and $IN == 3 ){ next;
   }elsif( $data =~ /^\s*end/ and $IN == 3){ $IN = 0; next;
   }

   if( $re->{'MAC'} ){
    if( $IN or $data =~ /^\s*if\s+Hardware::CPU/ ){
     $IN = $data =~ /$CPU/ ? 4 : 5 unless $IN;
      if( $IN == 4 and $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
       if( Read_1( $re,$bottle,$brew,$data ) ){
          $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data (build)\n" : 1;
           Info_1( $re,$data,$spa ); next;
       }
      }elsif( $IN == 4 and $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
          $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data\n" : 1;
           Info_1( $re,$data,$spa ); next;
      }elsif( $IN == 4 and $data =~ /^\s*else|^\s+end/ ){
          $IN = 0; next;
      }elsif( $IN == 5 and $data =~ /^\s*depends_on/ ){
          next;
      }elsif( $IN == 5 and $data =~ /^\s*end/ ){
          $IN = 0; next;
      }elsif( $IN == 5 and $data =~ /^\s*else/ ){
          $IN = 6; next;
      }elsif( $IN == 6 and $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
       if( Read_1( $re,$bottle,$brew,$data ) ){
          $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data (build)\n" : 1;
           Info_1( $re,$data,$spa ); next;
       }
      }elsif( $IN == 6 and $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
          $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data\n" : 1;
           Info_1( $re,$data,$spa ); next;
      }elsif( $IN == 6 and $data =~ /^\s+end/ ){
          $IN = 0; next;
      }
    }
   }

   if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
    next;
   }elsif (my( $cpu1,$cpu2 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build\s+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
     if( $re->{'MAC'} and $cpu2 =~ /$CPU/ ){
      if( Read_1( $re,$bottle,$brew,$cpu1 ) ){				
        $re->{'OS'}{"deps$cpu1"} = $re->{'TREE'} ? print $Files "${spa}-- $cpu1 (build)\n" : 1;
         Info_1( $re,$cpu1,$spa );
      }
     } next;
   }elsif( my( $cpu3,$cpu4 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build.+unless\s+Hardware::CPU\.([^\s]+).*\n/ ){
     if( $re->{'MAC'} and $cpu4 !~ /$CPU/ ){
      if( Read_1( $re,$bottle,$brew,$cpu3 ) ){
        $re->{'OS'}{"deps$cpu3"} = $re->{'TREE'} ? print $Files "${spa}-- $cpu3 (build)\n" : 1;
         Info_1( $re,$cpu3,$spa );
      }
     } next;
   }elsif( my( $ls1,$ls2,$ls3 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build\s+if\s+MacOS.version\s+([^\s]+)\s+:([^\s]+).*\n/ ){
     if( $re->{'MAC'} and eval"$OS_Version2 $ls2 $MAC_OS{$ls3}" ){
      if( Read_1( $re,$bottle,$brew,$ls1 ) ){
        $re->{'OS'}{"deps$ls1"} = $re->{'TREE'} ? print $Files "${spa}-- $ls1 (build)\n" : 1;
         Info_1( $re,$ls1,$spa );
      }
     } next;
   }elsif( my( $ls4,$ls5,$ls6 ) =
    $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>.+:build\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+).*\n/ ){
     if( $re->{'MAC'} and eval"$re->{'CLANG'} $ls5 $ls6" ){
      if( Read_1( $re,$bottle,$brew,$ls4 ) ){
        $re->{'OS'}{"deps$ls4"} = $re->{'TREE'} ? print $Files "${spa}-- $ls4 (build)\n" : 1;
         Info_1( $re,$ls4,$spa );
      }
     } next;
   }elsif( my( $ls7,$ls8 ) =
    $data =~ /^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build,\s+since:\s+:([^\s]+).*\n/ ){
     if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$ls8} ){
      if( Read_1( $re,$bottle,$brew,$ls7 ) ){
        $re->{'OS'}{"deps$ls7"} = $re->{'TREE'} ? print $Files "${spa}-- $ls7 (build)\n" : 1;
         Info_1( $re,$ls7,$spa );
      }
     } next;
   }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
     if( Read_1( $re,$bottle,$brew,$data ) ){
        $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data (build)\n" : 1;
         Info_1( $re,$data,$spa );
     } next;
   }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
     if( Read_1( $re,$bottle,$brew,$data ) ){
        $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data (build)\n" : 1;
         Info_1( $re,$data,$spa );
     } next;
   }

   if( $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*\sif\s).*\n/$1/ ){
     $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data\n" : 1;
         Info_1( $re,$data,$spa );
   }elsif( my( $ls1,$ls2 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+).*\n/ ){
    if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$ls2} ){
        $re->{'OS'}{"deps$ls1"} = $re->{'TREE'} ? print $Files "${spa}-- $ls1\n" : 1;
         Info_1( $re,$ls1,$spa );
    }
   }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
    $re->{'OS'}{"deps$data"} = $re->{'TREE'} ? print $Files "${spa}-- $data\n" : 1;
     Info_1( $re,$data,$spa );
   }elsif( $data =~ /^\s*depends_on.+\s*if\s*/ ){
    if( my( $ls1,$ls2,$ls3 ) =
     $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+).*\n/ ){
      if( $re->{'MAC'} and eval"$OS_Version2 $ls2 $MAC_OS{$ls3}" ){
        $re->{'OS'}{"deps$ls1"} = $re->{'TREE'} ? print $Files "${spa}-- $ls1\n" : 1;
         Info_1( $re,$ls1,$spa );
      }
    }elsif( my($ls4,$ls5,$ls6) =
     $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+).*\n/ ){
      if( $re->{'MAC'} and eval"$re->{'CLANG'} $ls5 $ls6" ){
        $re->{'OS'}{"deps$ls4"} = $re->{'TREE'} ? print $Files "${spa}-- $ls4\n" : 1;
         Info_1( $re,$ls4,$spa );
      }
    }elsif( my( $ls7,$ls8 ) =
     $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
      if( $re->{'MAC'} and $ls8 =~ /$CPU/ ){
        $re->{'OS'}{"deps$ls7"} = $re->{'TREE'} ? print $Files "${spa}-- $ls7\n" : 1;
         Info_1( $re,$ls7,$spa );
      }
    }
   }
  }
 close $BREW1;
}

sub Dirs_1{
my( $url,$ls,$re,$bn ) = @_;
 my $an = [];
 opendir my $dir_1,"$url" or die " Dirs_1 $!\n";
  for my $hand_1(readdir($dir_1)){
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
   for my $hand_2(readdir($dir_2)){
    next if $hand_2 =~ /^\./;
     push @$bn,"$hand_2\n";
   }
  closedir $dir_2;
 }
 $bn;
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

sub Search_1{
my( $list,$file,$in,$re ) = @_;
 for(my $i=0;$file->[$i];$i++){ my $pop = 0;
  my( $brew_1,$brew_2,$brew_3 ) = split("\t",$file->[$i]);
   my $mem = ( $re->{'L_OPT'} and $brew_1 =~ /$re->{'L_OPT'}/o ) ? 1 : 0;
    $brew_2 = $re->{'OS'}{"${brew_1}version"} if $re->{'CAS'} and $re->{'OS'}{"${brew_1}version"};

  if( not $re->{'LINK'} or
      $re->{'LINK'} == 1 and $re->{'OS'}{"${brew_1}un_xcode"} or
      $re->{'LINK'} == 2 and $re->{'OS'}{"${brew_1}un_Linux"} or
      $re->{'LINK'} == 3 and $re->{'OS'}{"$brew_1$OS_Version"} or
      $re->{'LINK'} == 4 and $re->{'OS'}{"${brew_1}un_cask"} or
      $re->{'LINK'} == 5 and $re->{'OS'}{"${brew_1}so_name"} or
      $re->{'LINK'} == 6 and $re->{'OS'}{"deps$brew_1"} ){

    if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
     Tap_1( $list,$re,\$in );
      $i-- and next;
    }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
     ( $re->{'DMG'}{$brew_1} or $re->{'HASH'}{$brew_1} ) ?
      Mine_1( $brew_1,$re,1 ) : Mine_1( $brew_1,$re,0 )
       if $re->{'S_OPT'} and $brew_1 =~ /$re->{'S_OPT'}/o;
        $in++ and $re->{'IN'}++; $pop = 1;
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
         $i-- and next;
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
             $in++ and $i-- and next;
     }else{
      if( $re->{'FOR'} and $brew_2 gt $re->{'HASH'}{$brew_1} or
          $re->{'CAS'} and $brew_2 gt $re->{'DMG'}{$brew_1} ){
        $re->{'TAR'} = $re->{'MAC'} ?
         Dirs_1( "$ENV{'HOME'}/Library/Caches/Homebrew",2 ) :
          Dirs_1( "$ENV{'HOME'}/.cache/Homebrew",2 ) unless $re->{'TAR'};

        for my $gz( @{$re->{'TAR'}} ){
          if( $gz=~s/$brew_1--(\d.+)\.tar.*/$1/ ){
           $re->{'GZ'} = 1 if $re->{'HASH'}{$brew_1} lt $gz;
            last;
          }
        }
         $re->{'GZ'} ? Type_1( $re,$brew_1,'(i)','e' ) : Type_1( $re,$brew_1,'(i)' );
          $re->{'OUT'}[$re->{'UP'}++] = ( $re->{'FOR'} and $re->{'GZ'} ) ?
           " e $brew_1 $re->{'HASH'}{$brew_1} < $brew_2\n" : ( $re->{'CAS'} and $re->{'GZ'} ) ?
           " e $brew_1 $re->{'DMG'}{$brew_1} < $brew_2\n"  : $re->{'FOR'} ?
           "   $brew_1 $re->{'HASH'}{$brew_1} < $brew_2\n" : "   $brew_1 $re->{'DMG'}{$brew_1} < $brew_2\n";
         $re->{'GZ'} = 0;
      }elsif( $re->{'CAS'} and $brew_2 ne $re->{'DMG'}{$brew_1} ){
          Type_1( $re,$brew_1,'(i)' );
           $re->{'OUT'}[$re->{'UP'}++] =  "   $brew_1 $re->{'DMG'}{$brew_1} != $brew_2\n";
      }else{
          Type_1( $re,$brew_1,' i ' );
      }
     }
     $in++;
    }
    $re->{'MEM'} .= "$brew_2\t$brew_3";
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
my( $list,$re,$in,$com ) = @_;
 my( $tap ) = $list->[$$in] =~ /^\s(.*)\n/;
  my $mem = ( $re->{'L_OPT'} and $tap =~ /$re->{'L_OPT'}/ ) ? 1 : 0;
   my $dir = $re->{'FOR'} ? $re->{'OS'}{"${tap}core"} : $re->{'OS'}{"${tap}cask"};

 open my $file,'<',$dir or die" Tap file $!\n";
  while(my $name=<$file>){
   $com = $1 and last if $name =~ /^\s*desc\s+"([^"]+)"/;
    $com = $1 if $name =~ /^\s*name\s+"([^"]+)"/;
  }
 close $file;

   my $brew = 1;
 if( $re->{'LINK'} and $re->{'LINK'} == 1 and not $re->{'OS'}{"${tap}un_xcode"} or
     $re->{'LINK'} and $re->{'LINK'} == 2 and not $re->{'OS'}{"${tap}un_Linux"} or
     $re->{'LINK'} and $re->{'LINK'} == 3 and not $re->{'OS'}{"$tap$OS_Version"} or
     $re->{'LINK'} and $re->{'LINK'} == 4 and not $re->{'OS'}{"${tap}un_cask"} or
     $re->{'LINK'} and $re->{'LINK'} == 5 and not $re->{'OS'}{"${tap}so_name"} or
     $re->{'LINK'} and $re->{'LINK'} == 6 and not $re->{'OS'}{"deps$tap"} ){
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
    }elsif( $re->{'FOR'} ){
         $re->{'MEM'} = "      i  $tap\t$re->{'HASH'}{$tap}\t$com\n";
    }else{
         $re->{'MEM'} = "      i  $tap\t$re->{'DMG'}{$tap}\t$com\n";
    }
     Type_1( $re,$tap,' i ' ) if $re->{'MEM'} !~ /^\s+X\s+/;
      Memo_1( $re,$mem,0 ) if $brew;
       $re->{'AN'}++ and $re->{'IN'}++ if $brew;
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
    $re->{'OS'}{"${brew_1}so_name"} ? $re->{'MEM'} =~ s/^.{9}/   s $i / :
    $re->{'OS'}{"${brew_1}formula"} ? $re->{'MEM'} =~ s/^.{9}/   f $i / :
                                      $re->{'MEM'} =~ s/^.{9}/     $i /; 
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
 for(my $in=0;$list->[$in];$in++){
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
  if( $re->{'TREE'} and close $Files ){
    Format_2( $re );
  }elsif( $re->{'LIST'} or $re->{'PRINT'} ){
   system(" printf '\033[?7l' ") if( $re->{'MAC'} and -t STDOUT );
    system('setterm -linewrap off') if( $re->{'LIN'} and -t STDOUT );
     $re->{'L_OPT'} ? print"$re->{'EXC'}" : print"$re->{'ALL'}" if $re->{'ALL'} or $re->{'EXC'};
     print " item $re->{'AN'} : install $re->{'IN'}\n" if $re->{'ALL'} or $re->{'EXC'};
   system(" printf '\033[?7h' ") if( $re->{'MAC'} and -t STDOUT );
    system('setterm -linewrap on') if( $re->{'LIN'} and -t STDOUT );
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
       print"\n" unless $ze = $in % $size;
       $in++;
      }
     print"\n" if $ze;
    $re->{'CAS'} = 0;
   }else{
    print"$_\n" for @{$re->{'ARR'}};
    $re->{'CAS'} = 0;
   }
  }
print "\033[33m$re->{'FILE'}\033[37m" if $re->{'FILE'} and ( $re->{'ALL'} or $re->{'EXC'} );
 Nohup_1( $re ) if $re->{'CAS'} or $re->{'FOR'};
}

sub Format_2{
my $re = shift;
 my( $wap,$leng,@TODO ); my $cou = 0;
  open my $file,"$ENV{'HOME'}/.BREW_LIST/tree.txt";
   my @DATA =<$file>;
  close $file;

 for(@DATA){ my $an;
  $wap++;
  $_ =~ s/\|/│/g;
  $_ =~ s/\│--/├──/g;
   my @an = split('   ',$_);
   for(@an){ $an++;
     $cou = $an if $cou < $an;
   } $an = 0;
 }

 for(my $i=0;$i<$cou;$i++){ my $in;
  $leng = $in = 0;
  for my $data(@DATA){  $leng++;
   my @an = split('   ',$data);
   for(@an){
    $TODO[$in] = $leng if $an[$i] and $an[$i] =~ /├──/;
    if( not $an[$i] and $TODO[$in] or
       $wap == $leng and $an[$i] and $an[$i] !~ /├──/ ){
     $TODO[++$in] = $leng;
      $wap != $leng ? $in++ : last;	
    }
   }
  }
   $wap = $leng = 0;
  for(my $p=0;$p<@DATA;$p++){
   $wap++; my $plus;
   my @an = split('   ',$DATA[$p]);
    for(my $e=0;$e<@an;$e++){
      if( $TODO[$leng] and $TODO[$leng] < $wap and $TODO[$leng+1] >= $wap ){
       $an[$i] =~ s/\│$/#/ if $an[$i];
      }
     $an[$e] =~ s/├──/└──/ if $TODO[$leng] and $TODO[$leng] == $wap;
      $leng += 2 if $TODO[$leng+1] and $TODO[$leng+1] == $wap;
       $an[$e] =  "   $an[$e]";
        $plus .= $an[$e];
    }
   $plus =~ s/^   //;
    @DATA[$p] = $plus;
     $plus = '';
  }
 }
 print"$re->{'INF'}\n" if @DATA;
  for(@DATA){ s/#/ /g; print; }
   unlink "$ENV{'HOME'}/.BREW_LIST/tree.txt";
}

sub Nohup_1{
 my $re = shift;
  my $time =[localtime((stat($re->{'TXT'}))[9])] if -f $re->{'TXT'};
  my( $year,$mon,$day ) = (
   ((localtime(time))[5] + 1900),((localtime(time))[4]+1),((localtime(time))[3]));
  if( not -f $re->{'TXT'} or  $year > $time->[5]+1900 or
      $mon > $time->[4]+1 or $day > $time->[3] ){
   system('nohup ~/.BREW_LIST/font.sh >/dev/null 2>&1 &');
  }
}
__END__
