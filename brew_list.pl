#!/usr/bin/perl
use strict;
use warnings;
use FindBin;

my $re  = {
 'LEN1'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,'EXC'=>'',
  'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html",
   'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
    'CEL'=>'/usr/local/Cellar','STDI'=>'',
     'BIN'=>'/usr/local/opt'};

my $ref = {
 'LEN1'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,'EXC'=>'',
  'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html",
   'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
    'DRI'=>"$ENV{'HOME'}/.BREW_LIST/Q_DRIV.txt",
     'CEL'=>'/usr/local/Caskroom','LEN2'=>1,'LEN3'=>1};

$^O =~ /^darwin/ ? $re->{'LIN'} = 0 :
 $^O =~ /^linux/ ? $re->{'LIN'} = 1 : exit;
 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
 }
$ref->{'FDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
$ref->{'DDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';

exit unless -d $re->{'CEL'};
 mkdir "$ENV{'HOME'}/.BREW_LIST" unless -d "$ENV{'HOME'}/.BREW_LIST";
  if( not -f "$ENV{'HOME'}/.BREW_LIST/font.sh" or
      -f "$FindBin::Bin/font.sh" and `diff $FindBin::Bin/font.sh ~/.BREW_LIST/font.sh` ){
    die " cp: $FindBin::Bin/font.sh : No snuch file\n"
   if system("cp $FindBin::Bin/font.sh ~/.BREW_LIST/font.sh 2>/dev/null");
  }

 my @AR = @ARGV; my $name;
  Died_1() unless $AR[0];
if( $AR[0] eq '-l' ){      $name = $re;  $re->{'LIST'}  = 1;
}elsif( $AR[0] eq '-i' ){  $name = $re;  $re->{'PRINT'} = 1;
}elsif( $AR[0] eq '-co' ){ $name = $re;  $re->{'COM'} = 1;
}elsif( $AR[0] eq '-c' ){  $name = $ref; $ref->{'LIST'} = 1;  Died_1() if $re->{'LIN'};
}elsif( $AR[0] eq '-ci' ){ $name = $ref; $ref->{'PRINT'} = 1; Died_1() if $re->{'LIN'};
}elsif( $AR[0] eq '-s' ){  $re->{'S_OPT'} = 1;
}elsif( $AR[0] eq '-' ){   $re->{'BL'} = $ref->{'BL'} = 1;
}else{  Died_1(); }

if( $AR[1] and my( $reg )= $AR[1] =~ m|^/(.+)/$| ){
 die" nothing in regex\n" 
  if system("perl -e '$AR[1]=~/$reg/' 2>/dev/null") or $AR[1] =~ m!/\^*[+*]+/|\[\.\.]!;
}

if( $re->{'COM'} or $AR[1] and $name->{'LIST'} ){
 $AR[1] ? $re->{'STDI'} = lc $AR[1] : Died_1();
  $name->{'L_OPT'} = $re->{'STDI'} =~ s|^/(.+)/$|$1| ? $re->{'STDI'} : "\Q$re->{'STDI'}";
}elsif( $re->{'S_OPT'} ){
 $AR[1] ? $ref->{'STDI'} = lc $AR[1] : Died_1();
  $re->{'S_OPT'} = $ref->{'S_OPT'} =
   $ref->{'STDI'} =~ s|^/(.+)/$|$1| ? $ref->{'STDI'} : "\Q$ref->{'STDI'}";
}

if( $re->{'LIN'} ){
 Linux_1( $re ); Format_1( $re );
}elsif( $re->{'S_OPT'} or $re->{'BL'} ){
 my $pid = fork;
 die "Not fork: $!\n" unless defined $pid;
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
 die "  Option
  -l List : -i Instaled list : - Brew List
  -s Type search name : -co Search to Comannd
  Only mac
  -c Casks list : -ci Casks instaled list\n";
}

sub Darwin_1{
 my( $re,$time,$list ) = @_;
  if( not -f $re->{'DIR'} ){
   if( $re->{'FOR'} ){
    my $ufo = 'https://formulae.brew.sh/formula/index.html';
     print " \033[31mNot connected\033[37m\n"
      if system("curl -so $re->{'DIR'} $ufo");
   }else{
    my $uca = 'https://formulae.brew.sh/cask/index.html';
     print " \033[31mNot connected\033[37m\n"
      if system("curl -so $re->{'DIR'} $uca");
   }
  }
  if( $re->{'S_OPT'} or $re->{'BL'} ){
    $list = Dirs_1( $re->{'CEL'},1 );
  }else{
    $list = Dirs_1( $re->{'CEL'},0,$re );
  }
  DB_1( $re );
 $re->{'COM'} ? Command_1( $list,$re ) : $re->{'BL'} ?
  Brew_1( $list,$re ) : File_1( $list,$re );
}

sub Linux_1{
 my( $re,$time,$list ) = @_;
  if( not -f $re->{'DIR'} ){
   my $url = 'https://formulae.brew.sh/formula-linux/index.html';
    print " \033[31mNot connected\033[37m\n"
     if system("curl -so $re->{'DIR'} $url");
  }
  if( $re->{'S_OPT'} or $re->{'BL'} ){
    $list = Dirs_1( $re->{'CEL'},1 );
  }else{
    $list = Dirs_1( $re->{'CEL'},0,$re );
  }
  DB_1( $re );
 $re->{'COM'} ? Command_1( $list,$re ) : $re->{'BL'} ? 
  Brew_1( $list,$re ) : File_1( $list,$re );
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

sub Brew_1{
my( $list,$re ) = @_;
 for(my $i=0;$i<@$list;$i++){  my( $tap ) = $list->[$i] =~ /^\s(.*)\n/;
  Mine_1( $tap,$re,0 ) if $re->{'DMG'}{$tap} or $re->{'HASH'}{$tap};
 }
}

sub File_1{
my( $list,$re,$test,$tap,$file ) = @_;
 open my $BREW,'<',$re->{'DIR'} or die " File_1 $!\n";
  while(my $brew = <$BREW>){
   if( $brew =~ s|^\s+<td><a href[^>]+>(.+)</a></td>\n|$1| ){
    $tap = "$brew\t"; next;
   }elsif( not $test and $brew =~ s|^\s+<td>(.+)</td>\n|$1| ){
    $tap .= "$brew\t";
    $test = 1; next;
   }elsif( $test and $brew =~ s|^\s+<td>(.+)</td>|$1| ){
    $tap .= $brew;
    $test = 0;
   }
   $tap =~ s/^(.+)\t(.+)\t(.+)\n/$1\t$3\t$2\n/ if $tap and $re->{'CAS'};
    push @$file,$tap if $tap;
     $tap = '';
  }
 close $BREW;

 @$file = sort{$a cmp $b}@$file if $re->{'FOR'};

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
 Search_1( $list,$file,0,0,$re,0 );
}

sub File_2{
my( $dir,$ls,$file ) = @_;
 open my $BREW,'<',$dir or die " File_2 $!\n";
  while(my $brew = <$BREW>){ chomp $brew;
   if( $ls == 1 ){
    push @$file,"homebrew/cask-fonts/$brew";
   }elsif( $ls == 2 ){
    push @$file,"homebrew/cask-drivers/$brew";
   }else{
    push @$file,$brew;
   }
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
 $name = $name.' (I)' if $ls;
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
    $re->{'ALL'} .= " Check folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
    $re->{'EXC'} .= " Check folder $re->{'CEL'} => $dir\n" if $mem;
   for(my $i=0;$i<@$file;$i++){
    $re->{'ALL'} .= @$file-1 == $i ? " $$file[$i]\n" : " $$file[$i]\t" unless $re->{'L_OPT'};
    $re->{'EXC'} .= @$file-1 == $i ? " $$file[$i]\n" : " $$file[$i]\t" if $mem;
   }
  }else{
    $re->{'ALL'} .= " Empty folder $re->{'CEL'} => $dir\n" unless $re->{'L_OPT'};
    $re->{'EXC'} .= " Empty folder $re->{'CEL'} => $dir\n" if $mem;
  }
 }else{
   $re->{'ALL'} .= $re->{'MEM'} unless $re->{'L_OPT'};
   $re->{'EXC'} .= $re->{'MEM'} if $mem;
 }
}

sub Search_1{
my( $list,$file,$in,$pop,$re,$mem ) = @_;
 for(my $i=0;$file->[$i];$i++){
  my( $brew_1,$brew_2,$brew_3 ) = split("\t",$file->[$i]);
   $mem = 1 if $re->{'L_OPT'} and $brew_1 =~ /$re->{'L_OPT'}/o;

   if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
    Tap_1( $list,$re,\$in );
     $i-- and next;
   }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
    ( $re->{'DMG'}{$brew_1} or $re->{'HASH'}{$brew_1} ) ?
     Mine_1( $brew_1,$re,1 ) : Mine_1( $brew_1,$re,0 )
     if $re->{'S_OPT'} and $brew_1 =~ /$re->{'S_OPT'}/o;
    $in++; $re->{'IN'}++; $pop = 1;
   }else{
    if( $re->{'S_OPT'} and $brew_1 =~ m|(?!.+/)$re->{'S_OPT'}|o ){
     if( my( $opt ) = $brew_1 =~ m|^homebrew/.+/(.+)| ){
      my $cou = () = $opt =~ /-/g;
      for(my $n=0;$n<=$cou;$n++){
       my( $reg ) = $opt =~ /(?:[^-]+-){$n}([^-]+)/;
        if( $reg =~ /^\Q$re->{'STDI'}\E$/o ){
         Mine_1( $brew_1,$re,0 ); last;
        } 
      }
     }else{ Mine_1( $brew_1,$re,0 ); }
    }
   }
    $re->{'MEM'} = "    $brew_1\t";
  unless( $re->{'S_OPT'} ){
   if( $pop ){
    if( not $list->[$in] or $list->[$in] =~ /^\s/ ){
        Memo_1( $re,$mem,$brew_1 );
         $mem = $pop = 0; $i-- and next;
    }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
        Memo_1( $re,$mem,$brew_1 );
     while(1){ $in++;
      last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
     }
    }
     if( $re->{'FOR'} and not $re->{'HASH'}{$brew_1} or
         $re->{'CAS'} and not $re->{'DMG'}{$brew_1} ){
       $re->{'MEM'} =~ s/^\s{4}$brew_1\t/ X  $brew_1\tNot Formula\n/;
        Memo_1( $re,$mem,0 );
         $mem = $pop = 0; $in++ and $i-- and next;
     }else{
      if( $re->{'FOR'} and $brew_2 gt $re->{'HASH'}{$brew_1} or
          $re->{'CAS'} and $brew_2 gt $re->{'DMG'}{$brew_1} ){
        $re->{'MEM'} =~ s/^\s{3}/(i)/;
      }else{
        $re->{'MEM'} =~ s/^\s{3}/ i /;
      }
     }
    $in++;
   }
   $re->{'MEM'} .= "$brew_2\t$brew_3";
    Memo_1( $re,$mem,0 ) if $re->{'LIST'} or $pop;
   $re->{'AN'}++; $mem = $pop = 0;
  }
 }
  if( $list->[$in] ){
   Tap_1( $list,$re,\$in ) while($list->[$in]);
  }
}

sub Tap_1{
my( $list,$re,$in ) = @_;
 my( $tap ) = $list->[$$in] =~ /^\s(.*)\n/;
 my $mem = 1 if $re->{'L_OPT'} and $tap =~ /$re->{'L_OPT'}/;
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
         $re->{'MEM'} = " X  $tap\tNot Formula\n";
    }elsif( $re->{'FOR'} ){
        $re->{'MEM'} = " i  $tap\t$re->{'HASH'}{$tap}\n";
    }else{
        $re->{'MEM'} = " i  $tap\t$re->{'DMG'}{$tap}\n";
    }
     Memo_1( $re,$mem,0 );
    $re->{'AN'}++; $re->{'IN'}++;
   }else{
   Memo_1( $re,$mem,$tap );
  }
 $$in++;
}

sub Command_1{
my( $list,$re,$ls1,$ls2,%HA,%OP ) = @_;
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
 opendir my $dir,$an or die " $!\n";
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
  my $time =[localtime((stat($re->{'FON'}))[9])] if -f $re->{'FON'};
  my( $year,$mon,$day ) = (
   ((localtime(time))[5] + 1900),((localtime(time))[4]+1),((localtime(time))[3]));
  if( not -f $re->{'FON'} or  $year > $time->[5]+1900 or
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
