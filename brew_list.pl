#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use NDBM_File;
use Fcntl ':DEFAULT';
my $OS_Version;

my $re  = {
 'LEN1'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,
  'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html",
   'CEL'=>'/usr/local/Cellar','BIN'=>'/usr/local/opt',
    'TXT'=>"$ENV{'HOME'}/.BREW_LIST/brew.txt"};

my $ref = {
 'LEN1'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,
  'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html",
   'CEL'=>'/usr/local/Caskroom','LEN2'=>1,'LEN3'=>1,
    'TXT'=>"$ENV{'HOME'}/.BREW_LIST/cask.txt",
     'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
      'DRI'=>"$ENV{'HOME'}/.BREW_LIST/Q_DRIV.txt"};

$^O eq 'darwin' ? $re->{'MAC'} = $ref->{'MAC'}= 1 :
 $^O eq 'linux' ? $re->{'LIN'} = 1 : exit;
 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
    $OS_Version = 'Linux';
 }else{
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/(\d\d.\d+)\.?\d*\n/$1/;
   $OS_Version =~ s/^11/11.0/;
   my $cpu = `sysctl machdep.cpu.brand_string`;
    $OS_Version = "${OS_Version}M1" if $cpu =~ /Apple\s*M1/;
 }
$ref->{'FDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
$ref->{'DDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';

exit unless -d $re->{'CEL'};
 mkdir "$ENV{'HOME'}/.BREW_LIST" unless -d "$ENV{'HOME'}/.BREW_LIST";
  if( not -f "$ENV{'HOME'}/.BREW_LIST/font.sh" or not -f "$ENV{'HOME'}/.BREW_LIST/tie.pl" or
     -f "$FindBin::Bin/font.sh" and `diff $FindBin::Bin/font.sh ~/.BREW_LIST/font.sh` or
     -f "$FindBin::Bin/tie.pl"  and `diff $FindBin::Bin/tie.pl ~/.BREW_LIST/tie.pl` ){
      die " cp: $FindBin::Bin/ font.sh or tie.pl : No snuch file\n"
       if system("cp $FindBin::Bin/font.sh $FindBin::Bin/tie.pl ~/.BREW_LIST/.");
  }

 my @AR = @ARGV; my $name;
  Died_1() unless $AR[0];
if( $AR[0] eq '-l' ){ $name = $re;  $re->{'LIST'}  = 1;
}elsif( $AR[0] eq '-i' ){  $name = $re;  $re->{'PRINT'} = 1;
}elsif( $AR[0] eq '-c' ){  $name = $ref; $ref->{'LIST'} = 1; Died_1() if $re->{'LIN'};
}elsif( $AR[0] eq '-ci'){  $name = $ref; $ref->{'PRINT'} = 1; Died_1() if $re->{'LIN'};
}elsif( $AR[0] eq '-lx' ){ $name = $re; $re->{'LINK'} = 1; $re->{'LIST'} = 1; $re->{'LINK'}=3 if $re->{'LIN'};
}elsif( $AR[0] eq '-lb' ){ $name = $re; $re->{'LINK'} = 2; $re->{'LIST'} = 1;
}elsif( $AR[0] eq '-co' ){ $name = $re; $re->{'COM'} = 1;
}elsif( $AR[0] eq '-new' ){$name = $re; $re->{'NEW'} = 1;
}elsif( $AR[0] eq '-s' ){  $name = $re; $re->{'S_OPT'} = 1;
}elsif( $AR[0] eq '-' ){   $name = $re; $re->{'BL'} = $ref->{'BL'} = 1;
}else{  Died_1(); }

if( $re->{'NEW'} or not -f "$ENV{'HOME'}/.BREW_LIST/DB" ){
 $name->{'NEW'} = 1; $re->{'S_OPT'} = $re->{'BL'} = 0;
  print" wait\n";
}

if( $AR[1] and $AR[1] =~ m!/.*(\\Q|\\E).*/!i ){
 $AR[1] !~ /.*\\Q.+\\E.*/ ? die" nothing in regex\n" :
  $AR[1] =~ s|/(.*)\\Q(.+)\\E(.*)/|/$1\Q$2\E$3/|;
}

if( $AR[1] and my( $reg )= $AR[1] =~ m|^/(.+)/$| ){
 die" nothing in regex\n" 
  if system("perl -e '$AR[1]=~/$reg/' 2>/dev/null") or
   $AR[1] =~ m!/\^*[+*]+/|\[\.\.]!;
}

if( $re->{'COM'} or $AR[1] and $name->{'LIST'} ){
 $AR[1] ? $re->{'STDI'} = lc $AR[1] : Died_1();
  $name->{'L_OPT'} = $re->{'STDI'} =~ s|^/(.+)/$|$1| ? $re->{'STDI'} : "\Q$re->{'STDI'}\E";
}elsif( $re->{'S_OPT'} ){
 $AR[1] ? $ref->{'STDI'} = lc $AR[1] : Died_1();
  $re->{'S_OPT'} = $ref->{'S_OPT'} =
   $ref->{'STDI'} =~ s|^/(.+)/$|$1| ? $ref->{'STDI'} : "\Q$ref->{'STDI'}\E";
}

if( $re->{'LIN'} ){
 Linux_1( $re ); Format_1( $re );
}elsif( $re->{'S_OPT'} or $re->{'BL'} ){
 my $pid = fork;
 die "Not fork : $!\n" unless defined $pid;
  if($pid){
   Darwin_1( $ref );
  }else{
   Darwin_1( $re );
  }
  if($pid){
   waitpid($pid,0);
   Format_1( $ref );
  }else{
   Format_1( $re ); exit;
  }
}else{ Darwin_1( $name ); Format_1( $name ); }

sub Died_1{
 die "  Option : '-new' Creat new cachae
  -l List : -i Instaled list : - Brew List
  -lb Bottled install List : -lx Cannot install List
  -s Type search name : -co Search to Comannd
  Only mac
  -c Casks list : -ci Casks instaled list\n";
}

sub Darwin_1{
 my( $re,$list,$ls ) = @_;
  if( $re->{'NEW'} ){
   my $url = 'https://formulae.brew.sh/formula/index.html';
    if( system("curl -so $re->{'DIR'} $url") ){ $ls = 1;
     print " \033[31mNot connected\033[37m\n";
    }
   system('~/.BREW_LIST/font.sh');
    ( -f "$ENV{'HOME'}/.BREW_LIST/DB" and not $ls ) ? die " Creat new cacahe\n" :
     ( -f "$ENV{'HOME'}/.BREW_LIST/DB" and $ls ) ? exit : die" Can not Created\n";
  }
 $list = ( $re->{'S_OPT'} or $re->{'BL'} ) ?
  Dirs_1( $re->{'CEL'},1 ) : Dirs_1( $re->{'CEL'},0,$re );

 DB_1( $re );
  DB_2( $re ) if $re->{'FOR'} and not $re->{'S_OPT'} and not $re->{'BL'};

 $re->{'COM'} ? Command_1( $re,$list ) : $re->{'BL'} ?
  Brew_1( $re,$list ) : File_1( $re,$list );
}

sub Linux_1{
 my( $re,$list,$ls ) = @_;
  if( $re->{'NEW'} ){
   my $url = 'https://formulae.brew.sh/formula-linux/index.html';
    if( system("curl -so $re->{'DIR'} $url") ){ $ls = 1;
     print " \033[31mNot connected\033[37m\n";
    }
   system('~/.BREW_LIST/font.sh');
    ( -f "$ENV{'HOME'}/.BREW_LIST/DB" and not $ls ) ? die " Creat new cacahe\n" :
     ( -f "$ENV{'HOME'}/.BREW_LIST/DB" and $ls ) ? exit : die" Can not Created\n";
  }
 $list = ( $re->{'S_OPT'} or $re->{'BL'} ) ?
  Dirs_1( $re->{'CEL'},1 ) : Dirs_1( $re->{'CEL'},0,$re );

 DB_1( $re );
  DB_2( $re ) if $re->{'FOR'} and not $re->{'S_OPT'} and not $re->{'BL'};

 $re->{'COM'} ? Command_1( $re,$list ) : $re->{'BL'} ? 
  Brew_1( $re,$list ) : File_1( $re,$list );
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
 $re->{'OS'} = %NA ? \%NA : '';
}

sub Brew_1{
my( $re,$list ) = @_;
 for(my $i=0;$i<@$list;$i++){  my( $tap ) = $list->[$i] =~ /^\s(.*)\n/;
  Mine_1( $tap,$re,0 ) if $re->{'DMG'}{$tap} or $re->{'HASH'}{$tap};
 }
}

sub File_1{
my( $re,$list,$file,$test,$tap1,$tap2,$tap3 ) = @_;
 if( -f $re->{'TXT'} ){
  open my $BREW,'<',$re->{'TXT'} or die " File_1 $!\n";
   @$file = <$BREW>;
  close $BREW;
 }else{
  open my $BREW,'<',$re->{'DIR'} or die " File_1 $!\n";
   while(my $brew = <$BREW>){
    if( $brew =~ s|^\s+<td><a href[^>]+>(.+)</a></td>\n|$1| ){
     $tap1 = $brew; next;
    }elsif( not $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
     $tap2 = $brew;
     $test = 1; next;
    }elsif( $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
     $tap3 = $brew;
     $test = 0;
    }
     if( $tap1 and $re->{'FOR'} ){
      push @$file,"$tap1\t$tap2\t$tap3\n";
     }elsif( $tap1 and $re->{'CAS'} ){
      push @$file,"$tap1\t$tap3\t$tap2\n";
     }
    $tap1 = $tap2 = $tap3 = '';
   }
   close $BREW;
  @$file = sort{$a cmp $b}@$file if $re->{'FOR'};
 }
 if( $re->{'CAS'} and $re->{'S_OPT'} and  -f $re->{'FON'} and  -f $re->{'DRI'} ){
   if( $re->{'FDIR'} and $re->{'DDIR'} ){
    push @$file,@{ File_2( $re->{'FON'},0) };
     push @$file,@{ File_2( $re->{'DRI'},0) };
      @$file = sort{$a cmp $b}@$file;
   }elsif( $re->{'FDIR'} and not $re->{'DDIR'} ){
    push @$file,@{ File_2( $re->{'FON'},0) };
     @$file = sort{$a cmp $b}@$file;
      push @$file,@{ File_2( $re->{'DRI'},2) };
   }elsif( not $re->{'FDIR'} and  $re->{'DDIR'} ){
    push @$file,@{ File_2( $re->{'DRI'},0) };
     @$file = sort{$a cmp $b}@$file;
      push @$file,@{ File_2( $re->{'FON'},1) };
   }else{
    @$file = sort{$a cmp $b}@$file;
     push @$file,@{ File_2( $re->{'FON'},1) };
      push @$file,@{ File_2( $re->{'DRI'},2) };
   }
 }
 Search_1( $list,$file,0,$re );
}

sub File_2{
my( $dir,$ls,$file ) = @_;
 open my $BREW,'<',$dir or die " File_2 $!\n";
  while(my $brew = <$BREW>){ chomp $brew;
   $ls == 1 ? push @$file,"homebrew/cask-fonts/$brew" :
   $ls == 2 ? push @$file,"homebrew/cask-drivers/$brew" : push @$file,$brew;
  }
 close $BREW;
$file;
}

sub Dirs_1{
my( $url,$ls,$re,$bn ) = @_;
 my $an = [];
opendir my $dir_1,"$url" or die " Dirs_1 $!\n";
 for my $hand_1(readdir($dir_1)){
  next if $hand_1 =~ /^\./;
   $re->{'FILE'} .= " File exists $url/$hand_1\n" if -f "$url/$hand_1" and not $ls;
   if( $ls != 2 ){ next unless -d "$url/$hand_1"; }
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
 $name = "$name (I)" if $ls;
  $re->{'LEN'}{$name} = length $name;
   push @{$re->{'ARR'}},$name;
 if( $name =~ m|^homebrew/cask-drivers/| ){
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
    if( $re->{'CAS'} or not $re->{'OS'} ){
     $re->{'ALL'} .= " Check folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= " Check folder $re->{'CEL'} => $dir\n" if $mem;
    }else{
     $re->{'ALL'} .= "     Check folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= "     Check folder $re->{'CEL'} => $dir\n" if $mem;
    }
   for(my $i=0;$i<@$file;$i++){
    if( $re->{'CAS'} or not $re->{'OS'} ){
     $re->{'ALL'} .= @$file-1 == $i ? " $$file[$i]\n" : " $$file[$i]\t" unless $re->{'L_OPT'};
     $re->{'EXC'} .= @$file-1 == $i ? " $$file[$i]\n" : " $$file[$i]\t" if $mem;
    }else{
     $re->{'ALL'} .= @$file-1 == $i ? "    $$file[$i]\n" : "     $$file[$i]" unless $re->{'L_OPT'};
     $re->{'EXC'} .= @$file-1 == $i ? "    $$file[$i]\n" : "     $$file[$i]" if $mem;
    }
   }
  }else{
    if( $re->{'CAS'} or not $re->{'OS'} ){
     $re->{'ALL'} .= " Empty folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= " Empty folder $re->{'CEL'} => $dir\n" if $mem;
    }else{
     $re->{'ALL'} .= "     Empty folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
     $re->{'EXC'} .= "     Empty folder $re->{'CEL'} => $dir\n" if $mem;
    }
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

  if( not $re->{'LINK'} or
      $re->{'LINK'} == 1 and $re->{'OS'}{"${brew_1}un_xcode"} or
      $re->{'LINK'} == 2 and $re->{'OS'}{"$brew_1$OS_Version"} or
      $re->{'LINK'} == 3 and $re->{'OS'}{"${brew_1}un_Linux"} ){

    if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
     Tap_1( $list,$re,\$in );
      $i-- and next;
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
     if( $re->{'CAS'} or not $re->{'OS'} ){
       $re->{'MEM'} = "    $brew_1\t";
     }else{
      if( $re->{'MAC'} ){
       $re->{'MEM'} = ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg"} ) ?
        " b k     $brew_1\t" : $re->{'OS'}{"$brew_1$OS_Version"} ? " b       $brew_1\t" :
         ( $re->{'OS'}{"${brew_1}un_xcode"} and $re->{'OS'}{"${brew_1}keg"} ) ?
        " x k     $brew_1\t" : $re->{'OS'}{"${brew_1}un_xcode"} ? " x       $brew_1\t" :
        $re->{'OS'}{"${brew_1}keg"} ? "   k     $brew_1\t" : "         $brew_1\t";
      }else{
       $re->{'MEM'} = ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
        " b k     $brew_1\t" : $re->{'OS'}{"$brew_1$OS_Version"} ? " b       $brew_1\t" :
         ( $re->{'OS'}{"${brew_1}un_Linux"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
        " x k     $brew_1\t" : $re->{'OS'}{"${brew_1}un_Linux"}  ? " x       $brew_1\t" :
        $re->{'OS'}{"${brew_1}keg_Linux"} ? "   k     $brew_1\t" : "         $brew_1\t";
      }
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
          ( $re->{'CAS'} or not $re->{'OS'} ) ?
           $re->{'MEM'} =~ s/^\s{4}$brew_1\t/ X  $brew_1\tNot Formula\n/ :
            $re->{'MEM'} =~ s/^.{9}$brew_1\t/      X  $brew_1\tNot Formula\n/;
          Memo_1( $re,$mem,0 );
           $in++ and $i-- and next;
     }else{
      if( $re->{'FOR'} and $brew_2 gt $re->{'HASH'}{$brew_1} or
          $re->{'CAS'} and $brew_2 gt $re->{'DMG'}{$brew_1} ){
           ( $re->{'CAS'} or not $re->{'OS'} ) ?
            $re->{'MEM'} =~ s/^\s{3}/(i)/ : Type_1( $re,$brew_1,'(i)' );
      }else{
           ( $re->{'CAS'} or not $re->{'OS'} ) ?
            $re->{'MEM'} =~ s/^\s{3}/ i / : Type_1( $re,$brew_1,' i ' );
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
my( $list,$re,$in ) = @_;
 my( $tap ) = $list->[$$in] =~ /^\s(.*)\n/;
 my $mem = ( $re->{'L_OPT'} and $tap =~ /$re->{'L_OPT'}/ ) ? 1 : 0;

  my $brew = 1;
 if( $re->{'LINK'} and $re->{'LINK'} == 1 and not $re->{'OS'}{"${tap}un_xcode"} or
     $re->{'LINK'} and $re->{'LINK'} == 2 and not $re->{'OS'}{"$tap$OS_Version"} or
     $re->{'LINK'} and $re->{'LINK'} == 3 and not $re->{'OS'}{"${tap}un_Linux"} ){
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
         $re->{'MEM'} = ( $re->{'CAS'} or not $re->{'OS'} ) ?
          " X  $tap\tNot Formula\n" : "      X  $tap\tNot Formula\n";
    }elsif( $re->{'FOR'} ){
        $re->{'MEM'} = ( $re->{'CAS'} or not $re->{'OS'} ) ?
          " i  $tap\t$re->{'HASH'}{$tap}\n" : "      i  $tap\t$re->{'HASH'}{$tap}\n";
    }else{
        $re->{'MEM'} = ( $re->{'CAS'} or not $re->{'OS'} ) ?
          " i  $tap\t$re->{'DMG'}{$tap}\n" :  "      i  $tap\t$re->{'DMG'}{$tap}\n";
    }
     Type_1( $re,$tap,' i ' ) if $re->{'FOR'} and $re->{'OS'};
      Memo_1( $re,$mem,0 ) if $brew;
       $re->{'AN'}++; $re->{'IN'}++;
  }else{
   Memo_1( $re,$mem,$tap );
  }
 $$in++;
}

sub Type_1{
my( $re,$brew_1,$i ) = @_;
 if( $re->{'MAC'} ){
  ( $re->{'OS'}{"${brew_1}un_xcode"} and $re->{'OS'}{"${brew_1}keg"} ) ?
   $re->{'MEM'} =~ s/^.{9}/ t k $i / : $re->{'OS'}{"${brew_1}un_xcode"} ?
   $re->{'MEM'} =~ s/^.{9}/ t   $i / : 
  ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg"} ) ?
   $re->{'MEM'} =~ s/^.{9}/ b k $i / : $re->{'OS'}{"$brew_1$OS_Version"} ?
   $re->{'MEM'} =~ s/^.{9}/ b   $i / : $re->{'OS'}{"${brew_1}keg"} ?
   $re->{'MEM'} =~ s/^.{9}/   k $i / : $re->{'MEM'} =~ s/^.{9}/     $i /; 
 }else{
  ( $re->{'OS'}{"$brew_1$OS_Version"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
   $re->{'MEM'} =~ s/^.{9}/ b k $i / : $re->{'OS'}{"$brew_1$OS_Version"} ?
   $re->{'MEM'} =~ s/^.{9}/ b   $i / :
  ( $re->{'OS'}{"${brew_1}un_Linux"} and $re->{'OS'}{"${brew_1}keg_Linux"} ) ?
   $re->{'MEM'} =~ s/^.{9}/ x k $i / : $re->{'OS'}{"${brew_1}un_linux"} ?
   $re->{'MEM'} =~ s/^.{9}/ x   $i / : $re->{'OS'}{"${brew_1}keg_Linux"} ?
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
my( $re,$ls,$sl,$ze ) = @_;
  if( $re->{'LIST'} or $re->{'PRINT'} ){
   system(" printf '\033[?7l' ") if $re->{'MAC'};
    system('setterm -linewrap off') if $re->{'LIN'};
     $re->{'L_OPT'} ? print"$re->{'EXC'}" : print"$re->{'ALL'}" if $re->{'ALL'} or $re->{'EXC'};
     print " item $re->{'AN'} : install $re->{'IN'}\n" if $re->{'ALL'} or $re->{'EXC'};
   system(" printf '\033[?7h' ") if $re->{'MAC'};
    system('setterm -linewrap on') if $re->{'LIN'};
  }else{
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
  }
print "\033[33m$re->{'FILE'}\033[37m" if $re->{'FILE'} and ($re->{'ALL'} or $re->{'EXC'});
 Nohup_1( $re ) if $re->{'CAS'} or $re->{'FOR'};
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
Check Darwin
diff <(ls /usr/local/Cellar) <(brew list --formula)
diff <(ls /usr/local/Caskroom) <(brew list --cask)
Check Linux
diff <(ls /home/linuxbrew/.linuxbrew/Cellar) <(brew list --formula)
