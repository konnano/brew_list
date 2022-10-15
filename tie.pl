use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my( $IN,$KIN,$SPA ) = ( 0,0,0 );
my $UNAME = `uname -m` !~ /arm64|aarch64/ ? 'x86_64' : 'arm64';
my $CPU = $UNAME =~ /arm64/ ? 'arm\?' : 'intel\?';
my( $re,$OS_Version,$OS_Version2,%MAC_OS,%HAN,$Xcode,$RPM,$CAT,@BREW,@CASK );

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
     %HAN = ('newer'=>'>','older'=>'<');

  if( $CPU eq 'intel\?' and -d '/usr/local/Cellar' ){ $re->{'CEL'} = '/usr/local/Cellar';
    $re->{'FON'} = '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
     $re->{'COM'} = '/usr/local/share/zsh/site-functions';
   unless( $ARGV[0] ){
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks',0,1 );
     Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
      Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
       Dirs_1( '/usr/local/Homebrew/Library/Taps',1,0 );
   }
    Dirs_1( '/usr/local/Homebrew/Library/Taps/homebrew',1,1 );
  }else{ $re->{'CEL'} = '/opt/homebrew/Cellar';
    $re->{'FON'} = '/opt/homebrew/Library/Taps/homebrew/homebrew-cask-fonts';
     $re->{'COM'} = '/opt/homebrew/share/zsh/site-functions';
   unless( $ARGV[0] ){
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
    $re->{'COM'} = '/home/linuxbrew/.linuxbrew/share/zsh/site-functions';
     $OS_Version2 = $UNAME =~ /x86_64/ ? 'Linux' : 'LinuxM1';
 Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula',0,0 );
  Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Aliases',0,0 );
   Dirs_1( '/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps',1,0 );
}

sub Dirs_1{
my( $dir,$ls,$cask ) = @_;
 for(glob "$dir/*"){
  next if $ls and m[/homebrew$|/homebrew-core$|/homebrew-cask$|/homebrew-bundle$|/homebrew-services$];
   ( -d ) ? Dirs_1( $_,$ls,$cask ) : ( -l ) ? push @{$re->{'ALIA'}},$_ :
   ( /\.rb$/ and $cask ) ? push @CASK,$_ : ( /\.rb$/ ) ? push @BREW,$_ : 0;
 }
}

 my $DBM = $ARGV[0] ? 'DBM' : 'DBMG';
tie my %tap,'NDBM_File',"$ENV{'HOME'}/.BREW_LIST/$DBM",O_RDWR|O_CREAT,0666 or die " tie DBM $!\n";
unless( $ARGV[0] ){
 for my $alias(@{$re->{'ALIA'}}){
  my $hand = readlink $alias;
  $alias =~ s|.+/(.+)|$1|;
   $hand =~ s|.+/(.+)\.rb|$1|;
  $tap{"${alias}alia"} = $hand;
 } my( $in,$e ) = int @BREW/4;
 for my $dir1(@BREW){ my $bot;
  if( $re->{'MAC'} ){ $e++;
   $e == $in ? rmdir "$ENV{'HOME'}/.BREW_LIST/14" :
   $e == $in*2 ? rmdir "$ENV{'HOME'}/.BREW_LIST/15" :
   $e == $in*3 ? rmdir "$ENV{'HOME'}/.BREW_LIST/16" : 0;
  }
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb|;
   $tap{"${name}core"} = $dir1;
  open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
   while(my $data=<$BREW>){
     if( $data =~ /^\s*bottle\s+do/ ){
      $KIN = $bot = 1; next;
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
   if( $data !~ /^\s*end/ and $IN ){ $SPA++ if $data =~ /\s+do$/; next;
   }elsif( $data =~ /^\s*end/ and $SPA > 1 and $IN ){ $SPA--; next;
   }elsif( $data =~ /^\s*end/ and $IN ){ $SPA = $IN = 0; next;
   }
    if( $re->{'MAC'} ){
      $SPA = $IN = 1, next if $data =~ /^\s*on_linux\s+do/;
    }else{
      $SPA = $IN = 1, next if $data =~ /^\s*on_macos\s+do/;
    }
     if( $data =~ /^\s*head\s+do/ ){ $SPA = $IN = 1; next;
     }elsif( $data =~ /^\s*on_intel\s+do/ and $UNAME =~ /arm64/ or
             $data =~ /^\s*on_arm\s+do/ and $UNAME =~ /x86_64/ ){ $SPA = $IN = 1; next;
     }elsif( my( $ha1,$ha2 ) = $data =~ /^\s*on_([^\s]+)\s+:or_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $re->{'LIN'} or eval "$MAC_OS{$ha1} $HAN{$ha2} $OS_Version"; next;
     }elsif( my( $ha3,$ha4 ) = $data =~ /^\s+on_system\s+:linux,\s+macos:\s+:(.+)_or_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $re->{'MAC'} and eval "$MAC_OS{$ha3} $HAN{$ha4} $OS_Version"; next;
     }

      if( my( $ls1,$ls2 ) =
        $data =~ /^\s*depends_on\s+xcode:.+if\s+MacOS::CLT\.version\s+([^\s]+)\s+"([\d.]+)"/ ){
         if( $re->{'MAC'} and not $Xcode and $ls1 =~ /^[<=>]+$/ and eval "$re->{'CLT'} $ls1 $ls2" ){
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
     }elsif( $re->{'MAC'} and my( $ds,$ds1,$ds2,$ds3 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+:build.+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+).+CPU\.([^\s]+)/ ){
        if( $ds1 =~ /^[<=>]+$/ and eval "$re->{'CLANG'} $ds1 $ds2" and $CPU eq $ds3 ){
         $tap{"${ds}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds\t";
        }
     }elsif( $re->{'MAC'} and my( $ds4,$ds5,$ds6 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
        if( $ds5 =~ /^[<=>]+$/ and eval "$re->{'CLANG'} $ds5 $ds6" ){
         $tap{"${ds4}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds4\t";
        }
     }elsif( $re->{'MAC'} and my( $ds7,$ds8,$ds9 ) =
       $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
        if( $ds8 =~ /^[<=>]+$/ and eval "$re->{'CLANG'} $ds8 $ds9" ){
         $tap{"${ds7}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$ds7\t";
        }
     }elsif( $re->{'MAC'} and $data =~ s/^\s*depends_on\s+"([^"]+)".+MacOS\.version\.outdated_release\?\n/$1/ ){
       push @{$re->{'OS'}},"$name,$data";
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
       $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
        $tap{"${name}deps_b"} .= "$data\t";
     }elsif( my( $us1,$us2 ) =
       $data =~ /^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build,\s+since:\s+:([^\s]+)/ ){
        if( $re->{'LIN'} or $OS_Version < $MAC_OS{$us2} ){
         $tap{"${us1}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$us1\t";
        }
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
        $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         $tap{"${name}deps_b"} .= "$data\t";
     }elsif( my( $us3,$us4 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+)/ ){
       if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$us4} ){
        $tap{"${us3}uses"} .= "$name\t";
         $tap{"${name}deps"} .= "$us3\t";
       }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
     }elsif( $re->{'LIN'} and
             my( $us5,$us6 ) = $data =~ /^\s*depends_on\s+"([^"]+)".+OS::Linux[^\s]+\s+([^\s]+)/ ){
      if( $us6 =~ /^[<=>]+$/ and eval "$RPM $us6 $CAT" ){
       $tap{"${us5}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$us5\t";
      }
     }elsif( $re->{'LIN'} and
             my( $us7 ) = $data =~ /^\s*depends_on\s+"([^"]+)".*\["glibc"]\.any_version_installed/ ){
      if( `which /home/linuxbrew/.linuxbrew/bin/glibc 2>/dev/null` ){
       $tap{"${us7}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$us7\t";
      }
     }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)".*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
         push @{$re->{'OS'}},"$name,$data,1";
     }

      if( not $bot and $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_version"} = $data;
      }elsif( not $bot and $data =~ s/^\s*desc\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_desc"} = $data;
      }elsif( not $bot and $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}f_name"} = $data;
      }elsif( not $bot and $data =~ s/^\s*revision\s+(\d+).*\n/$1/ ){
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
    }elsif( my( $cs1,$cs2,$cs3 ) =
           $data =~ /^\s*depends_on\s+macos:\s+:([^\s]*)\s+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
     $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and
      $cs2 =~ /^[<=>]+$/ and eval "$re->{'CLANG'} $cs2 $cs3" and $MAC_OS{$cs1} > $OS_Version;
       $tap{"${name}USE_OS"} = $cs1;
    }elsif( $data =~ s/^\s*depends_on\s+macos:\s+:([^\s]*).*\n/$1/ ){
      $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and $OS_Version and $MAC_OS{$data} > $OS_Version;
       $tap{"${name}USE_OS"} = $data;
    }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[?:([^,\s]+).*\n/$1/ ){
      $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and $OS_Version and $MAC_OS{$data} < $OS_Version;
    }
   }
  close $BREW;
 }
 if( $re->{'MAC'} ){ my %HA;
  rmdir "$ENV{'HOME'}/.BREW_LIST/17";
  for(@{$re->{'OS'}}){
   my( $name,$data,$ls ) = split ',';
   if( not $ls and $MAC_OS{$tap{"${data}USE_OS"}} <= $OS_Version ){
    $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
     $tap{"${name}deps_b"} .= "$data\t";
   }elsif( $ls and $tap{"${data}USE_OS"} and $MAC_OS{$tap{"${data}USE_OS"}} > $OS_Version ){
    Uses_1( $name,\%HA );
   }
  }
 }
 sub Uses_1{
 my( $name,$HA ) = @_;
  for my $ls(split '\t',$name){
   $HA->{$ls}++;
   if( $HA->{$ls} < 2 ){
    $tap{"$ls$OS_Version2"} = 0 if $tap{"$ls$OS_Version2"};
     $tap{"${ls}un_xcode"} = 1;
   }
   Uses_1( $tap{"${ls}uses"},$HA ) if $tap{"${ls}uses"}
  }
 }
 sub Glob_1{
 my( $brew,$mine,$loop,$in ) = @_;
  my @GLOB = $brew ? glob "$re->{'CEL'}/$brew/*" : glob "$re->{'CEL'}/*/*";
  for(@GLOB){ my($name) = m|$re->{'CEL'}/([^/]+)/.*|;
   if( -f "$_/INSTALL_RECEIPT.json" ){
    open my $CEL,'<',"$_/INSTALL_RECEIPT.json" or die " GLOB $!\n";
     while(<$CEL>){
      unless( /\n/ or /^}$/ ){
       s/.+"runtime_dependencies":\[([^]]*)].+/$1/;
       my @HE = /{"full_name":"([^"]+)","version":"[^"]+"}/g;
       for my $ls1(@HE){ my %HA;
        if( $tap{"${ls1}uses"} ){
         for(split '\t',$tap{"${ls1}uses"}){ $HA{$_}++; }
        }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls1 eq $mine;
         }else{ next unless Glob_1( $ls1,$name,1 );
          $tap{"${ls1}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls1\t";
         }
        }
       }
      }else{ my %HA;
       if( /runtime_dependencies/ or $in ){ $in = /]/ ? 0 : 1;
        my( $ls2 ) = /"full_name":\s*"([^"]+)".*/ ? $1 : next;
        if( $tap{"${ls2}uses"} ){
         for(split '\t',$tap{"${ls2}uses"}){ $HA{$_}++; }
        }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls2 eq $mine;
         }else{ next unless Glob_1( $ls2,$name,1 );
          $tap{"${ls2}uses"} .= "$name\t";
          $tap{"${name}deps"} .= "$ls2\t";
         }
        }
       }
      }
     }
    close $CEL;
   }
  }1;
 } Glob_1;
 if( $RPM and Version_1( $RPM,$CAT ) ){
  $tap{'glibcun_Linux'} = 1;
   $tap{'glibcLinux'} = 0;
 }
}

sub Version_1{
 my @ls1 = split '\.|-|_',$_[0];
 $_[1] ? my @ls2 = split '\.|-|_',$_[1] : return 1;
 my $i = 0;
  for(;$i<@ls2;$i++){
   if( $ls1[$i] and $ls2[$i] =~ /[^\d]/ ){
     if( $ls1[$i] gt $ls2[$i] ){ return 1;
     }elsif( $ls1[$i] lt $ls2[$i] ){ return;
     }
   }else{
     if( $ls1[$i] and $ls1[$i] > $ls2[$i] ){ return 1;
     }elsif( $ls1[$i] and $ls1[$i] < $ls2[$i] ){ return;
     }
   }
  }
 $ls1[$i] ? 1 : 0;
}
  my( $FON,$TIN,$UAA );
 if( $re->{'MAC'} ){
 rmdir "$ENV{'HOME'}/.BREW_LIST/18";
 my( $IN,$in,$e ) = ( 0,int @CASK/2,0 ); $tap{'fontlist'} = '';
  for my $dir2(@CASK){ my $ver;
   rmdir "$ENV{'HOME'}/.BREW_LIST/19" if $in == $e++;
   my( $name ) = $dir2 =~ m|.+/(.+)\.rb|;
    $tap{"${name}cask"} = $dir2;
     my( $IF1,$IF2,$ELIF,$ELS,$FI ) = ( 1,0,0,0,1 );
    $tap{"${name}d_cask"} = $tap{"${name}formula"} = '';
   open my $BREW,'<',$dir2 or die " tie Info_2 $!\n";
    while(my $data=<$BREW>){
     if( $name =~ /^font-/ and $FI ){
      $ver = $1 if $data =~ /^\s*version\s+"([^"]+)"/;
      ( $tap{"${name}font"} ) = $data =~ /^\s*url\s+"(.+(?:ttf|otf|dfont))"/;
       if( $tap{"${name}font"} ){
        $tap{"${name}font"} =~ s/\Q#{version}\E/$ver/g;
         $tap{'fontlist'} .= "$name\t";
          $FON .= "$name \\\n" if -d $re->{'FON'}; $FI = 0;
       }
     }
     if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ ){
       $tap{"${name}un_cask"} = 1 unless $ls1 !~ /^[<=>]+$/ or eval "$OS_Version $ls1 $MAC_OS{$ls2}";
     }elsif( $data =~ s/^\s*depends_on\s+formula:\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}formula"} .= "$data\t";
        $tap{"${data}u_form"} .= "$name\t";
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
  $TIN .= "$BREW[$i] \\\n" if $tap{"${BREW[$i]}deps"};
  $UAA .= "$BREW[$i] \\\n" if $tap{"${BREW[$i]}uses"};
   for(;$COU<@LIST;$COU++){
    my( $ls1,$ls2,$ls3 ) = split '\t',$LIST[$COU];
     $tap{"${BREW[$i]}ver"} = $tap{"${BREW[$i]}f_version"}, last if $BREW[$i] lt $ls1;
      if( $BREW[$i] eq $ls1 ){
       $tap{"${BREW[$i]}ver"} = Version_1( $ls2,$tap{"${BREW[$i]}f_version"} ) ? $ls2 : $tap{"${BREW[$i]}f_version"};
       $tap{"${BREW[$i]}ver"} = $tap{"${BREW[$i]}ver"}.$tap{"${BREW[$i]}revision"} if $tap{"${BREW[$i]}revision"};
       $COU++; last;
      }
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
 } my( $COM,@TRE,%HAU,$ls );
  for my $br(glob "$re->{'CEL'}/*"){
   $br =~ s|.+/(.+)|$1|;
   if( $tap{"${br}deps"} ){ push @TRE,$br;
    $HAU{$_}++ for(split '\t',$tap{"${br}deps"});
   } $COM .= "$br \\\n";
  }
 if( $re->{'MAC'} ){
  for(@CASK){
   $TIN .= "$_ \\\n" if $tap{"${_}formula"} or $tap{"${_}d_cask"};
   $UAA .= "$_ \\\n" if $tap{"${_}u_cask"} or  $tap{"${_}u_form"};
  }
   my $glob = $UNAME eq 'x86_64' ? '/usr/local/Caskroom' : '/opt/homebrew/Caskroom';
  for my $gs(glob "$glob/*"){
   $gs =~ s|.+/(.+)|$1|;
   if( $tap{"${gs}d_cask"} ){ $ls = push @TRE,$gs;
     $HAU{$_}++ for(split '\t',$tap{"${gs}d_cask"});
   }
   if( $tap{"${gs}formula"} ){ push @TRE,$gs unless $ls;
     $HAU{$_}++ for(split '\t',$tap{"${gs}formula"});
   }
  }
 } my( $UCC,$TRE );
  $TRE .= $HAU{$_} ? '' : "$_ \\\n" for(@TRE);
  $TRE =~ s/([^?]+)\\\n$/{-d,-dd,-de}':Delete:( \\\n$1 )' \\\n/;
   $UCC .= "$_ \\\n" for(sort keys %HAU);
    $UCC =~ s/([^?]+)\\\n$/'-u:uses:( \\\n$1 )' \\\n/;
  $TIN =~ s/([^?]+)\\\n$/{-t,-tt,-in}':Depends:( \\\n$1 )' \\\n/;
   $FON =~ s/([^?]+)\\\n$/'-p:Fonts:( \\\n$1 )' \\\n/ if $FON;
    $COM =~ s/([^?]+)\\\n$/'-co:Library:( \\\n$1 )' \\\n/;
     $UAA =~ s/([^?]+)\\\n$/'-ua:USES:( \\\n$1 )' \\\n/;
  my $TOP = $FON ? "#compdef bl\n_bl(){\n_arguments '*::' \\\n$TRE$TIN$UAA$UCC$COM$FON}" :
                   "#compdef bl\n_bl(){\n_arguments '*::' \\\n$TRE$TIN$UAA$UCC$COM}";
   no warnings 'closed';
  open my $dir,'>',"$re->{'COM'}/_bl";
   print $dir $TOP;
  close $dir;
}
untie %tap;
