#!/usr/bin/perl
use strict;
use warnings;
use FindBin;

my $re  = {
 'LEN'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,'EXC'=>'',
  'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html",
   'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
    'CEL'=>'/usr/local/Cellar','HASH'=>{},
     'BIN'=>'/usr/local/opt','SEA_1'=>''};

my $ref = {
 'LEN'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,'EXC'=>'',
  'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html",
   'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
    'DRI'=>"$ENV{'HOME'}/.BREW_LIST/Q_DRIV.txt",
     'CEL'=>'/usr/local/Caskroom',
      'LEN2'=>1,'LEN3'=>1};

$^O =~ /^darwin/ ? $re->{'MAC'} = $ref->{'MAC'} = 1 :
 $^O =~ /^linux/ ? $re->{'LIN'} = 1 : exit;
 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
 }
exit unless -d $re->{'CEL'};
 mkdir "$ENV{'HOME'}/.BREW_LIST" unless -d "$ENV{'HOME'}/.BREW_LIST";
  system("cp $FindBin::Bin/font.sh ~/.BREW_LIST/font.sh 2>/dev/null ||\
   echo ' # Not exisit => '$FindBin::Bin/font.sh")
    unless -f "$ENV{'HOME'}/.BREW_LIST/font.sh";
 Died_1() unless $ARGV[0];

 my $name;
if( $ARGV[0] eq '-l' ){      $name = $re;  $re->{'LIST'}  = 1;
}elsif( $ARGV[0] eq '-i' ){  $name = $re;  $re->{'PRINT'} = 1;
}elsif( $ARGV[0] eq '-co' ){ $name = $re;  $re->{'COM'} = 1;
}elsif( $ARGV[0] eq '-c' ){  $name = $ref; $ref->{'LIST'} = 1;  Died_1() if $re->{'LIN'};
}elsif( $ARGV[0] eq '-ci' ){ $name = $ref; $ref->{'PRINT'} = 1; Died_1() if $re->{'LIN'};
}elsif( $ARGV[0] eq '-s' ){  $re->{'SEARCH'} = $ref->{'SEARCH'} = 1;
}else{  Died_1();
}

$ref->{'FDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
$ref->{'DDIR'} = 1 if -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-drivers';

 my @AR = @ARGV; my $SPA;
if( $AR[1] and $AR[1] =~ s|^(/.*)\s*|$1| and $AR[$#AR] =~ s|\s*(.*/)$|$1| ){
 for(my $i= 1;$i<@AR;$i++){ $SPA .= lc $AR[$i];
 }
}

$SPA ? $re->{'SEA_1'} = $SPA : $ARGV[1] ?
 $re->{'SEA_1'} = lc $ARGV[1] : Died_1() if $re->{'SEARCH'};
$re->{'S_OPT'} = $ref->{'S_OPT'} = ( $re->{'SEA_1'} =~ s|^/(.*)/$|$1| ) ?
 $re->{'SEA_1'} : "\Q$re->{'SEA_1'}\E";

$SPA ? $re->{'SEA_1'} = $SPA : $ARGV[1] ?
 $re->{'SEA_1'} = lc $ARGV[1] : Died_1() if $re->{'COM'} or $ARGV[1] and $name->{'LIST'};
$name->{'SEA_2'} = ( $re->{'SEA_1'} =~ s|^/(.*)/$|$1| ) ?
 $re->{'SEA_1'} : "\Q$re->{'SEA_1'}\E";

if( $re->{'LIN'} ){
 Linux_1( $re ); Format_1( $re );
}elsif( $re->{'MAC'} and $re->{'SEARCH'} ){
 my $pid = fork;
 die "Not fork: $!\n" unless defined $pid;
  if($pid){
   Darwin_1( $ref );
   waitpid($pid,0);
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
  -l List : -i Instaled list 
  -s Type search name : -co search to comannd
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
  if( $re->{'FOR'} and not $re->{'SEARCH'} ){
    $list = Dirs_1( $re->{'CEL'},0,$re );
  }elsif( $re->{'CAS'} and not $re->{'SEARCH'} ){
    $list = Dirs_1( $re->{'CEL'},0,$re );
  }elsif( $re->{'FOR'} and $re->{'SEARCH'} ){
    $list = Dirs_1( $re->{'CEL'},1 );
  }else{
    $list = Dirs_1( $re->{'CEL'},1 );
  }
 File_1( $list,$re );
}

sub Linux_1{
 my( $re,$time,$list ) = @_;
  if( not -f $re->{'DIR'} ){
   my $url = 'https://formulae.brew.sh/formula-linux/index.html';
    print " \033[31mNot connected\033[37m\n"
     if system("curl -so $re->{'DIR'} $url");
  }
  unless( $re->{'SEARCH'} ){
    $list = Dirs_1( $re->{'CEL'},0,$re );
  }else{
    $list = Dirs_1( $re->{'CEL'},1 );
  }
 File_1( $list,$re );
}

sub File_1{
my( $list,$re,$test,$tap,$file,$fin,$din ) = @_;
 open my $BREW,'<',$re->{'DIR'} or die " File_1 $!\n";
  while(my $brew = <$BREW>){
   if( $brew =~ s[\s+<td><a href[^>]+>(.+)</a></td>\n][$1] ){
    $tap = "$brew\t"; next;
   }elsif( not $test and $brew =~ s[\s+<td>(.+)</td>\n][$1] ){
    $tap .= "$brew\t";
    $test = 1; next;
   }elsif( $test and $brew =~ s[\s+<td>(.+)</td>][$1] ){
    $tap .= $brew;
    $test = 0;
   }
   $tap =~ s/(.+)\t(.+)\t(.+)\n/$1\t$3\t$2\n/ if $tap and $re->{'CAS'};
    push @{$file},$tap if $tap;
     $tap = '';
  }
 close $BREW;

 @{$file} = sort{$a cmp $b}@{$file} if $re->{'FOR'};

 if( $re->{'CAS'} and $re->{'SEARCH'} and  -f $re->{'FON'} and  -f $re->{'DRI'} ){
  $fin = $re->{'FDIR'} ? File_2( $re->{'FON'},0 ) : File_2( $re->{'FON'},1 );
  $din = $re->{'DDIR'} ? File_2( $re->{'DRI'},0 ) : File_2( $re->{'DRI'},2 );

   if( $re->{'FDIR'} and $re->{'DDIR'} ){
    push @{$file},@{$fin};
     push @{$file},@{$din};
      @{$file} = sort{$a cmp $b}@{$file};
   }elsif( $re->{'FDIR'} and not $re->{'DDIR'} ){
    push @{$file},@{$fin};
     @{$file} = sort{$a cmp $b}@{$file};
      push @{$file},@{$din};
   }elsif( not $re->{'FDIR'} and  $re->{'DDIR'} ){
    push @{$file},@{$din};
     @{$file} = sort{$a cmp $b}@{$file};
      push @{$file},@{$fin};
   }else{
    @{$file} = sort{$a cmp $b}@{$file};
     push @{$file},@{$fin};
      push @{$file},@{$din};
   }
 }
 Dirs_1( $re->{'BIN'},4,$re ) if $re->{'FOR'}; ### check existe
  $re->{'COM'} ? Command_1( $list,$re,0 ) :
   Search_1( $list,$file,0,0,0,0,$re,'',0,0 );
}

sub File_2{
my( $dir,$ls,$file ) = @_;
 open my $BREW,'<',$dir or die " File_2 $!\n";
  while(my $brew = <$BREW>){ chomp $brew;
   if( $ls == 1 ){
    push @{$file},"homebrew/cask-fonts/$brew";
   }elsif( $ls == 2 ){
    push @{$file},"homebrew/cask-drivers/$brew";
   }else{
    push @{$file},$brew;
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
   $re->{'FILE'} .= " File exists $url/$hand_1\n"
    if -f "$url/$hand_1" and not $ls;
     if( $ls == 4){
      my $hand = readlink("$re->{'BIN'}/$hand_1");
       my( $an,$bn ) = $hand =~ m|/Cellar/([^/]+)/([^_]*)|;
       $re->{'HASH'}{$an} = $bn;
      next; 
     }elsif( $ls != 3 ){ next unless -d "$url/$hand_1";
     }
   $ls == 1 ? push @{$an}," $hand_1\n" : $ls == 2 ?
    push @{$an}," $hand_1\t" : push @{$an},$hand_1;
 }
closedir $dir_1;
 @{$an} = sort{$a cmp $b}@{$an};
  push @{$an},"\n" if $ls == 2;
   return $an if $ls;

for( my $in=0;$in<@{$an};$in++ ){
 push @{$bn}," ${$an}[$in]\n";
 opendir my $dir_2,"$url/${$an}[$in]" or die " Dirs_2 $!\n";
  for my $hand_2(readdir($dir_2)){
   next if $hand_2 =~ /^\./;
    $re->{'FILE'} .= " File exists $url/${$an}[$in]/$hand_2\n"
     if -f "$url/${$an}[$in]/$hand_2";
   next unless -d "$url/${$an}[$in]/$hand_2";
  push @{$bn},"$hand_2\n";
  }
 closedir $dir_2;
 }
$bn;
}

sub Mine_1{
my( $name,$re,$ls ) = @_;
 $name = $name.' ✅' if $ls;
  $re->{'HA'}{$name} = length $name;
   push @{$re->{'ARR'}},$name;
 if( $name =~ m|^homebrew/cask-fonts| ){
  $re->{'LEN2'} = $re->{'HA'}{$name} if $re->{'LEN2'} < $re->{'HA'}{$name};
 }elsif( $name =~ m|^homebrew/cask-drivers| ){
  $re->{'LEN3'} = $re->{'HA'}{$name} if $re->{'LEN3'} < $re->{'HA'}{$name};
 }else{
  $re->{'LEN'} = $re->{'HA'}{$name} if $re->{'LEN'} < $re->{'HA'}{$name};
 }
}

sub Memo_1{
my( $re,$mem,$ls ) = @_;
 if( $ls ){
  my $file = Dirs_1( "$re->{'CEL'}/$ls",3 );
   if( @{$file} ){
    if( $mem ){ $re->{'EXC'} .= " file exists folder $re->{'CEL'} => $ls\n";
    }else{ $re->{'ALL'} .= " file exists folder $re->{'CEL'} => $ls\n";
    }
   }else{
    if( $mem ){ $re->{'EXC'} .= " Empty folder $re->{'CEL'} => $ls\n";
    }else{ $re->{'ALL'} .= " Empty folder $re->{'CEL'} => $ls\n";
    }
   }
 }else{
  if( $mem ){ $re->{'EXC'} .= $re->{'MEM'};
  }else{ $re->{'ALL'} .= $re->{'MEM'};
  }
 }
}

sub Search_1{
my( $list,$file,$in,$i,$nst,$pop,$re,$tap,$mem,$cou ) = @_;
 die " Deep recursion on subroutine\n" if $nst > 97;
  for(;$file->[$i];$i++){
   my( $brew_1,$brew_2,$brew_3 ) = split("\t",$file->[$i]);
    $mem = 1 if $re->{'SEA_2'} and $brew_1 =~ /$re->{'SEA_2'}/;

    if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
     $mem = 1 if $re->{'SEA_2'} and $list->[$in] =~ /$re->{'SEA_2'}/;
      Tap_1( $list,$re,$mem,\$in );
       $i--; $mem = 0; next;
    }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
      if( $re->{'S_OPT'} and $brew_1 =~ /$re->{'S_OPT'}/ ){
        if( $re->{'CAS'} or $re->{'HASH'}{$brew_1} ){
            Mine_1( $brew_1,$re,1 ); ### search existis Formula
        }else{
            Mine_1( $brew_1,$re,0 ); ### search not existis Formula
        }
      }
       $tap = "    $brew_1\t";
        $in++; $re->{'IN'}++; $pop = 1;
    }else{
     if( $re->{'S_OPT'} and $brew_1 =~ m|(?!.*/)$re->{'S_OPT'}| ){
       my $opt = $brew_1;
      if( $opt =~ s|^homebrew/.*/(.*)|$1| ){
       my $cou = () = $opt =~ /-/g;
        for(my $n=0;$n<=$cou;$n++){
         my( $reg ) = $opt =~ /(?:[^-]*-){$n}([^-]*)/;
          Mine_1( $brew_1,$re,0 ) if $reg =~ /^\Q$re->{'S_OPT'}\E$/;
        }
      }else{ Mine_1( $brew_1,$re,0 );
      }
     }
       $re->{'MEM'} = "    $brew_1\t";
        Memo_1( $re,$mem,0 ) if $re->{'LIST'}; ### ALL push
    }

   unless( $re->{'SEARCH'} ){
    if( $pop ){
      if( not $list->[$in] or $list->[$in] =~ /^\s/ ){
        Memo_1( $re,$mem,$brew_1 ); ### push comment for Folder
         Search_1( $list,$file,$in,$i,++$nst,0,$re,'',0,0 );
          last;
      }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
       $re->{'MEM'} = " Check folder $re->{'CEL'} => $brew_1\n";
        Memo_1( $re,$mem,0 ); ### push comment for Folder
         my $dir = Dirs_1( "$re->{'CEL'}/$brew_1",2 );
          if( $mem ){ $re->{'EXC'} .= $_ for(@{$dir});
          }else{ $re->{'ALL'} .= $_ for(@{$dir});
         }
          while(1){ $in++; $cou++;
           last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
          }
      }
        $list->[$in - $cou - 1] =~ s/^\s(.*)\n/$1/;
       if( $re->{'FOR'} and not $re->{'HASH'}{$list->[$in - $cou - 1]} ){
        $tap =~ s/^\s{4}$brew_1\t/ X  $brew_1/;
         $re->{'MEM'} = "$tap\tNot Formula\n";
          Memo_1( $re,$mem,0 ); ### push comment
           Search_1( $list,$file,++$in,$i,++$nst,0,$re,'',0,0 );
            last;
       }else{
         if( $re->{'FOR'} and $brew_2 gt $re->{'HASH'}{$list->[$in - $cou - 1]} or
             $re->{'CAS'} and $brew_2 gt $list->[$in - $cou] ){
          $tap =~ s/^\s{3}/(i)/;
         }else{
          $tap =~ s/^\s{3}/ i /;
         }
        $tap .= "$brew_2\t"; $in++;
       }
    }else{
      $re->{'MEM'} = "$brew_2\t";
       Memo_1( $re,$mem,0 ) if $re->{'LIST'}; ### ALL push
    }
    if( $pop ){
     $tap .= $brew_3;
      $pop = 0;
    }else{
      $re->{'MEM'} = "$brew_3";
       Memo_1( $re,$mem,0 ) if $re->{'LIST'}; ### ALL push
    }
     if( $mem ){ $re->{'EXC'} .= $tap;
     }else{ $re->{'ALL'} .= $tap;
     }
      $tap = ''; $re->{'AN'}++; $mem = 0; $cou = 0;
   }
  }
 if( $list->[$in] ){
  Tap_1( $list,$re,$mem,\$in ) while($list->[$in]);
 }
}

sub Tap_1{
my( $list,$re,$mem,$in ) = @_; my $cou = 0;
 $list->[$$in] =~ s/^\s(.*)\n/$1/;
  if( $re->{'S_OPT'} and $list->[$$in]=~/$re->{'S_OPT'}/ and $re->{'CAS'} or
      $re->{'S_OPT'} and $list->[$$in]=~/$re->{'S_OPT'}/ and $re->{'HASH'}{$list->[$$in]}){
        Mine_1( $list->[$$in++],$re,1 ); ### search existis Formula

  }elsif( $list->[$$in + 1] and $list->[$$in + 1] !~ /^\s/ ){
   my $tap = $list->[$$in++];
    if( $list->[$$in + 1] and $list->[$$in + 1] !~ /^\s/ ){
     $re->{'MEM'} = " Check folder $re->{'CEL'} => $list->[$$in - 1]\n";
      Memo_1( $re,$mem,0 ); ### push comment for Folder
       my $dir = Dirs_1( "$re->{'CEL'}/$list->[$$in - 1]",2 );
        if( $mem ){ $re->{'EXC'} .= $_ for(@{$dir});
        }else{ $re->{'ALL'} .= $_ for(@{$dir});
        }
         while(1){ $$in++; $cou++;
          last if not $list->[$$in + 1] or $list->[$$in + 1] =~ /^\s/;
         }
    }
    if( $re->{'FOR'} and not $re->{'HASH'}{$list->[$$in - $cou - 1]} ){
          $re->{'MEM'} = " X  $tap\tNot Formula\n";
            Memo_1( $re,$mem,0 ); ### push comment
    }elsif( $re->{'FOR'} ){
        $re->{'MEM'} = " i  $tap\t$re->{'HASH'}{$list->[$$in - $cou - 1]}\n";
           Memo_1( $re,$mem,0 ); ### ALL push
    }else{ $re->{'MEM'} = " i  $tap\t$list->[$$in - $cou]";
           Memo_1( $re,$mem,0 ); ### ALL push
    }
     $re->{'AN'}++; $re->{'IN'}++;
  }else{
     Memo_1( $re,$mem,$list->[$$in] ); ### push comment for Folder
  }
 $$in++;
}

sub Command_1{
my( $list,$re,$in,$com ) = @_;
 $re->{'SEA_1'} = "\Q$re->{'SEA_1'}\E";
 for(;$list->[$in];$in++){
  $list->[$in] =~ s/^\s(.*)\n/$1/;
  if( $list->[$in] =~ /^$re->{'SEA_1'}$/){
   my $name = $list->[$in];
    my $num = $list->[$in + 1]; chomp $num;
    if( -d "$re->{'CEL'}/$name/$num/bin"){
     $com = Dirs_1( "$re->{'CEL'}/$name/$num/bin",3 );
      print"$re->{'CEL'}/$name/$num/bin/$_\n" for(@{$com});
    }
    if( -d "$re->{'CEL'}/$name/$num/sbin" ){
     $com = Dirs_1( "$re->{'CEL'}/$name/$num/sbin",3 );
      print"$re->{'CEL'}/$name/$num/sbin/$_\n" for(@{$com});
    } 

   Dirs_2( "$re->{'CEL'}/$name/$num",$re );
    $name = "\Q$name\E";
     my( %HA,%OP,$ls1,$ls2 );
   for $ls1(@{$re->{'ARR'}}){
    next if $ls1 =~ m|/Cellar/$name/$num/[^/]+$| or $ls1 =~ m|/$name/$num/s?bin/|;
        $ls2 = $ls1;
    if(not -l $ls1 and $ls1 =~ m|^$re->{'CEL'}/$name/$num/lib/[^/]+[^a\d]$|){
           print"$ls1\n"; $re->{'IN'} = 1;
    }else{
      $ls1 =~ s|($re->{'CEL'}/$name/$num/[^/]+/[^/]+)/.+(/.+)|$1$2|;
       $HA{$ls1}++ if $ls1=~s|(.+)/.+|$1|;
      $ls2 =~ s|$re->{'CEL'}/$name/$num/[^/]+/[^/]+/(.+)|$1|;
       $OP{$ls1} = $ls2;
    }
   }
   for my $key(sort keys %HA){
    if( $HA{$key} == 1 ){
     $OP{$key} =~ /^$re->{'CEL'}/ ? print"$OP{$key}\n" : print"$key/$OP{$key}\n";
    }else{
     ( $re->{'IN'} and  $key =~ m|^$re->{'CEL'}/$name/$num/lib$| ) ?
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
my( $re,$ls,$sl ) = @_;
  if( $re->{'LIST'} or $re->{'PRINT'} ){
   system(" printf '\033[?7l' ") if $re->{'MAC'};
    system('setterm -linewrap off') if $re->{'LIN'};
     $re->{'SEA_2'} ? print"$re->{'EXC'}" : print"$re->{'ALL'}";
      print " item $re->{'AN'} : install $re->{'IN'}\n";
   system(" printf '\033[?7h' ") if $re->{'MAC'};
    system('setterm -linewrap on') if $re->{'LIN'};
  }else{
   my $leng = $re->{'LEN'};
    my $tput = `tput cols`;
     my $size = int $tput/($leng+2);
      my $in = 1;
   print" ==> Formulae\n" if $re->{'FOR'} and @{$re->{'ARR'}};
   print" ==> Casks\n" if $re->{'CAS'} and @{$re->{'ARR'}};
    for my $arr( @{$re->{'ARR'}} ){
     if( $arr =~ m|^homebrew/cask-fonts| and not $ls ){
      print"\n brew tap : homebrew/cask-fonts\n\n";
       $leng = $re->{'LEN2'};
        $size = int $tput/($leng+2);  $ls = 1;
     }elsif( $arr =~ m|^homebrew/cask-drivers| and not $sl ){
      print"\n brew tap :  homebrew/cask-drivers\n\n";
       $leng = $re->{'LEN3'};
        $size = int $tput/($leng+2);  $sl = 1;
     }
      for(my $i=$re->{'HA'}{$arr};$i<$leng+2;$i++){
       $arr .= ' ';
      }
     print"$arr";
     print"\n" unless $in % $size;
     $in++;
    }
   $re->{'CAS'} = 0;
  }
print "\n" if @{$re->{'ARR'}};
print "\033[33m$re->{'FILE'}\033[37m" if $re->{'FILE'};
Nohup_1( $re ) if $re->{'CAS'} or $re->{'FOR'};
}

sub Nohup_1{
 my $re = shift;
  my $time =[localtime((stat($re->{'FON'}))[9])] if -f $re->{'FON'};
   $time->[5] += 1900;
    $time->[4]++;
  my( $year,$mon,$day ) = (
   ((localtime(time))[5] + 1900),((localtime(time))[4]+1),((localtime(time))[3]));
  if( not -f $re->{'FON'} or  $year > $time->[5] or
     $mon > $time->[4] or $day > $time->[3] ){
      system('nohup ~/.BREW_LIST/font.sh >/dev/null 2>&1 &');
  }
}
__END__
Check Darwin
diff <(ls /usr/local/Cellar) <(brew list --formula)
diff <(ls /usr/local/Caskroom) <(brew list --cask)
Check Linux
diff <(ls /home/linuxbrew/.linuxbrew/Cellar) <(brew list --formula)
