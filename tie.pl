use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';
my( @brew,$file );
my $i = 0;

if( $^O eq 'darwin' ){
 $file = '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula';
}else{
 $file = '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula';
}
@brew = `ls $file`;

sub dirs_1{
 my $dir = shift;
 my @files = glob("$dir/*");
  for my $card (@files) {
   next if $card =~ m|/homebrew/|;
    if( -d $card){ dirs_1($card);
    }else{ push @brew,"$card\n" if $card =~ /\.rb$/;
    }
  }
}
dirs_1('/usr/local/Homebrew/Library/Taps') if $^O eq 'darwin';

tie my %tap,"NDBM_File","$ENV{'HOME'}/.BREW_LIST/DBM",O_RDWR|O_CREAT,0644;
 for my $name(@brew){ $name =~ s/(.+)\.rb\n/$1/;
  my $dir = $name =~ m|^/usr/| ? $name : "$file/$name";
  open my $BREW1,'<',"$dir.rb" or die " Info_1 $!\n";
   while(my $data=<$BREW1>){

     if( $data =~ /^\s*bottle\s*do/ ){
      $i=1; next;
     }elsif( $data =~ /\s*rebuild/ and $i == 1 ){
      next;
     }elsif( $data !~ /^\s*end/ and $i == 1 ){
       $tap{"$name$data"} = 1 if $data =~ s/.*arm64_big_sur:.*\n/11.0M1/;
        $tap{"$name$data"} = 1 if $data =~ s/.*big_sur:.*\n/11.0/;
       $tap{"$name$data"} = 1 if $data =~ s/.*catalina:.*\n/10.15/;
        $tap{"$name$data"} = 1 if $data =~ s/.*mojave:.*\n/10.14/;
       $tap{"$name$data"} = 1 if $data =~ s/.*high_sierra:.*\n/10.13/;
        $tap{"$name$data"} = 1 if $data =~ s/.*sierra:.*\n/10.12/;
       $tap{"$name$data"} = 1 if $data =~ s/.*el_capitan:.*\n/10.11/;
        $tap{"$name$data"} = 1 if $data =~ s/.*yosemite:.*\n/10.10/;
       $tap{"$name$data"} = 1 if $data =~ s/.*x86_64_linux:.*\n/Linux/;
        if( $data =~ /.*,\s*all:/ ){
         $tap{"${name}11.0M1"} = 1;  $tap{"${name}11.0"} = 1;
          $tap{"${name}10.15"} = 1;   $tap{"${name}10.14"} = 1;
         $tap{"${name}10.13"} = 1;   $tap{"${name}10.12"} = 1;
          $tap{"${name}10.11"} = 1;   $tap{"${name}10.10"} = 1;
        }
      next;
     }elsif( $data =~ /^\s*end/ and $i == 1 ){
      $i = 0; next;
     }

    if( $data =~ /^\s*on_linux\s*do/ ){
     $i = 2; next;
    }elsif( $data !~ /^\s*end/ and $data =~ /^\s*keg_only/ and $i == 2 ){
     $tap{"${name}keg_Linux"} = 1; next;
    }elsif( $data =~ /^\s*end/ and $i == 2 ){
     $i = 0; next;
    }

     if( $data =~ /^\s*keg_only.*macos/ ){
      $tap{"${name}keg"} = 1; next;
     }elsif( $data =~ /^\s*keg_only/ ){
      $tap{"${name}keg_Linux"} = $tap{"${name}keg"} = 1; next;
     }elsif( $data =~ /^\s*depends_on\s*:macos/ ){
      $tap{"${name}un_Linux"} = 1; next;
     }
   }
  close $BREW1;
 }
untie %tap;
__END__
