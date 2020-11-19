#!/usr/bin/perl
use strict;
use warnings;

my $cur = $ENV{'HOME'}.'/.Q_BREW.html';
my( @list,@an,$time,$year,$mon,$day,$tap,$test,$cn,$en );
my $pri = 1 if $ARGV[0] and $ARGV[0] eq '-i';

"Darwin\n" eq `uname` ? Darwin() : "Linux\n" eq `uname` ? Linux() : exit;

sub Darwin{
if( -f $cur ){
$time = [split(" ",`ls -lT ~/.Q_BREW.html|awk '{print \$6,\$7,\$9}'`)];
( $year,$mon,$day ) = (
 ((localtime(time))[5] + 1900),
  ((localtime(time))[4]+1),
   ((localtime(time))[3]) );
}
if( not -f $cur or  $year > $time->[2] or
	$mon > $time->[0] or $day > $time->[1] ){
 unlink $cur;
my $url = 'https://formulae.brew.sh/formula/index.html';
 system('curl','-so',$cur,$url);
}

my @list = `ls /usr/local/Cellar/*|\
sed -E 's/\\/usr\\/local\\/Cellar\\/(.+):/ \\1/'|\
sed 's/_[1-9]\$//'|sed '/^\$/d'`;
}

sub Linux{
exit unless `ls /home/linuxbrew/.linuxbrew/Cellar 2>/dev/null`;

if( -f $cur ){
my $ls = `ls --full-time ~/.Q_BREW.html|awk '{print \$6}'`;
( $year,$mon,$day ) = split('-',$ls);
 $time = [( ((localtime(time))[5] + 1900),
  ((localtime(time))[4]+1),
   ((localtime(time))[3]) )];
}
if( not -f $cur or $time->[0] > $year or
	$time->[1] > $mon or $time->[2] > $day ){
 unlink $cur;
my $url = 'https://formulae.brew.sh/formula-linux/index.html';
 system('curl','-so',$cur,$url);
}

@list = `ls /home/linuxbrew/.linuxbrew/Cellar/*|\
sed -E 's/\\/home\\/linuxbrew\\/.linuxbrew\\/Cellar\\/(.+):/ \\1/'|\
sed 's/_[1-9]\$//'|sed '/^\$/d'`;
}

open my $BREW,$cur or die $!,"\n";
while(my $brew = <$BREW>){
 if( $brew =~ s[\s+<td><a href[^>]+>(.+)</a></td>\n][$1] ){
  $tap = "$brew\t"; next;
 }elsif( not $test and $brew =~ s[\s+<td>(.+)</td>\n][$1] ){
  $tap .= "$brew\t";
  $test = 1; next;
 }elsif( $test and $brew =~ s[\s+<td>(.+)</td>][$1] ){
  push @an,$tap.$brew;
  $test = 0;
 }
 $tap = '';
}
close $BREW;

@an = sort{$a cmp $b}@an;
search( \@list,\@an,0,0,0,0,'' );

sub search{
my( $list,$an,$in,$i,$nst,$pop,$tap,$loop ) = @_;

for(;$an->[$i];$i++){
my( $brew_1,$brew_2,$brew_3 ) = split("\t",$an->[$i]);
 if( $list->[$in] and " $brew_1\n" gt $list->[$in] ){
  last;
 }elsif( $list->[$in] and " $brew_1\n" eq $list->[$in] ){
  $tap = "    $brew_1\t";
  $in++; $en++; $pop = 1;
 }else{
  print "    $brew_1\t" unless $pri;
 }
 if( $pop ){
   if( not $list->[$in] or $list->[$in] =~ /^\s/ ){
    print " Empty folder /usr/local/Cellar/ =>$list->[$in - 1]";
    search( $list,$an,$in,$i,++$nst,0,'' );
     $loop = 1;
     last;
   }elsif( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
   print " Check folder /usr/local/Cellar/ =>$list->[$in - 1]";
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
  print "$brew_2\t" unless $pri;
 }
 if( $pop ){
  print "$tap$brew_3";
  $pop = 0;
 }else{
  print "$brew_3" unless $pri;
 }
 $tap = ''; $cn++;
}
 if( $nst > 9 ){
  print " Deep recursion on subroutine\n"; exit;
 }
 if( $list->[$in] and not $loop ){
  if( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
   $tap = $list->[$in++] if $list->[$in] =~ s/\n/\t/;
   if( $list->[$in + 1] and $list->[$in + 1] !~ /^\s/ ){
   print " Check folder /usr/local/Cellar/ =>$list->[$in - 1]\n";
    while(1){ $in++;
     last if not $list->[$in + 1] or $list->[$in + 1] =~ /^\s/;
    }
   } 
   print " i $tap$list->[$in]";
   $cn++; $en++;
  }else{
  print " Empty folder /usr/local/Cellar/ =>$list->[$in]";
  }
 search( $list,$an,++$in,$i,++$nst,0,'' );
 }
}
print " item $cn : install $en\n";
__END__
check
diff <(ls /usr/local/Cellar) <(brew list --formula)
