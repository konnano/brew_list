#!/usr/bin/perl
use strict;
use warnings;

my $re  = {'LEN'=>1,'FOR'=>1,'ARR'=>[],'IN'=>0,'POP'=>'',
 'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html",
  'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
   'CEL'=>'/usr/local/Cellar','HASH'=>{},
    'BIN'=>'/usr/local/opt'};

my $ref = {'LEN'=>1,'CAS'=>1,'ARR'=>[],'IN'=>0,'POP'=>'',
 'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html",
  'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt",
   'CEL'=>'/usr/local/Caskroom','DMG'=>{}};

$^O =~ /^darwin/ ? $re->{'MAC'} = $ref->{'MAC'} = 1 :
 $^O =~ /^linux/ ? $re->{'LIN'} = 1 : exit;
 if( $re->{'LIN'} ){
  $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
   $re->{'BIN'} = '/home/linuxbrew/.linuxbrew/opt';
 }
  exit unless -d $re->{'CEL'};
 mkdir "$ENV{'HOME'}/.BREW_LIST" unless -d "$ENV{'HOME'}/.BREW_LIST";
 
 $ref->{'YEA'} = $re->{'YEA'} = ((localtime(time))[5] + 1900);
  $ref->{'MON'} = $re->{'MON'} = ((localtime(time))[4]+1);
   $ref->{'DAY'} = $re->{'DAY'} = ((localtime(time))[3]);

 Died_1() unless $ARGV[0];
  my $name;
if( $ARGV[0] eq '-l' ){      $name = $re;  $re->{'LIST'}  = 1;
}elsif( $ARGV[0] eq '-i' ){  $name = $re;  $re->{'PRINT'} = 1;
}elsif( $ARGV[0] eq '-c' ){  $name = $ref; $ref->{'LIST'} = 1;  Died_1() if $re->{'LIN'};
}elsif( $ARGV[0] eq '-ci' ){ $name = $ref; $ref->{'PRINT'} = 1; Died_1() if $re->{'LIN'};
}elsif( $ARGV[0] eq '-s' ){  $re->{'SEARCH'} = $ref->{'SEARCH'} = 1;
}else{  Died_1();
}
$ARGV[1] ? $re->{'OPT'} = $ref->{'OPT'} = lc $ARGV[1] : die " Type search name\n"
       if $re->{'SEARCH'};
$name->{'SER'} = lc $ARGV[1] if $ARGV[1] and $name->{'LIST'};

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
  -l List : -i Instaled list : -s Type search name
  Only mac
  -c Casks list : -ci Casks instaled list\n";
}

sub Darwin_1{
 my( $re,$time,$list ) = @_;
  $time = Time_1( $re->{'DIR'} )if -f $re->{'DIR'};
   if( not -f $re->{'DIR'} or  $re->{'YEA'} > $time->[5] or 
       $re->{'MON'} > $time->[4] or $re->{'DAY'} > $time->[3] ){
    if( $re->{'FOR'} ){
     my $ufo = 'https://formulae.brew.sh/formula/index.html';
     $re->{'CUR'} = 1 if system("curl -so $re->{'DIR'} $ufo");
    }else{
     my $uca = 'https://formulae.brew.sh/cask/index.html';
     $re->{'CUR'} = 1 if system("curl -so $re->{'DIR'} $uca");
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
  $time = Time_1( $re->{'DIR'} ) if -f $re->{'DIR'};
   if( not -f $re->{'DIR'} or $re->{'YEA'} > $time->[5] or
       $re->{'MON'} > $time->[4] or $re->{'DAY'} > $time->[3] ){
    my $url = 'https://formulae.brew.sh/formula-linux/index.html';
     $re->{'CUR'} = 1 if system("curl -so $re->{'DIR'} $url");
   }
  unless( $re->{'SEARCH'} ){
    $list = Dirs_1( $re->{'CEL'},0,$re );
  }else{
    $list = Dirs_1( $re->{'CEL'},1 );
  }
 File_1( $list,$re );
}

sub Time_1{
my( $file,$time ) = @_;
 $time =[localtime((stat($file))[9])];
  $time->[5] += 1900;
   $time->[4]++;
$time;
}

sub File_1{
my( $list,$re,$test,$tap,$file ) = @_;
  open my $BREW,'<',$re->{'DIR'} or die " File $!\n";
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

 if( $re->{'CAS'} and $re->{'SEARCH'} and -f $re->{'FON'} ){
  open my $FONT,'<',$re->{'FON'} or die " Font $!\n";
   while(my $font = <$FONT>){ chomp $font;
    push @{$file},$font;
   }
  close $FONT;
 }
 @{$file} = sort{$a cmp $b}@{$file};
  Search_1( $list,$file,0,0,0,0,$re,'',0,0 );
}

sub Dirs_1{
my( $url,$ls,$re,$bn ) = @_;
 my $an = [];
opendir my $dir_1,"$url" or die " Dirs_1 $!\n";
 for my $hand_1( readdir($dir_1) ){
  next if $hand_1 =~ /^\./;
  $re->{'FILE'} .= " File exists $url/$hand_1\n"
   if -f "$url/$hand_1" and not $ls;
    if( $ls != 3 ){ next unless -d "$url/$hand_1"; }
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
  for my $hand_2( readdir($dir_2) ){
   next if $hand_2 =~ /^\./;
   $re->{'FILE'} .= " File exists $url/${$an}[$in]/$hand_2\n"
     if -f "$url/${$an}[$in]/$hand_2";
  next unless -d "$url/${$an}[$in]/$hand_2";
   $hand_2 =~ s/_[1-9]$//;
  push @{$bn},"$hand_2\n";
  }
 closedir $dir_2;
 }
$bn;
}

sub DB_1{
my $re = shift;
 if( $re->{'FOR'} ){
  opendir my $dir,$re->{'BIN'} or die " DB_1 $!\n";
   for my $com(readdir($dir)){
    my $hand = readlink("$re->{'BIN'}/$com");
     next if not $hand or $hand and $hand !~ /Cellar/;
    my( $an,$bn ) = $hand =~ m|/Cellar/(.*)/([^_]*)|;
     $re->{'HASH'}{$an} = $bn;
   }
  closedir $dir;
 }elsif( $re->{'CAS'} ){
  my $dmg = Dirs_1( "$ENV{'HOME'}/Library/Caches/Homebrew/Cask",3 );
  my $cas = Dirs_1( $re->{'CEL'},4 );
   for my $in1(@{$cas}){
    for my $in2(@{$dmg}){
     $re->{'DMG'}{$in1} = 1 if $in2 =~ /^$in1/;
    }
   }
 }
}

sub Mine_1{
my( $name,$re,$ls ) = @_;
 $name = $name.' ✅' if $ls;
  $re->{'HA'}{$name} = length $name;
   push @{$re->{'ARR'}},$name;
 $re->{'LEN'} = $re->{'HA'}{$name} if $re->{'LEN'} < $re->{'HA'}{$name};
}

sub Search_1{
my( $list,$file,$in,$i,$nst,$pop,$re,$tap,$mem,$cou,$dir,$loop ) = @_;
 die " Deep recursion on subroutine\n" if $nst > 50;
  DB_1( $re ) if $re->{'FOR'} and not %{$re->{'HASH'}} or
                 $re->{'CAS'} and not %{$re->{'DMG'}};

  for(;$file->[$i];$i++){
   my( $brew_1,$brew_2,$brew_3 ) = split("\t",$file->[$i]);
    $mem = 1 if $re->{'SER'} and $brew_1 =~ /$re->{'SER'}/;
 
    if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
     $mem = 1 if $re->{'SER'} and $list->[$in] =~ /$re->{'SER'}/;
      last;
    }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
      if( $re->{'OPT'} and $brew_1 =~ /$re->{'OPT'}/ and $re->{'DMG'}{$brew_1} or
          $re->{'OPT'} and $brew_1 =~ /$re->{'OPT'}/ and $re->{'HASH'}{$brew_1} ){
            Mine_1( $brew_1,$re,1 );
      }elsif( $re->{'OPT'} and $brew_1 =~ /$re->{'OPT'}/ ){
            Mine_1( $brew_1,$re,0 );
      }
       $tap = "    $brew_1\t";
        $in++; $re->{'IN'}++; $pop = 1;
    }else{
      Mine_1( $brew_1,$re,0 ) if $re->{'OPT'} and $brew_1 =~ /$re->{'OPT'}/;
       $re->{'ALL'} .= "    $brew_1\t" if $re->{'LIST'} and not $mem;
        $re->{'POP'} .= "    $brew_1\t" if $re->{'LIST'} and $mem;
    }

   unless( $re->{'SEARCH'} ){
    if( $pop ){
      if( not $list->[$in] or $list->[$in] =~ /^\s/ ){
        if( $mem ){ $re->{'POP'} .= " Empty folder $re->{'CEL'} =>$list->[$in - 1]";
        }else{ $re->{'ALL'} .= " Empty folder $re->{'CEL'} =>$list->[$in - 1]";
        }
         Search_1( $list,$file,$in,$i,++$nst,0,$re,'',0,0 );
          $loop = 1;
           last;
      }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
       $list->[$in - 1] =~ s/^\s(.+)\n/$1/;
        if( $mem ){ $re->{'POP'} .= " Check folder $re->{'CEL'} => $list->[$in - 1]\n";
        }else{ $re->{'ALL'} .= " Check folder $re->{'CEL'} => $list->[$in - 1]\n";
        }
          $dir = Dirs_1( "$re->{'CEL'}/$list->[$in - 1]",2 );
         if( $mem ){ $re->{'POP'} .= $_ for(@{$dir});
         }else{ $re->{'ALL'} .= $_ for(@{$dir});
         }
          while(1){ $in++; $cou++;
           last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
          }
      }
        $list->[$in - $cou - 1] =~ s/^\s(.*)\n/$1/;
       if( $re->{'FOR'} and not $re->{'HASH'}{$list->[$in - $cou - 1]} or
           $re->{'CAS'} and not $re->{'DMG'}{$list->[$in - $cou - 1]} ){
        $tap =~ s/^\s{4}$brew_1\t/ X  $brew_1/;
         if( $mem ){ $re->{'POP'} .= "$tap\tNot Formula\n";
         }else{ $re->{'ALL'} .= "$tap\tNot Formula\n";
         }
          Search_1( $list,$file,++$in,$i,++$nst,0,$re,'',0,0 );
           $loop = 1;
            last;
       }else{ 
         if( "$brew_2\n" gt $list->[$in++] ){
          $tap =~ s/^\s{3}/(i)/;
         }else{
          $tap =~ s/^\s{3}/ i /;
         }
        $tap .= "$brew_2\t";
       }
    }else{
     $re->{'ALL'} .= "$brew_2\t" if $re->{'LIST'} and not $mem;
      $re->{'POP'} .= "$brew_2\t" if $re->{'LIST'} and $mem;
    }

    if( $pop ){
     $tap .= $brew_3;
      $pop = 0;
    }else{
     $re->{'ALL'} .= "$brew_3" if $re->{'LIST'} and not $mem;
      $re->{'POP'} .= "$brew_3" if $re->{'LIST'} and $mem;
    }
     if( $mem ){ $re->{'POP'} .= $tap;
     }else{ $re->{'ALL'} .= $tap;
     }
      $tap = ''; $re->{'AN'}++; $mem = 0; $cou = 0;
   }
  }
  
  if( $list->[$in] and not $loop ){
   $list->[$in] =~ s/^\s(.*)\n/$1/;
    if( $re->{'OPT'} and $list->[$in] =~ /$re->{'OPT'}/ and $re->{'DMG'}{$list->[$in]} or
        $re->{'OPT'} and $list->[$in] =~ /$re->{'OPT'}/ and $re->{'HASH'}{$list->[$in]}){
            Mine_1( $list->[$in],$re,1 );

    }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
     $tap = $list->[$in++];
      if( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
        if( $mem ){ $re->{'POP'} .= " Check folder $re->{'CEL'} => $list->[$in - 1]\n";
        }else{ $re->{'ALL'} .= " Check folder $re->{'CEL'} => $list->[$in - 1]\n";
        }
         $dir = Dirs_1( "$re->{'CEL'}/$list->[$in - 1]",2 );
         if( $mem ){ $re->{'POP'} .= $_ for(@{$dir});
         }else{ $re->{'ALL'} .= $_ for(@{$dir});
         }
          while(1){ $in++; $cou++;
           last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
          }
      }

      if( $re->{'FOR'} and not ${$re->{'HASH'}}{$list->[$in - $cou - 1]} or
          $re->{'CAS'} and not ${$re->{'DMG'}}{$list->[$in - $cou - 1]}){
       $re->{'POP'} .= " X  $tap\tNot Formula\n"
         if $re->{'SER'} and $tap =~ /$re->{'SER'}/;
        $re->{'ALL'} .= " X  $tap\tNot Formula\n"
          if not $re->{'SER'};

      }elsif( $re->{'CAS'}){
       $re->{'POP'} .= " i  $tap\t$list->[$in]"
         if $re->{'SER'} and $tap =~ /$re->{'SER'}/;
        $re->{'ALL'} .= " i  $tap\t$list->[$in]"
          if not $re->{'SER'};

      }else{
       $re->{'POP'} .= " i  $tap\t$re->{'HASH'}{$list->[$in - $cou - 1]}\n"
         if $re->{'SER'} and $tap =~ /$re->{'SER'}/;
        $re->{'ALL'} .= " i  $tap\t$re->{'HASH'}{$list->[$in - $cou - 1]}\n"
          if not $re->{'SER'};
      }
     $re->{'AN'}++; $re->{'IN'}++;
    }else{
      if( $mem ){ $re->{'POP'} .= " Empty folder $re->{'CEL'} => $list->[$in]\n";
      }else{ $re->{'ALL'} .= " Empty folder $re->{'CEL'} => $list->[$in]\n";
      }
    }
   Search_1( $list,$file,++$in,$i,++$nst,0,$re,'',0,0 );
  }
}

sub Format_1{
my $re = shift;
  if( $re->{'LIST'} or $re->{'PRINT'} ){
   system(" printf '\033[?7l' ") if $re->{'MAC'};
   system('setterm -linewrap off') if $re->{'LIN'};
    $re->{'SER'} ? print"$re->{'POP'}" : print"$re->{'ALL'}";
    print " item $re->{'AN'} : install $re->{'IN'}\n";
   system(" printf '\033[?7h' ") if $re->{'MAC'};
   system('setterm -linewrap on') if $re->{'LIN'};
  }else{
   my $size = int `tput cols`/($re->{'LEN'}+2);
   my $in = 1;
   print" ==>Formulae\n" if $re->{'FOR'} and @{$re->{'ARR'}};
   print" ==>Casks\n" if $re->{'CAS'} and @{$re->{'ARR'}};
    for my $arr( @{$re->{'ARR'}} ){
      for(my $i=$re->{'HA'}{$arr};$i<$re->{'LEN'}+2;$i++){
       $arr .= ' ';
      }
     print"$arr";
     print"\n" unless $in % $size;
     $in++;
    }
   $re->{'CAS'} = 0;
  }
print "\n" if @{$re->{'ARR'}};
print " \033[31mNot connected\033[37m\n" if $re->{'CUR'};
print "\033[33m$re->{'FILE'}\033[37m" if $re->{'FILE'};
Nohup_1( $re ) if $re->{'MAC'} and ( $re->{'CAS'} or $re->{'FOR'} );
}

sub Nohup_1{
my $re = shift;
 my $time = Time_1( $re->{'FON'} ) if -f $re->{'FON'};
  if( not -f $re->{'FON'} or  $re->{'YEA'} > $time->[5] or
      $re->{'MON'} > $time->[4] or $re->{'DAY'} > $time->[3] ){
   system('nohup ./font.sh >/dev/null 2>&1 &');
  }
}
__END__
Check Darwin
diff <(ls /usr/local/Cellar) <(brew list --formula)
diff <(ls /usr/local/Caskroom) <(brew list --cask)
Check Linux
diff <(ls /home/linuxbrew/.linuxbrew/Cellar) <(brew list --formula)
