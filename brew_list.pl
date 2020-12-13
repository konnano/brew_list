#!/usr/bin/perl
use strict;
use warnings;

my $re  = {'LEN'=>1,'FOR'=>1,'ARR'=>[],'EN'=>0,
 'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_BREW.html",
  'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt"};
my $ref = {'LEN'=>1,'CAS'=>1,'ARR'=>[],'EN'=>0,
 'DIR'=>"$ENV{'HOME'}/.BREW_LIST/Q_CASK.html",
  'FON'=>"$ENV{'HOME'}/.BREW_LIST/Q_FONT.txt"};
`uname` =~ /^Darwin/ ? $re->{'MAC'} = $ref->{'MAC'} = 1 :
 `uname ` =~ /^Linux/ ? $re->{'LIN'} = 1 : exit;
if( $re->{'LIN'} ){ exit unless -d '/home/linuxbrew/.linuxbrew/Cellar'; }
 if( $re->{'MAC'} ){ exit unless -d '/usr/local/Cellar'; }
`nohup mkdir -p ~/.BREW_LIST >/dev/null 2>&1 &`;
unless( $ARGV[0] ){
 die "  Option
  -l List : -i Instaled list : -s Type search name
  Darwin Option
  -c Casks list : -ci Casks instaled list\n";
}
 my $con;
if( $ARGV[0] eq '-l' ){     $con = $re;  $re->{'LIST'}  = 1;
}elsif( $ARGV[0] eq '-i' ){ $con = $re;  $re->{'PRINT'} = 1;
}elsif( $ARGV[0] eq '-c' ){ $con = $ref; $ref->{'LIST'} = 1;  exit if $re->{'LIN'};
}elsif( $ARGV[0] eq '-ci'){ $con = $ref; $ref->{'PRINT'} = 1; exit if $re->{'LIN'};
}elsif( $ARGV[0] eq '-s' ){ $re->{'SEARCH'} = $ref->{'SEARCH'} = 1;
}else{
 die "  Option
  -l List : -i Instaled list : -s Type search name
  Darwin Option
  -c Casks list : -ci Casks instaled list\n";
}
$ARGV[1] ? $re->{'OPT'} = $ref->{'OPT'} = lc $ARGV[1] : die " Type search name\n"
	if $re->{'SEARCH'};
if( $re->{'LIN'} ){
 Linux($re); Format($re);
}elsif( $re->{'MAC'} and $re->{'SEARCH'} ){
 my $pid = fork;
die "Not fork: $!\n" unless defined $pid;
  if($pid){
   Darwin($ref);
   waitpid($pid,0);
  }else{
   Darwin($re);
  }
  if($pid){
   waitpid($pid,0);
   Format($ref);
  }else{
   Format($re); exit;
  }
}else{ Darwin($con); Format($con); }

sub Darwin{
 my( $re,$time,@list ) = @_;
if( -f $re->{'DIR'} ){
$time=[split(" ",`ls -lT ~/.BREW_LIST/Q_BREW.html|awk '{print \$9,\$6,\$7}'`)]
	if $re->{'FOR'};
$time=[split(" ",`ls -lT ~/.BREW_LIST/Q_CASK.html|awk '{print \$9,\$6,\$7}'`)]
	if $re->{'CAS'};
}
( $re->{'YEA'},$re->{'MON'},$re->{'DAY'} ) = (
 ((localtime(time))[5] + 1900),
  ((localtime(time))[4]+1),
   ((localtime(time))[3]) );
if( not -f $re->{'DIR'} or  $re->{'YEA'} > $time->[0] or 
	$re->{'MON'} > $time->[1] or $re->{'DAY'} > $time->[2] ){
my $ufo = 'https://formulae.brew.sh/formula/index.html';
my $uca = 'https://formulae.brew.sh/cask/index.html';
 if( $re->{'FOR'} ){
  $re->{'CUR'} = 1 if system('curl','-so',$re->{'DIR'},$ufo);
 }else{
  $re->{'CUR'} = 1 if system('curl','-so',$re->{'DIR'},$uca);
 }
}
if( $re->{'FOR'} and not $re->{'SEARCH'} ){
@list = `ls /usr/local/Cellar/* 2>/dev/null|\
sed -e 's/\\/usr\\/local\\/Cellar\\/\\(.*\\):/ \\1/' -e 's/_[1-9]\$//' -e '/^\$/d'`;
 if( @list == 1 ){
  $list[1] = $list[0];
  $list[0] = `ls /usr/local/Cellar|sed 's/^/ /'`;
 }
}elsif( $re->{'CAS'} and not $re->{'SEARCH'} ){
@list = `ls /usr/local/Caskroom/* 2>/dev/null|\
sed -e 's/\\/usr\\/local\\/Caskroom\\/\\(.*\\):/ \\1/' -e '/^\$/d'`;
 if( @list == 1 ){
  $list[1] = $list[0];
  $list[0] = `ls /usr/local/Caskroom|sed 's/^/ /'`;
 }
}elsif( $re->{'FOR'} and $re->{'SEARCH'} ){
@list = `ls  /usr/local/Cellar|sed 's/^/ /'`;
}else{
@list = `ls  /usr/local/Caskroom|sed 's/^/ /'`;
}
File(\@list,$re);
}

sub Linux{
 my( $re,$time,$year,$mon,$day,@list ) = @_;
if( -f $re->{'DIR'} ){
( $year,$mon,$day ) =
 split('-',`ls --full-time ~/.BREW_LIST/Q_BREW.html|awk '{print \$6}'`);
$time = [(
 ((localtime(time))[5] + 1900),
  ((localtime(time))[4]+1),
   ((localtime(time))[3]) )];
}
if( not -f $re->{'DIR'} or $time->[0] > $year or
	$time->[1] > $mon or $time->[2] > $day ){
my $url = 'https://formulae.brew.sh/formula-linux/index.html';
$re->{'CUR'} = 1 if system('curl','-so',$re->{'DIR'},$url);
}
unless( $re->{'SEARCH'} ){
@list = `ls /home/linuxbrew/.linuxbrew/Cellar/* 2>/dev/null|\
sed -E 's/\\/home\\/linuxbrew\\/.linuxbrew\\/Cellar\\/(.+):/ \\1/'|\
sed -e 's/_[1-9]\$//' -e '/^\$/d'`;
 if( @list == 1 ){
  $list[1] = $list[0];
  $list[0] = `ls /home/linuxbrew/.linuxbrew/Cellar|sed 's/^/ /'`;
 }
}else{
@list = `ls /home/linuxbrew/.linuxbrew/Cellar|sed 's/^/ /'`;
}
File(\@list,$re);
}

sub File{
my $size = `tput cols`;
my( $list,$re,$test,$tap,@an ) = @_;
open my $BREW,$re->{'DIR'} or die " $!\n";
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
 push @an,$tap if $tap;
 $tap = '';
}
close $BREW;
push @an,split("\n",`cat ~/.BREW_LIST/Q_FONT.txt 2>/dev/null`)
 if $re->{'CAS'} and $re->{'OPT'} and $re->{'OPT'} =~ /f?o?n?t?/;
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
    my $mit = $brew_1.' ✅';
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
 unless( $re->{'SEARCH'} ){
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
}
 if( $nst > 9 ){
  print " Deep recursion on subroutine\n"; exit;
 }
 if( $list->[$in] and not $loop ){
  if( $re->{'OPT'} and $list->[$in] =~ /$re->{'OPT'}/ ){
   my $mit = $list->[$in].' ✅' if $list->[$in] =~ s/^\s(.+)\n/$1/;
   $re->{'HA'}{$mit} = length $mit;
   push @{$re->{'ARR'}},$mit;
   $re->{'LEN'} = $re->{'HA'}{$mit} if $re->{'LEN'} < $re->{'HA'}{$mit};
  }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){ ###
   $tap = $list->[$in++] if $list->[$in] =~ s/\n/\t/;
   if( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
    $re->{'ALL'} .= " Check folder /usr/local/Cellar/ =>$list->[$in - 1]\n";
    while(1){ $in++;
     last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
    }
   } 
   $re->{'ALL'} .= " i $tap$list->[$in]";
   $re->{'CN'}++; $re->{'EN'}++;
  }else{
   $re->{'ALL'} .= " Empty folder /usr/local/Cellar/ =>$list->[$in]";
  }
 Search( $list,$an,++$in,$i,++$nst,0,$re,'' );
 }
}

sub Format{
my $re = shift;
 if( $re->{'LIST'} or $re->{'PRINT'} ){
  system('printf', '\033[?7l') if $re->{'MAC'};
  system('setterm','-linewrap','off') if $re->{'LIN'};
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
 $re->{'CAS'} = 0;
 }
print "\n" if @{$re->{'ARR'}};
print " \033[31mNot connected\033[37m\n" if $re->{'CUR'};
 system('printf', '\033[?7h') if $re->{'MAC'};
 system('setterm','-linewrap','on') if $re->{'LIN'};
nohup( $re ) if $re->{'MAC'} and ( $re->{'CAS'} or $re->{'FOR'} );
}

sub nohup{
my $re = shift;
my $time=[split(" ",`ls -lT ~/.BREW_LIST/Q_FONT.txt|awk '{print \$6,\$7,\$9}'`)]
	if -f $re->{'FON'};
 if( not -f $re->{'FON'} or  $re->{'YEA'} > $time->[2] or
	$re->{'MON'} > $time->[0] or $re->{'DAY'} > $time->[1] ){
 `nohup ./font.sh >/dev/null 2>&1 &`;
 }
}
__END__
Check Darwin
diff <(ls /usr/local/Cellar) <(brew list --formula)
diff <(ls /usr/local/Caskroom) <(brew list --cask)
Check Linux
diff <(ls /home/linuxbrew/.linuxbrew/Cellar) <(brew list --formula)
