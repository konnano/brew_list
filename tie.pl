use strict;
use warnings;
use NDBM_File;
use Fcntl;# ':DEFAULT';

my $IN = 0;
my( $re,$OS_Version,$OS_Version2,%MAC_OS,$CPU,$Xcode,$RPM,$CAT,@BREW,@CASK );

if( $^O eq 'darwin' ){
 $re->{'MAC'} = 1;
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/(10.\d+)\.?\d*\n/$1/;
   $OS_Version =~ s/^11.+\n/11.0/;

 $CPU = `sysctl machdep.cpu.brand_string`;
  $CPU = $CPU =~ /Apple\s+M1/ ? 'arm\?' : 'intel\?';
   $OS_Version2 = $OS_Version;
    $OS_Version2 = "${OS_Version}M1" if $CPU eq 'arm\?';

 $Xcode = `which xcodebuild` ?
  `xcodebuild -version|awk '/Xcode/{print \$NF}'|sed 's/\\([0-9]*\\.[0-9]*\\).*/\\1/'` : 0;

 %MAC_OS = ('big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14','high_sierra'=>'10.13',
            'sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10');
 $re->{'CLANG'} = `clang --version|awk '/Apple/{print \$NF}'|sed 's/.*-\\([^.]*\\)\\..*/\\1/'`;

 $re->{'CLT'} = `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables|\
                 awk '/version/ {print \$2}'|sed 's/\\([0-9]*\\.[0-9]*\\).*/\\1/'`;

  if( $CPU eq 'intel\?' ){
   Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew',1,1 );
     Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/usr/local/Homebrew/Library/Taps',1,0 );
  }else{
   Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
    Dirs_1( '/opt/homebrew/Library/Taps/homebrew',1,1 );
     Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/opt/homebrew/Library/Taps',1,0 );
  }
}else{
 $re->{'LIN'} = 1;
 Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
  Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps',1,0 );
   $RPM = `ldd --version|awk '/ldd/{print \$NF}'`;
    $CAT = `cat ~/.BREW_LIST/brew.txt|awk '/glibc/{print \$2}'`;
}

sub Dirs_1{
 my( $dir,$ls,$cask ) = @_;
 my @files = glob "$dir/*";
  for my $card(@files) {
   next if $ls and $card =~ m!/homebrew$|/homebrew-core$|/homebrew-cask$|
                              /homebrew-bundle$|/homebrew-services$!x;
    if( -d $card ){
     Dirs_1( $card,$ls,$cask );
    }else{
     $cask ? push @CASK,"$card\n" : push @BREW,"$card\n" if $card =~ /\.rb$/;
    }
  }
}

tie my %tap,"NDBM_File","$ENV{'HOME'}/.BREW_LIST/DBM",O_RDWR|O_CREAT,0644;
 for my $dir1(@BREW){ chomp $dir1;
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb|;
   $tap{"${name}core"} = $dir1;
  open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
   while(my $data=<$BREW>){
     if( $data =~ /^\s*bottle\s+do/ ){
      $IN = 1; next;
     }elsif( $data =~ /^\s*rebuild/ and $IN == 1 ){
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
         $tap{"${name}11.0M1"} = $tap{"${name}11.0"} = $tap{"${name}10.15"} =
         $tap{"${name}10.14"} = $tap{"${name}10.13"} = $tap{"${name}10.12"} =
         $tap{"${name}10.11"} = $tap{"${name}10.10"} = $tap{"${name}Linux"} = 1;
        }
       next;
     }elsif( $data =~ /^\s*end/ and $IN == 1 ){
       $IN = 0; next;
     }

    if( $re->{'MAC'} ){
     if( $data =~ /^\s*on_linux\s*do/ ){ $IN = 1; next;
     }elsif( $data !~ /^\s*end/ and $IN == 1 ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 1){ $IN = 0; next;
     }
    }else{
     if( $data =~ /^\s*on_macos\s+do/ ){ $IN = 1; next;
     }elsif( $data !~ /^\s*end/ and $IN == 1  ){ next;
     }elsif( $data =~ /^\s*end/ and $IN == 1){ $IN = 0; next;
     }elsif( $data =~ /^\s*on_linux\s*do/ ){ $IN = 2; next;
     }elsif( $data =~ /^\s*keg_only/ and $IN == 2 ){
       $tap{"${name}keg_Linux"} = 1; next;
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
       if( $IN == 4 and $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
         $data =~ s/(\d+\.\d+)\.?\d*/$1/;
          $tap{"${name}un_xcode"} = 1 if $data > $Xcode;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
            next;
       }elsif( $IN == 4 and $data =~ /\s*depends_on\s+xcode:\s+:build/ ){
         $tap{"${name}un_xcode"} = 1 unless $Xcode;
          $tap{"$name$OS_Version2"} = 0 unless $Xcode;
           next;
       }elsif( $IN == 4 and $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*:build).*\n/$1/ ){
         $tap{"${data}uses"} .= "$name\t";
          next;
       }elsif( $IN == 4 and $data =~ /^\s+else|^\s+end/ ){
         $IN = 0; next;
       }elsif( $IN == 5 and $data =~ /^\s*depends_on/ ){
         next;
       }elsif( $IN == 5 and $data =~ /^\s*end/ ){
         $IN = 0; next;
       }elsif( $IN == 5 and $data =~ /^\s+else/ ){
         $IN = 6; next;
       }elsif( $IN == 6 and $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
         $data =~ s/(\d+\.\d+)\.?\d*/$1/;
          $tap{"${name}un_xcode"} = 1 if $data > $Xcode;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
       }elsif( $IN == 6 and $data =~ /\s*depends_on\s+xcode:\s+:build/ ){
         $tap{"${name}un_xcode"} = 1 unless $Xcode;
          $tap{"$name$OS_Version2"} = 0 unless $Xcode;
           next;
       }elsif( $IN == 6 and $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*:build).*\n/$1/ ){
         $tap{"${data}uses"} .= "$name\t";
          next;
       }elsif( $IN == 6 and $data =~ /^\s+end/ ){
         $IN = 0; next;
       }
     }elsif( my( $ls1,$ls2 ) =
       $data =~ /^\s*depends_on\s+xcode:.+if\s+MacOS::CLT\.version\s+([^\s]+)\s+"([^"]+)".*\n/ ){
         $tap{"${name}un_xcode"} = 1 if not $Xcode and  eval "$re->{'CLT'} $ls1 $ls2";
          $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
           next;
     }elsif( $data =~ /\s*depends_on\s+xcode:\s+:build/ ){
         $tap{"${name}un_xcode"} = 1 unless $Xcode;
          $tap{"$name$OS_Version2"} = 0 unless $Xcode;
     }elsif( $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
         $data =~ s/(\d+\.\d+)\.?\d*/$1/;
          $tap{"${name}un_xcode"} = 1 if $data > $Xcode;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
            next;
     }
    }

     if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
        next;
     }elsif( $data =~ /^\s*depends_on\s+"[^"]+"\s+=>.+:build/ ){
        next;
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"(?!.*\sif\s).*\n/$1/ ){
        $tap{"${data}uses"} .= "$name\t";
     }elsif( my( $ls1,$ls2 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+).*\n/ ){
      if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$ls2} ){
        $tap{"${ls1}uses"} .= $name;
      }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
        $tap{"${data}uses"} .= "$name\t";
     }elsif( $data =~ /^\s*depends_on.+\s+if\s+/ ){
       if( my( $ls1,$ls2,$ls3 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+).*\n/ ){
         if( $re->{'MAC'} and eval"$OS_Version $ls2 $MAC_OS{$ls3}" ){
          $tap{"${ls1}uses"} .= "$name\t";
        }
       }elsif( my($ls4,$ls5,$ls6) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+).*\n/ ){
         if( $re->{'MAC'} and eval"$re->{'CLANG'} $ls5 $ls6" ){
          $tap{"${ls4}uses"} .= "$name\t";
         }
       }elsif( my( $ls7,$ls8 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
         if( $re->{'MAC'} and $ls8 =~ /$CPU/ ){
          $tap{"${ls7}uses"} .= "$name\t";
         }
       }
     }

     if( $data =~ /^\s*keg_only.*macos/ ){
      $tap{"${name}keg"} = 1;
     }elsif( $data =~ /^\s*keg_only/ ){
      $tap{"${name}keg_Linux"} = $tap{"${name}keg"} = 1;
     }elsif( $data =~ /^\s*depends_on\s+:macos/ ){
      $tap{"${name}un_Linux"} = 1; $tap{"${name}Linux"} = 0;
     }elsif( $data =~ /^\s*depends_on\s+:linux/ ){
       $tap{"${name}un_xcode"} = 1;
     }elsif( $data =~ s/^\s*depends_on\s+macos:\s+:([^\s]*).*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} gt $OS_Version ){
       $tap{"${name}un_xcode"} = 1;
      }
     }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[:([^\s]+),\s+:build].*\n/$1/ ){
      if( $OS_Version and $MAC_OS{$data} gt $OS_Version ){
       $tap{"${name}un_xcode"} = 1;
      }
     }

   }
  close $BREW;
 }
 if( $RPM and $RPM > $CAT ){
  $tap{'glibcun_Linux'} = 1;
   $tap{'glibcLinux'} = 0;
 }

 if( $re->{'MAC'} ){
  my $IF1 = 1; my $IF2 = 0 ; my $VER = 0;
  for my $dir2(@CASK){ chomp $dir2;
   my( $name ) = $dir2 =~ m|.+/(.+)\.rb|;
    $tap{"${name}cask"} = $dir2;
   open my $BREW,'<',$dir2 or die " tie Info_2 $!\n";
    while(my $data=<$BREW>){
     if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)".*\n/ ){
      $tap{"${name}un_cask"} = 1 unless eval "$OS_Version $ls1 $MAC_OS{$ls2}";
     }elsif( $data =~ /^\s*depends_on\s+formula:/ ){
      $tap{"${name}formula"} = 1;
       if( my( $ls3 ) = $data =~ /^\s*depends_on\s+formula:.+if\s+Hardware::CPU\.([^\s]+).*\n/ ){
        $tap{"${name}formula"} = 0 if $CPU ne $ls3;
       }
     }elsif( my( $ls4,$ls5 ) = $data =~ /if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ and $IF1 ){
       $IF2 = 1;
      if( eval"$OS_Version $ls4 $MAC_OS{$ls5}" ){
       $IF1 = 0; $VER = 1;
      }
     }elsif( $data =~ /^\s*else/ and $IF1 and $IF2 ){
       $VER = 1;
     }elsif( my( $ls6 ) = $data =~ /^\s*version\s+"([^"]+)"/ and $VER ){
      $tap{"${name}version"} = $ls6;
       $IF1 = $IF2 = $VER = 0;
     }
    }
   close $BREW;
  $IF1 = 1; $IF2 = $VER = 0;
  }

  open my $FILE,'<',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE $!\n";
   my @LIST = <$FILE>;
  close $FILE;

  @BREW = sort{$a cmp $b} map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @BREW;
  @CASK = sort{$a cmp $b} map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @CASK;

   my $COU = $IN;
  for(my $i=0;$i<@BREW;$i++){
    for(;$COU<@LIST;$COU++){
     my( $ls1,$ls2,$ls3 ) = split "\t",$LIST[$COU]; 
      last if $BREW[$i] lt $ls1;
       $tap{"${BREW[$i]}ver"} = $ls2 and last if $BREW[$i] eq $ls1; 
    }
    for(;$IN<@CASK;$IN++){
     last if $BREW[$i] lt $CASK[$IN];
      if($BREW[$i] eq $CASK[$IN]){
       $tap{"${CASK[$IN]}so_name"} = 1;
        last;
      }
    }  
  }
 }
untie %tap;
__END__
