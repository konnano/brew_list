use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my $IN = 0;
my( $OS_Version,%MAC_OS,$CPU,$Xcode,$RPM,$CAT,@BREW,@CASK );

if( $^O eq 'darwin' ){
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/(\d\d.\d+)\.?\d*\n/$1/;
 $CPU = `sysctl machdep.cpu.brand_string`;
  $CPU = $CPU =~ /Apple\s+M1/ ? 'arm\?' : 'intel\?';
 $Xcode = `xcodebuild -version|xargs|awk '{print \$2}'`;
  $Xcode =~ s/(\d+\.\d+)\.?\d*\n/$1/;
 %MAC_OS = ('big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14','high_sierra'=>'10.13',
            'sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10');

 Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
  Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0 );
   Dirs_1( '/usr/local/Homebrew/Library/Taps',1 );
}else{
 Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0 );
  $RPM = `ldd --version|awk '/ldd/{print \$NF}'`;
  open my $CD,"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " CAT $!\n";
   while(my $an=<$CD>){
    my($ls1,$ls2,$ls3) = split("\t",$an);
     $CAT = $ls2 if $ls1 eq 'glibc';
   }
  close $CD
}

sub Dirs_1{
 my( $dir,$ls,$cask ) = @_;
 my @files = glob("$dir/*");
  for my $card (@files) {
   next if $ls and $card =~ m|/homebrew/|;
    if( -d $card){ Dirs_1( $card,$ls );
    }else{ $cask ? push @CASK,"$card\n" : push @BREW,"$card\n" if $card =~ /\.rb$/;
    }
  }
}

tie my %tap,"NDBM_File","$ENV{'HOME'}/.BREW_LIST/DBM",O_RDWR|O_CREAT,0644;
 for my $dir1(@BREW){ chomp $dir1;
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb|;
  open my $BREW,'<',$dir1 or die " Info_1 $!\n";
   while(my $data=<$BREW>){

     if( $data =~ /^\s*bottle\s+do/ ){
      $IN = 1; next;
     }elsif( $data =~ /\s*rebuild/ and $IN == 1 ){
      next;
     }elsif( $data !~ /^\s*end/ and $IN == 1 ){
       $tap{"$name$data"} = 1 if $data =~ s/.*arm64_big_sur:.*\n/11.0M1/;
        $tap{"$name$data"} = 1 if $data =~ s/.*big_sur:.*\n/11.0/;
       $tap{"$name$data"} = 1 if $data =~ s/.*catalina:.*\n/10.15/;
        $tap{"$name$data"} = 1 if $data =~ s/.*mojave:.*\n/10.14/;
       $tap{"$name$data"} = 1 if $data =~ s/.*high_sierra:.*\n/10.13/;
        $tap{"$name$data"} = 1 if $data =~ s/.*sierra:.*\n/10.12/;
       $tap{"$name$data"} = 1 if $data =~ s/.*el_capitan:.*\n/10.11/;
        $tap{"$name$data"} = 1 if $data =~ s/.*yosemite:.*\n/10.10/;
       $tap{"$name$data"} = 1 if $data =~ s/.*x86_64_linux:.*\n/Linux/;
        if( $data =~ /.*,\s+all:/ ){
         $tap{"${name}11.0M1"} = 1;  $tap{"${name}11.0"} = 1;
          $tap{"${name}10.15"} = 1;   $tap{"${name}10.14"} = 1;
         $tap{"${name}10.13"} = 1;   $tap{"${name}10.12"} = 1;
          $tap{"${name}10.11"} = 1;   $tap{"${name}10.10"} = 1;
         $tap{"${name}Linux"} = 1;
        }
      next;
     }elsif( $data =~ /^\s*end/ and $IN == 1 ){
      $IN = 0; next;
     }

    if( $data =~ /^\s*on_linux\s+do/ ){
     $IN = 2; next;
    }elsif( $data =~ /^\s*keg_only/ and $IN == 2 ){
     $tap{"${name}keg_Linux"} = 1; next;
    }elsif( $data !~ /^\s*end/ and $IN == 2 ){
     next;
    }elsif( $data =~ /^\s*end/ and $IN == 2 ){
     $IN = 0; next;
    }
     if( $data =~ /^\s*keg_only.*macos/ ){
      $tap{"${name}keg"} = 1; next;
     }elsif( $data =~ /^\s*keg_only/ ){
      $tap{"${name}keg_Linux"} = $tap{"${name}keg"} = 1; next;
     }elsif( $data =~ /^\s*depends_on\s+:macos/ ){
      $tap{"${name}un_Linux"} = 1; $tap{"${name}Linux"} = 0; next;
     }elsif( $data =~ /^\s*depends_on\s+:linux/ ){
       $tap{"${name}un_xcode"} = 1; next;
     }elsif( $data =~ s/^\s*depends_on\s+macos:\s+:([^\s]*).*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} gt $OS_Version ){
       $tap{"${name}un_xcode"} = 1; next;
      }
     }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[:([^\s]+),\s+:build].*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} gt $OS_Version ){
       $tap{"${name}un_xcode"} = 1; next;
      }
     }elsif( my( $ls1,$ls2 ) =
       $data =~ /^\s*depends_on\s+xcode:.+if\s+MacOS::CLT\.version\s+([^\s]+)\s+"([^"]+)".*\n/ ){
       ### $tap{"${name}un_xcode"} = 1 if( $Xcode and eval "$Xcode $ls1 $ls2" );
           next;
     }
    if( $^O eq 'darwin' ){
     if( $IN or $data =~ /^\s*if\s+Hardware::CPU/ ){
      $IN = $data =~ /$CPU/ ? 3 : 4 unless $IN;
       if( $IN == 3 and $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
         $data =~ s/(\d+\.\d+)\.?\d*/$1/;
          $tap{"${name}un_xcode"} = 1 if $data > $Xcode;
       }elsif( $IN == 3 and $data =~ /^\s+else|^\s+end/ ){
        $IN = 0;
       }elsif( $IN == 4 and $data =~ /^\s+else/ ){
        $IN = 5;
       }elsif( $IN == 5 and $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
         $data =~ s/(\d+\.\d+)\.?\d*/$1/;
          $tap{"${name}un_xcode"} = 1 if $data > $Xcode;
       }elsif( $IN == 5 and $data =~ /^\s+end/ ){
        $IN = 0;
       }
     }elsif( $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
         $data =~ s/(\d+\.\d+)\.?\d*/$1/;
          $tap{"${name}un_xcode"} = 1 if $data > $Xcode;
     }
    }
   }
  close $BREW;
 }
 if( $RPM and $RPM > $CAT ){
   $tap{'glibcun_Linux'} = 1;
    $tap{'glibcLinux'} = 0;
 }
  $IN = 0;
 for(my $i=0;$i<@BREW;$i++){
  $BREW[$i] =~ s|.+/(.+)|$1|;
  for(;$IN<@CASK;$IN++){
   my( $name ) = $CASK[$IN] =~ m|.+/(.+)\n|;
   last if $BREW[$i] lt $name;
    if($BREW[$i] eq $name){
     $name =~ s/\.rb$//;
     $tap{"${name}so_name"} = 1;
      last;
    }
  }
 }

 for my $dir2(@CASK){ chomp $dir2;
  my( $name ) = $dir2 =~ m|.+/(.+)\.rb|;
  open my $BREW,'<',$dir2 or die " Info_2 $!\n";
   while(my $data=<$BREW>){
    if( my( $ls1,$ls2 ) = $data =~ /^\s+depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)".*\n/ ){
     $tap{"${name}un_cask"} = 1 unless eval "$OS_Version $ls1 $MAC_OS{$ls2}";
    }
    if( $data =~ /^\s*depends_on\s+formula:/ ){
     $tap{"${name}formula"} = 1;
      if( my( $ls3 ) = $data =~ /^\s*depends_on\s+formula:.+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
       $tap{"${name}formula"} = 0 if $CPU ne $ls3;
      }
    }
   }
  close $BREW;
 }
untie %tap;
__END__
