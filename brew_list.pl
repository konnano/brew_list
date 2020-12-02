#!/usr/bin/perl
use strict;
use warnings;

my $cur = $ENV{'HOME'}.'/.Q_BREW.html';
my $cas = $ENV{'HOME'}.'/.Q_CASK.html';
my $con; my $dir;
my $re  = {'LEN'=>1,'FOR'=>1,'ARR'=>[],'EN'=>0};
my $ref = {'LEN'=>1,'CAS'=>1,'ARR'=>[],'EN'=>0};
die "  Option
  -l List : -i Instaled list : -s Type search name
  Mac Option
  -c Casks list : -ci Casks instaled list\n" unless $ARGV[0];

if( $ARGV[0] eq '-l' ){     $con = $re;  $dir = $cur; $re->{'LIST'}  = 1;
}elsif( $ARGV[0] eq '-i' ){ $con = $re;  $dir = $cur; $re->{'PRINT'} = 1;
}elsif( $ARGV[0] eq '-c' ){ $con = $ref; $dir = $cas; $ref->{'LIST'} = 1;
}elsif( $ARGV[0] eq '-ci'){ $con = $ref; $dir = $cas; $ref->{'PRINT'} = 1;
}elsif( $ARGV[0] eq '-s' ){ $re->{'SEARCH'} = $ref->{'SEARCH'} = 1;
}else{ exit; }
$ARGV[1] ? $re->{'OPT'} = $ref->{'OPT'} = $ARGV[1] : die " Type search name\n"
	if $re->{'SEARCH'};

if( `uname` =~ /Linux/ ){
 Linux($cur,$re); Format($re);
}elsif( `uname` =~ /Darwin/ and not $re->{'SEARCH'} ){
 Darwin($dir,$con); Format($con);
}elsif( `uname` =~ /Darwin/ and $re->{'SEARCH'} ){
 my $pid = fork;
die "Not fork $!\n" unless defined $pid;
  if( $pid ){
   Darwin($cas,$ref);
   waitpid($pid,0);
  }else{
   Darwin($cur,$re);
  }
  if( $pid ){
   Format($ref);
  }else{
   Format($re); exit;
  }
}else{ exit; }

sub Darwin{
exit unless `ls /usr/local/Cellar 2>/dev/null`;
 my( $cur,$re,$time,$year,$mon,$day,@list ) = @_;
if( -f $cur ){
$time=[split(" ",`ls -lT ~/.Q_BREW.html|awk '{print \$6,\$7,\$9}'`)] if $re->{'FOR'};
$time=[split(" ",`ls -lT ~/.Q_CASK.html|awk '{print \$6,\$7,\$9}'`)] if $re->{'CAS'};
( $year,$mon,$day ) = (
 ((localtime(time))[5] + 1900),
  ((localtime(time))[4]+1),
   ((localtime(time))[3]) );
}
if( not -f $cur or  $year > $time->[2] or
	$mon > $time->[0] or $day > $time->[1] ){
my $curl = $ENV{'HOME'}.'/.Q_BREW.html';
my $casl = $ENV{'HOME'}.'/.Q_CASK.html';
my $url = 'https://formulae.brew.sh/formula/index.html';
my $uca = 'https://formulae.brew.sh/cask/index.html';
$re->{'CUR'} = 1 if system('curl','-so',$curl,$url);
$re->{'CUR'} = 1 if system('curl','-so',$casl,$uca);
}
if( $re->{'FOR'} ){
@list = `ls /usr/local/Cellar/*|\
sed -e 's/\\/usr\\/local\\/Cellar\\/\\(.*\\):/ \\1/' -e 's/_[1-9]\$//' -e '/^\$/d'`
}elsif( $re->{'CAS'} ){
@list = `ls /usr/local/Caskroom/*|\
sed -e 's/\\/usr\\/local\\/Caskroom\\/\\(.*\\):/ \\1/' -e '/^\$/d'`;
 if( @list == 1 ){
  $list[1] = $list[0];
  $list[0] = `ls /usr/local/Caskroom/|sed 's/^/ /'`;
 }
}
File(\@list,$cur,$re);
}

sub Linux{
exit unless `ls /home/linuxbrew/.linuxbrew/Cellar 2>/dev/null`;
 my( $cur,$re,$time,$year,$mon,$day ) = @_;
if( -f $cur ){
( $year,$mon,$day ) =
 split('-',`ls --full-time ~/.Q_BREW.html|awk '{print \$6}'`);
$time = [(
 ((localtime(time))[5] + 1900),
  ((localtime(time))[4]+1),
   ((localtime(time))[3]) )];
}
if( not -f $cur or $time->[0] > $year or
	$time->[1] > $mon or $time->[2] > $day ){
my $url = 'https://formulae.brew.sh/formula-linux/index.html';
$re->{'CUR'} = 1 if system('curl','-so',$cur,$url);
}
my @list = `ls /home/linuxbrew/.linuxbrew/Cellar/*|\
sed -E 's/\\/home\\/linuxbrew\\/.linuxbrew\\/Cellar\\/(.+):/ \\1/'|\
sed -e 's/_[1-9]\$//' -e '/^\$/d'`;
 File(\@list,$cur,$re);
}

sub File{
my $size = `tput cols`;
my( $list,$cur,$re,$cas,$test,$tap,@an ) = @_;
open my $BREW,$cur or die "$!\n";
while( my $brew = <$BREW> ){
 if( $brew =~ s[\s+<td><a href[^>]+>(.+)</a></td>\n][$1] ){
  $tap = "$brew\t"; next;
 }elsif( not $test and $brew =~ s[\s+<td>(.+)</td>\n][$1] ){
  $tap .= "$brew\t";
  $test = 1; next;
 }elsif( $test and $brew =~ s[\s+<td>(.+)</td>][$1] ){
  $tap .= $brew;
  $test = 0;
 }
 $tap =~ s/^(.+)\t(.+)\t(.+)\n$/$1\t$3\t$2\n/ if $tap and $re->{'CAS'};
  if( $tap and $size > 79 and length $tap > $size-20 ){
   $tap = substr($tap,0,$size-20); $tap .= "\n";
  }
 push @an,$tap if $tap;
 $tap = '';
}
close $BREW;
@an = sort{$a cmp $b}@an;
Search( $list,\@an,0,0,0,0,$re,'' );
}

sub Search{
my( $list,$an,$in,$i,$nst,$pop,$re,$tap,$loop ) = @_;
for(;$an->[$i];$i++){
my( $brew_1,$brew_2,$brew_3 ) = split("\t",$an->[$i]);
 if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
  last;
 }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
  $tap = "    $brew_1\t";
  $in++; $re->{'EN'}++; $pop = 1;
   if( $re->{'OPT'} and $brew_1 =~ /$re->{'OPT'}/ ){
    my $mit = $brew_1.' [i]';
    $re->{'HA'}{$mit} = length $mit;
    push @{$re->{'ARR'}},$mit;
    $re->{'LEN'} = $re->{'HA'}{$mit} if $re->{'LEN'} < $re->{'HA'}{$mit};
   }
 }else{
  $re->{'ALL'} .= "    $brew_1\t" unless $re->{'PRINT'};
   if( $re->{'OPT'} and $brew_1 =~ /$re->{'OPT'}/ ){
    $re->{'HA'}{$brew_1} = length $brew_1;
    push @{$re->{'ARR'}},$brew_1;
    $re->{'LEN'} = $re->{'HA'}{$brew_1} if $re->{'LEN'} < $re->{'HA'}{$brew_1};
   }
 }
 if( $pop ){
   if( not $list->[$in] or $list->[$in] =~ /^\s/ ){
    $re->{'ALL'} .= " Empty folder /usr/local/Cellar/ =>$list->[$in - 1]";
    Search( $list,$an,$in,$i,++$nst,0,$re,'' );
     $loop = 1;
     last;
   }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
   $re->{'ALL'} .= " Check folder /usr/local/Cellar/ =>$list->[$in - 1]";
    while(1){ $in++;
     last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
    }
   }
   if( "$brew_2\n" gt $list->[$in++] ){
    $tap =~ s/^\s{3}/(i)/;
   }else{
    $tap =~ s/^\s{3}/ i /;
   }
   $tap .= "$brew_2\t";
 }else{
  $re->{'ALL'} .= "$brew_2\t" unless $re->{'PRINT'};
 }
 if( $pop ){
  $tap .= $brew_3;
  $pop = 0;
 }else{
  $re->{'ALL'} .= "$brew_3" unless $re->{'PRINT'};
 }
 $re->{'ALL'} .= $tap;
 $tap = ''; $re->{'CN'}++;
}
 if( $nst > 9 ){
  print " Deep recursion on subroutine\n"; exit;
 }
 if( $list->[$in] and not $loop ){
  if( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
   $tap = $list->[$in++] if $list->[$in] =~ s/\n/\t/;
    if( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
    $re->{'ALL'} .= " Check folder /usr/local/Cellar/ =>$list->[$in - 1]\n";
     while(1){ $in++;
      last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
     }
    } 
   $re->{'ALL'} .= " i $tap$list->[$in]";
   $re->{'CN'}++; $re->{'EN'}++;
    if( $re->{'OPT'} and $tap =~ /$re->{'OPT'}/ ){
     my $mit = $tap.' [i]' if $tap =~ s/^\s(.+)\t$/$1/;
     $re->{'HA'}{$mit} = length $mit;
     push @{$re->{'ARR'}},$mit;
     $re->{'LEN'} = $re->{'HA'}{$mit} if $re->{'LEN'} < $re->{'HA'}{$mit};
    }
  }else{
  $re->{'ALL'} .= " Empty folder /usr/local/Cellar/ =>$list->[$in]";
  }
 Search( $list,$an,++$in,$i,++$nst,0,$re,'' );
 }
}

sub Format{
my $re = shift;
 if( $re->{'LIST'} or $re->{'PRINT'} ){
  print"$re->{'ALL'}";
  print " item $re->{'CN'} : install $re->{'EN'}\n";
 }elsif( $re->{'SEARCH'} ){
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
 }
print"\n" if @{$re->{'ARR'}};
print " Not connected\n" if $re->{'CUR'};
}
__END__
Check Mac
diff <(ls /usr/local/Cellar) <(brew list --formula)
diff <(ls /usr/local/Caskroom) <(brew list --cask)
Check Linux
diff <(ls /home/linuxbrew/.linuxbrew/Cellar) <(brew list --formula)
