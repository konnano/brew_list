use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my( $IN,$CIN,$KIN,$VER ) = ( 0,0,0,0 );
chomp( my $UNAME = `uname -m` );
my $CPU = $UNAME =~ /arm64/ ? 'arm\?' : 'intel\?';
my( $re,$OS_Version,$OS_Version2,%MAC_OS,$Xcode,$RPM,$CAT,@BREW,@CASK,@ALIA );

if( $^O eq 'darwin' ){ $re->{'MAC'} = 1;
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/^(10\.1[0-5]).*\n/$1/;
   $OS_Version =~ s/^10\.9.*\n/10.09/;
    $OS_Version =~ s/^11.+\n/11.0/;
     $OS_Version =~ s/^12.+\n/12.0/;
 $OS_Version2 = $OS_Version;
  $OS_Version2 = "${OS_Version}M1" if $CPU eq 'arm\?';

unless( $ARGV[0] ){
 $Xcode = `xcodebuild -version 2>/dev/null` ?
  `xcodebuild -version|awk '/Xcode/{print \$NF}'` : 0;
    $Xcode =~ s/^(\d\.)/0$1/;
 $re->{'CLANG'} = `/usr/bin/clang --version|sed '/Apple/!d' 2>/dev/null` ?
                  `/usr/bin/clang --version|sed '/Apple/!d;s/.*clang-\\([^.]*\\).*/\\1/'` : 0;
 $re->{'CLT'} = `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null` ?
                `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables|\
                 sed '/version/!d;s/[^0-9]*\\([0-9]*\\.[0-9]*\\).*/\\1/'` : 0;
}
  %MAC_OS = ('monterey'=>'12.0','big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14',
             'high_sierra'=>'10.13','sierra'=>'10.12','el_capitan'=>'10.11','yosemite'=>'10.10',
             'mavericks'=>'10.09','mountain_lion'=>'10.08','lion'=>'10.07');

  if( $CPU eq 'intel\?' and -d '/usr/local/Cellar' ){
   unless( $ARGV[0] ){ $re->{'CEL'} = '/usr/local/Cellar';
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
     Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
       Dirs_1( '/usr/local/Homebrew/Library/Taps',1,0 );
   }
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew',1,1 );
  }else{
   unless( $ARGV[0] ){ $re->{'CEL'} = 'opt/homebrew/Cellar';
    Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
     Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/opt/homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
       Dirs_1( '/opt/homebrew/Library/Taps',1,0 );
   }
    Dirs_1( '/opt/homebrew/Library/Taps/homebrew',1,1 );
  }
 rmdir "$ENV{'HOME'}/.BREW_LIST/13";
}else{ $re->{'LIN'} = 1;
 $re->{'CEL'} = '/home/linuxbrew/.linuxbrew/Cellar';
  $RPM = `ldd --version 2>/dev/null` ? `ldd --version|awk '/ldd/{print \$NF}'` : 0;
   $CAT = `cat ~/.BREW_LIST/brew.txt 2>/dev/null` ? `cat ~/.BREW_LIST/brew.txt|awk '/glibc\t/{print \$2}'` : 0;
    $OS_Version2 = $UNAME =~ /x86_64/ ? 'Linux' : $UNAME =~ /arm64/ ? 'LinuxM1' : 'Linux32';
 Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
  Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
   Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps',1,0 );
}

sub Dirs_1{
my( $dir,$ls,$cask ) = @_;
 for(glob "$dir/*"){
  next if $ls and m[/homebrew$|/homebrew-core$|/homebrew-cask$|/homebrew-bundle$|/homebrew-services$];
   ( -d ) ? Dirs_1( $_,$ls,$cask ) : ( -l ) ? push @ALIA,$_ :
   ( /\.rb$/ and $cask ) ? push @CASK,$_ : ( /\.rb$/ ) ? push @BREW,$_ : 0;
 }
}

 my $DBM = $ARGV[0] ? 'DBM' : 'DBMG';
tie my %tap,'NDBM_File',"$ENV{'HOME'}/.BREW_LIST/$DBM",O_RDWR|O_CREAT,0666 or die " tie DBM $!\n";
unless( $ARGV[0] ){
 for my $alias(@ALIA){
  my $hand = readlink $alias;
  $alias =~ s|.+/(.+)|$1|;
   $hand =~ s|.+/(.+)\.rb|$1|;
  $tap{"${alias}alia"} = $hand;
 } my( $in,$e ) = int @BREW/4;
 for my $dir1(@BREW){
  if( $re->{'MAC'} ){ $e++;
   if( $e == $in ){ rmdir "$ENV{'HOME'}/.BREW_LIST/14";
   }elsif( $e == $in*2 ){ rmdir "$ENV{'HOME'}/.BREW_LIST/15";
   }elsif( $e == $in*3 ){ rmdir "$ENV{'HOME'}/.BREW_LIST/16";
   }
  }
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb|;
   $tap{"${name}core"} = $dir1;
  open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
   while(my $data=<$BREW>){
     if( $data =~ /^\s*bottle\s+do/ ){
      $KIN = 1; next;
     }elsif( $data =~ /^\s*rebuild/ and $KIN == 1 ){
       next;
     }elsif( $data !~ /^\s*end/ and $KIN == 1 ){
       if( $data =~ /.*,\s+all:/ ){
        $tap{"${name}12.0M1"} = $tap{"${name}12.0"} =
        $tap{"${name}11.0M1"} = $tap{"${name}11.0"} = $tap{"${name}10.15"} =
        $tap{"${name}10.14"} = $tap{"${name}10.13"} = $tap{"${name}10.12"} =
        $tap{"${name}10.11"} = $tap{"${name}10.10"} = $tap{"${name}10.09"} =
        $tap{"${name}Linux"} = 1;
       }
        $tap{"$name$data"} =
        $data =~ s/.*arm64_monterey:.*\n/12.0M1/ ? 1 :
        $data =~ s/.*monterey:.*\n/12.0/         ? 1 :
        $data =~ s/.*arm64_big_sur:.*\n/11.0M1/  ? 1 :
        $data =~ s/.*big_sur:.*\n/11.0/          ? 1 :
        $data =~ s/.*catalina:.*\n/10.15/        ? 1 :
        $data =~ s/.*mojave:.*\n/10.14/          ? 1 :
        $data =~ s/.*high_sierra:.*\n/10.13/     ? 1 :
        $data =~ s/.*sierra:.*\n/10.12/          ? 1 :
        $data =~ s/.*el_capitan:.*\n/10.11/      ? 1 :
        $data =~ s/.*yosemite:.*\n/10.10/        ? 1 :
        $data =~ s/.*x86_64_linux:.*\n/Linux/    ? 1 : next; # x86_64
       next;
     }elsif( $data =~ /^\s*end/ and $KIN == 1 ){
      $KIN = 0; next;
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

     if( $CIN or $data =~ /^\s*if\s+Hardware::CPU/ ){
       $CIN = $data =~ /$CPU/ ? 1 : 2 unless $CIN;
       if(($CIN == 1 or $CIN == 3) and $re->{'MAC'} and
           $data =~ s/^\s*depends_on\s+xcode:\s*.*"([^"]+)".*\n/$1/ ){
          $data =~ s/^(\d\.)/0$1/;
           $tap{"${name}un_xcode"} = 1 if $data gt $Xcode;
            $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
          next;
       }elsif( ( $CIN == 1 or $CIN == 3 ) and $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>.+:build.*\n/$1/ ){
          $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
           $tap{"${name}deps_b"} .= "$data\t"; next;
       }elsif( ( $CIN == 1 or $CIN == 3 ) and $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
          $tap{"${data}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$data\t"; next;
       }elsif( $CIN == 1 and $data =~ /^\s*else/ ){
          $CIN = 4; next;
       }elsif( $CIN == 2 and $data =~ /^\s*else/ ){
          $CIN = 3; next;
       }elsif( $data =~ /^\s*end/ ){
          $CIN = 0; next;
       }elsif( $data !~ /^\s*else/ ){
          next;
       }
     }

     if( $VER or my( $co1,$co2 ) = $data =~ /^\s*if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
      $VER = $re->{'LIN'} ? 2 : ( $co1 =~ /^[<=>]+$/ and eval "$OS_Version $co1 $MAC_OS{$co2}" ) ? 1 : 2 unless $VER;
       if(($VER == 1 or $VER == 3) and $data =~ s/\s*depends_on\s+"([^"]+)".*\n/$1/ ){
          $tap{"${data}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$data\t"; next;
   #    }elsif(($VER==1 or $VER==3) and $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)".*\n/$1/){
   #       $tap{"${data}uses"} .= "$name\t";
   #        $tap{"${name}deps"} .= "$data\t"; next;
       }elsif( $VER == 1 and $data =~ /^\s*else/ ){
          $VER = 4; next;
       }elsif( $VER == 2 and $data =~ /^\s*else/ ){
          $VER = 3; next;
       }elsif( $data =~ /^\s*end/ ){
          $VER = 0; next;
       }elsif( $data !~ /^\s*else/ ){
          next;
       }
     }

      if( my( $ls1,$ls2 ) =
        $data =~ /^\s*depends_on\s+xcode:.+if\s+MacOS::CLT\.version\s+([^\s]+)\s+"([^"]+)"/ ){
         if( $re->{'MAC'} and
             not $Xcode and $ls1 =~ /^[<=>]+$/ and $ls2 =~ /^\d+\.\d+$/ and eval "$re->{'CLT'} $ls1 $ls2" ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( my( $ls3,$ls4 ) =
        $data =~ /^\s*depends_on\s+xcode:.+:build.+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
         if( $re->{'MAC'} and $ls3 =~ /^[<=>]+$/ and eval "$OS_Version $ls3 $MAC_OS{$ls4}" and not $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( my( $ls5,$ls6,$ls7 ) =
        $data =~ /^\s*depends_on\s+xcode:\s*"([^"]+)"\s*if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
         $data =~ s/^(\d\.)/0$1/;
         if( $re->{'MAC'} and $ls6 =~ /^[<=>]+$/ and eval "$OS_Version $ls6 $MAC_OS{$ls7}" and $ls5 gt $Xcode ){
         $ls5 =~ s/^(\d\.)/0$1/;
          $tap{"${name}un_xcode"} = 1;
           $tap{"$name$OS_Version2"} = 0;
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ s/^\s*depends_on\s+xcode:\s+:build\s+if\s+Hardware::CPU\.([^\s]+).*\n/$1/ ){
         if( $re->{'MAC'} and $data =~ /$CPU/ and not $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ s/^\s*depends_on\s+xcode:.+"([^"]+)",\s+:build.*\n/$1/ ){
         $data =~ s/^(\d\.)/0$1/;
         if( $re->{'MAC'} and $data gt $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ /^\s*depends_on\s+xcode:\s+:build/ ){
         if( $re->{'MAC'} and not $Xcode ){
          $tap{"${name}un_xcode"} = 1;
           $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
         }elsif( $re->{'LIN'} ){
          $tap{"${name}un_Linux"} = 1;
           $tap{"${name}un_Linux"} = 0 if $tap{"${name}Linux"};
         } next;
      }elsif( $data =~ s/^\s*depends_on\s+xcode:\s*"([^"]+)".*\n/$1/ ){
        $data =~ s/^(\d\.)/0$1/;
         if( $re->{'MAC'} and $data gt $Xcode ){
           $tap{"${name}un_xcode"} = 1;
            $tap{"$name$OS_Version2"} = 0;
         }elsif( $re->{'LIN'} ){
           $tap{"${name}un_Linux"} = 1;
            $tap{"${name}Linux"} = 0; # bottle
         } next;
      }elsif( $data =~ s/\s*depends_on\s+arch:\s+:([^\s]+).*\n/$1/ and $UNAME ne $data ){
          $tap{"${name}un_xcode"} = $tap{"${name}un_Linux"} =1;
          $tap{"$name$OS_Version2"} = $tap{"${name}Linux"} = 0;
           next;
      }

     if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
         next;
     }elsif( my( $ds1,$ds2,$ds3 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+)/ ){
        if( $re->{'MAC'} and $ds2 =~ /^[<=>]+$/ and $ds3 =~ /^\d+$/ and eval "$re->{'CLANG'} $ds2 $ds3" ){
         $tap{"${ds1}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds1\t";
        }
     }elsif( my( $ds4,$ds5 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build\s+if\s+Hardware::CPU\.([^\s]+)/ ){
        if( $ds5 =~ /$CPU/ ){
         $tap{"${ds4}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds4\t";
        }
     }elsif( my( $us1,$us2 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build\s+unless\s+Hardware::CPU\.([^\s]+)/ ){
        if( $us2 !~ /$CPU/ ){
         $tap{"${us1}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$us1\t";
        }
     }elsif( my( $ds6,$ds7,$ds8 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
        if( $re->{'MAC'} and $ds7 =~ /^[<=>]+$/ and eval "$OS_Version $ds7 $MAC_OS{$ds8}" ){
         $tap{"${ds6}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds6\t";
        }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
       $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
        $tap{"${name}deps_b"} .= "$data\t";
     }elsif( my( $us3,$us4 ) =
       $data =~ /^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build,\s+since:\s+:([^\s]+)/ ){
        if( $re->{'LIN'} or $OS_Version < $MAC_OS{$us4} ){
         $tap{"${us3}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$us3\t";
        }
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
        $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         $tap{"${name}deps_b"} .= "$data\t";

     }elsif( my( $us5,$us6 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+)/ ){
       if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$us6} ){
        $tap{"${us5}uses"} .= "$name\t";
         $tap{"${name}deps"} .= "$us5\t";
       }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
     }elsif( my( $ls1,$ls2,$ls3 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
        if( $re->{'MAC'} and $ls2 =~ /^[<=>]+$/ and eval "$OS_Version $ls2 $MAC_OS{$ls3}" ){
         $tap{"${ls1}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls1\t";
        }
     }elsif( my($ls4,$ls5,$ls6) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+DevelopmentTools.+\s+([^\s]+)\s+([^\s]+)/ ){
        if( $re->{'MAC'} and $ls5 =~ /^[<=>]+$/ and $ls6 =~ /^\d+$/ and eval "$re->{'CLANG'} $ls5 $ls6" ){
         $tap{"${ls4}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls4\t";
        }
     }elsif( my( $ls7,$ls8 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Hardware::CPU\.([^\s]+)/ ){
        if( $ls8 =~ /$CPU/ ){
         $tap{"${ls7}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls7\t";
        }
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
     }

      if( $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_version"} = $data;
      }elsif( $data =~ s/^\s*desc\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_desc"} = $data;
      }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_name"} = $data;
      }elsif( $data =~ s/^\s*revision\s+(\d+).*\n/$1/ ){
        $tap{"${name}revision"} = "_$data";
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
      $tap{"${name}un_xcode"} = 1 if $OS_Version and $MAC_OS{$data} > $OS_Version;
    }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[:([^\s]+),\s+:build].*\n/$1/ ){
      $tap{"${name}un_xcode"} = 1 if $OS_Version and $MAC_OS{$data} < $OS_Version;
    }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+:([^\s]+).*\n/$1/ ){
      $tap{"${name}un_xcode"} = 1 if $OS_Version and $MAC_OS{$data} < $OS_Version;
    }
   }
  close $BREW;
 }
 if( $RPM and $RPM gt $CAT ){
  $tap{'glibcun_Linux'} = 1;
   $tap{'glibcLinux'} = 0;
 }
 rmdir "$ENV{'HOME'}/.BREW_LIST/17";
 sub Glob_1{
 my( $brew,$mine,$loop ) = @_;
  my @GLOB = $brew ? glob "$re->{'CEL'}/$brew/*" : glob "$re->{'CEL'}/*/*";
  for(@GLOB){ my($name) = m|$re->{'CEL'}/([^/]+)/.*|;
   if( -f "$_/INSTALL_RECEIPT.json" ){
    open my $cel,"$_/INSTALL_RECEIPT.json" or die " GLOB $!\n";
     while(<$cel>){
      unless( /\n/ ){
       my @HE = /{"full_name":"([^"]+)","version":"[^"]+"},?/g;
       for my $ls1(@HE){ my %HA;
        if( $tap{"${ls1}uses"} ){
         for(split '\t',$tap{"${ls1}uses"}){ $HA{$_}++; }
         unless( $HA{$name} ){
          if( $loop ){ return 1 if $ls1 eq $mine;
          }else{ next if Glob_1( $ls1,$name,1 );
           $tap{"${ls1}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls1\t";
          }
         }
        }
       }
      }else{ my %HA;
       my( $ls2 ) = /"full_name":\s*"([^"]+)".+/ ? $1 : next;
       if( $tap{"${ls2}uses"} ){
        for(split '\t',$tap{"${ls2}uses"}){ $HA{$_}++; }
        unless( $HA{$name} ){
         if( $loop ){ return 1 if $ls2 eq $mine;
         }else{ next if Glob_1( $ls2,$name,1 );
          $tap{"${ls2}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls2\t";
         }
        }
       }
      }
     }
    close $cel;
   }
  } 0;
 } Glob_1;
}

 if( $re->{'MAC'} ){
 rmdir "$ENV{'HOME'}/.BREW_LIST/18";
 my( $IN,$in,$e ) = ( 0,int @CASK/2,0 );
  for my $dir2(@CASK){
   rmdir "$ENV{'HOME'}/.BREW_LIST/19" if $in == $e++;
   my( $name ) = $dir2 =~ m|.+/(.+)\.rb|;
    $tap{"${name}cask"} = $dir2;
     my( $IF1,$IF2,$ELIF,$ELS ) = ( 1,0,0,0 );
    $tap{"${name}d_cask"} = $tap{"${name}formula"} = '';
   open my $BREW,'<',$dir2 or die " tie Info_2 $!\n";
    while(my $data=<$BREW>){
     if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ ){
       $tap{"${name}un_cask"} = 1 unless $ls1 !~ /^[<=>]+$/ or eval "$OS_Version $ls1 $MAC_OS{$ls2}";
     }elsif( $data =~ s/^\s*depends_on\s+formula:\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}formula"} .= "$data\t";
        $tap{"${data}u_form"} .= "$name\t";
       if( my( $ls3 ) = $data =~ /^\s*depends_on\s+formula:.+if\s+Hardware::CPU\.([^\s]+)/ ){
        $tap{"${name}formula"} = $tap{"${name}u_form"} = 0 if $CPU ne $ls3;
       }
     }elsif( $data =~ /^\s*depends_on\s+cask:\s+/ or $IN ){
      if( $data =~ /^\s*depends_on\s+cask:\s+\[/ ){ $IN = 1; next; }
       if( $data =~ /^\s*\]/ ){ $IN = 0; next; }
      $data =~ s/^\s*"([^"]+)".*\n/$1/;
       $data =~ s/^\s*depends_on\s+cask:\s+"([^"]+)".*\n/$1/;
        $tap{"${name}d_cask"} .= "$data\t";
         $data =~ s|.+/([^/]+)|$1|;
          $tap{"${data}u_cask"} .= "$name\t";
     }elsif( my( $ls4,$ls5 ) = $data =~ /^\s*if\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ ){
       $IF1 = 0; $ELIF = $ELS = 1;
       if( $ls4 =~ /^[<=>]+$/ and eval "$OS_Version $ls4 $MAC_OS{$ls5}" ){
        $ELS = $ELIF = 0; $IF2 = 1;
       }
     }elsif( my( $ls6,$ls7 ) = $data =~ /^\s*elsif\s+MacOS\.version\s+([^\s]+)\s+:([^\s]+)/ and $ELIF ){
       if( $ls6 =~ /^[<=>]+$/ and eval "$OS_Version $ls6 $MAC_OS{$ls7}" ){
        $ELS = $ELIF  = 0; $IF2 = 1;
       }
     }elsif( $data =~ /^\s*else/ and $ELS ){
       $IF2 = 1;
     }elsif(( $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ or
              $data =~ s/^\s*version\s+:([^\s]+).*\n/$1/ ) and ( $IF1 or $IF2 )){
       $tap{"${name}c_version"} = $data;
        $IF1 = $IF2 = 0;
     }elsif( $data =~ s/^\s*desc\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_desc"} = $data;
     }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_name"} = $data;
     }
    }
   close $BREW;
  }
 }
unless( $ARGV[0] ){
 open my $FILE,'<',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE $!\n";
  my @LIST = <$FILE>;
 close $FILE;

 @BREW = sort map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @BREW;
 @CASK = sort map{ $_=~s|.+/(.+)\.rb|$1|;$_ } @CASK if $re->{'MAC'};

  my $COU = $IN = 0;
 for(my $i=0;$i<@BREW;$i++){
   for(;$COU<@LIST;$COU++){
    my( $ls1,$ls2,$ls3 ) = split '\t',$LIST[$COU];
     last if $BREW[$i] lt $ls1;
      if( $BREW[$i] eq $ls1 ){
       $tap{"${BREW[$i]}ver"} = $tap{"${BREW[$i]}revision"} ? $ls2.$tap{"${BREW[$i]}revision"} : $ls2;
       $COU++; last;
      }
   }
   unless( $tap{"${BREW[$i]}ver"} ){
    $tap{"${BREW[$i]}ver"} = ( $tap{"${BREW[$i]}f_version"} and $tap{"${BREW[$i]}revision"} ) ?
     $tap{"${BREW[$i]}f_version"}.$tap{"${BREW[$i]}revision"} : $tap{"${BREW[$i]}f_version"} ?
      $tap{"${BREW[$i]}f_version"} : 0;
   }
   if( $re->{'MAC'} ){
     for(;$IN<@CASK;$IN++){
      last if $BREW[$i] lt $CASK[$IN];
       if($BREW[$i] eq $CASK[$IN]){
        $tap{"${CASK[$IN]}so_name"} = 1;
        $IN++; last;
       }
     }
   }
 }
}
untie %tap;
