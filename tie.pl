use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my( $re,$OS_Version,$OS_Version2,%MAC_OS,%HAN,$Xcode,@BREW,@CASK );
my $UNAME = `uname -m` !~ /arm64|aarch64/ ? 'x86_64' : 'arm64';
my $MY_BREW = $ENV{'Perl_B'} || `CO=\$(command -v brew);printf \${CO%/bin/brew}`;
my $MY_HOME = -d "$MY_BREW/Homebrew" ? "$MY_BREW/Homebrew" : $MY_BREW;

if( $^O eq 'darwin' ){ $re->{'MAC'} = 1;
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/^(10\.1[1-5]).*\n/$1/;
   $OS_Version =~ s/^(1[1-4]).+\n/$1.0/;
 $OS_Version2 = $UNAME eq 'arm64' ? "${OS_Version}M1" : $OS_Version;

 unless( $ARGV[0] ){
  $Xcode = `CC=\$(xcode-select -p);cat \${CC%/*}/version.plist 2>/dev/null|
            sed -nE '/ShortVersionString/{n;s/[^0-9]+([0-9.]+).+/\\1/;s/^([1-9]\\.)/0\\1/;p;}'`||0;
  $re->{'CLANG'} = `/usr/bin/clang --version|sed -E '/Apple/!d;s/.+clang-([^.]+).+/\\1/'` || 0;
 }
  %MAC_OS = ('sonoma'=>'14.0','ventura'=>'13.0','monterey'=>'12.0','big_sur'=>'11.0','catalina'=>'10.15',
             'mojave'=>'10.14','high_sierra'=>'10.13','sierra'=>'10.12','el_capitan'=>'10.11');
     %HAN = ('newer'=>'>','older'=>'<');
  $re->{'FON'} = "$MY_HOME/Library/Taps/homebrew/homebrew-cask-fonts";
   $re->{'COM'} = "$MY_BREW/share/zsh/site-functions";
    $re->{'CEL'} = "$MY_BREW/Cellar";
  unless( $ARGV[0] ){
   Dirs_1( "$MY_HOME/Library/Taps/homebrew/homebrew-cask/Casks",0,1 )
   if -d "$MY_HOME/Library/Taps/homebrew/homebrew-cask/Casks";
    Dirs_1( "$MY_HOME/Library/Taps/homebrew/homebrew-core/Formula",0,0 );
     Dirs_1( "$MY_HOME/Library/Taps/homebrew/homebrew-core/Aliases",0,0 );
      Dirs_1( "$MY_HOME/Library/Taps",1,0 );
  }
   Dirs_1( "$MY_HOME/Library/Taps/homebrew",1,1 );
 rmdir "$ENV{'HOME'}/.BREW_LIST/11";
}else{ $re->{'LIN'} = 1;
 $re->{'CEL'} = "$MY_BREW/Cellar";
  $re->{'COM'} = "$MY_BREW/share/zsh/site-functions";
   $OS_Version2 = $UNAME eq 'x86_64' ? 'Linux' : 'Linux_arm';
 Dirs_1( "$MY_HOME/Library/Taps/homebrew/homebrew-core/Formula",0,0 );
  Dirs_1( "$MY_HOME/Library/Taps/homebrew/homebrew-core/Aliases",0,0 );
   Dirs_1( "$MY_HOME/Library/Taps",1,0 );
    Dirs_1( "$MY_HOME/Library/Taps/homebrew",1,1 );
}

sub Dirs_1{
my( $dir,$ls,$cask,$HA ) = @_;
 opendir my $DIR,$dir or die " DIR $!\n";
  for my $an(sort readdir $DIR){ next if index($an,'.') == 0;
   $HA->{$an}++ if not $cask and $an =~ /\.rb$/;
    next if $ls and $an =~ /homebrew$|homebrew-core$|homebrew-cask$|homebrew-bundle$|homebrew-services$/ or
                    $HA->{$an} and $HA->{$an} > 1;
   ( -d "$dir/$an" ) ? Dirs_1( "$dir/$an",$ls,$cask,$HA ) : ( -l "$dir/$an" ) ? push @{$re->{'ALIA'}},"$dir/$an" :
   ( $cask and $an =~ /\.rb$/ ) ? push @CASK,"$dir/$an" : ( $an =~ /\.rb$/ ) ? push @BREW,"$dir/$an" : 0;
  }
 closedir $DIR;
}

 my $DBM = $ARGV[0] ? 'DBM' : 'DBMG';
tie my %tap,'NDBM_File',"$ENV{'HOME'}/.BREW_LIST/$DBM",O_RDWR|O_CREAT,0666 or die " tie DBM $!\n";
unless( $ARGV[0] ){
 for my $alias(@{$re->{'ALIA'}}){
  my $hand = readlink $alias;
  $alias =~ s|.+/(.+)|$1|;
   $hand =~ s|.+/(.+)\.rb$|$1|;
  $tap{"${alias}alia"} = $hand;
  $tap{"${hand}alias"} .= "$alias\t";
 } $tap{'pythonalia'} = 'python@3.11' if $re->{'LIN'};
  my( $in,$e ) = @BREW >> 2;
   my @in = ( $in << 1,($in << 1) + $in );
    my( $IN,$KIN,$SPA ) = ( 0,0,0 );
 for my $dir1(@BREW){ my( $bot,@an );
  if( $re->{'MAC'} ){ $e++;
   $e == $in ? rmdir "$ENV{'HOME'}/.BREW_LIST/12" :
   $e == $in[0] ? rmdir "$ENV{'HOME'}/.BREW_LIST/13" :
   $e == $in[1] ? rmdir "$ENV{'HOME'}/.BREW_LIST/14" : 0;
  }
  my( $name ) = $dir1 =~ m|.+/(.+)\.rb$|;
   $tap{"${name}core"} = $dir1;
  open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
   while(my $data=<$BREW>){ last if $data =~ /^\s*def\s+install/;
     if( $data =~ /^\s*bottle\s+do/ ){
      $KIN = $bot = 1; next;
     }elsif( $data =~ /^\s*rebuild/ and $KIN == 1 ){
       next;
     }elsif( $data !~ /^\s*end/ and $KIN == 1 ){
       if( $data =~ /.*,\s+all:/ ){
        $tap{"${name}14.0M1"}= $tap{"${name}14.0"}  = $tap{"${name}13.0M1"}=
        $tap{"${name}13.0"}  = $tap{"${name}12.0M1"}= $tap{"${name}12.0"}  =
        $tap{"${name}11.0M1"}= $tap{"${name}11.0"}  = $tap{"${name}10.15"} =
        $tap{"${name}10.14"} = $tap{"${name}10.13"} = $tap{"${name}10.12"} =
        $tap{"${name}10.11"} = $tap{"${name}Linux"} = 1;
       }
        if( $re->{'LIN'} ){
           $data =~ s/.*x86_64_linux:.*\n/Linux/ ? $tap{"$name$data"} = 1 : next;
        }else{
         if( not $an[0] and $data =~ s/.*arm64_sonoma:.*\n/14.0M1/ ){
           $tap{"$name$data"} = $an[0] = 1; next;
         }elsif( not $an[1] and $data =~ s/.*arm64_ventura:.*\n/13.0M1/ ){
           $tap{"$name$data"} = $an[1] = 1; next;
         }elsif( not $an[2] and $data =~ s/.*arm64_monterey:.*\n/12.0M1/ ){
           $tap{"$name$data"} = $an[2] = 1; next;
         }elsif( not $an[3] and $data =~ s/.*arm64_big_sur:.*\n/11.0M1/ ){
           $tap{"$name$data"} = $an[3] = 1; next;
         }elsif( not $an[4] and $data =~ s/.*sonoma:.*\n/14.0/ ){
           $tap{"$name$data"} = $an[4] = 1; next;
         }elsif( not $an[5] and $data =~ s/.*ventura:.*\n/13.0/ ){
           $tap{"$name$data"} = $an[5] = 1; next;
         }elsif( not $an[6] and $data =~ s/.*monterey:.*\n/12.0/ ){
           $tap{"$name$data"} = $an[6] = 1; next;
         }elsif( not $an[7] and $data =~ s/.*big_sur:.*\n/11.0/ ){
           $tap{"$name$data"} = $an[7] = 1; next;
         }elsif( not $an[8] and $data =~ s/.*catalina:.*\n/10.15/ ){
           $tap{"$name$data"} = $an[8] = 1; next;
         }elsif( not $an[9] and $data =~ s/.*mojave:.*\n/10.14/ ){
           $tap{"$name$data"} = $an[9] = 1; next;
         }elsif( not $an[10] and $data =~ s/.*high_sierra:.*\n/10.13/ ){
           $tap{"$name$data"} = $an[10] = 1; next;
         }elsif( not $an[11] and $data =~ s/.*sierra:.*\n/10.12/ ){
           $tap{"$name$data"} = $an[11] = 1; next;
         }elsif( not $an[12] and $data =~ s/.*el_capitan:.*\n/10.11/ ){
           $tap{"$name$data"} = $an[12] = 1; next;
         }else{ next }
        }
       next;
     }elsif( $data =~ /^\s*end/ and $KIN == 1 ){
      $KIN = 0; next;
     }
   if( $data !~ /^\s*end/ and $IN ){ $SPA++ if $data =~ /\s+do\s/; next;
   }elsif( $data =~ /^\s*end/ and $SPA > 1 ){ $SPA--; next;
   }elsif( $data =~ /^\s*end/ and $IN ){ $SPA = $IN = 0; next;
   }
    if( $re->{'MAC'} ){
      $SPA = $IN = 1, next if $data =~ /^\s*on_linux\s+do/;
    }else{
      $SPA = $IN = 1, next if $data =~ /^\s*on_macos\s+do/;
    }
     if( $data =~ /^\s*head\s+do/ ){ $SPA = $IN = 1; next;
     }elsif( $data =~ /^\s*on_intel\s+do/ and $UNAME eq 'arm64' or
             $data =~ /^\s*on_arm\s+do/ and $UNAME eq 'x86_64' ){ $SPA = $IN = 1; next;
     }elsif( my( $ha1,$ha2 ) = $data =~ /^\s*on_([^\s]+)\s+:or_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $re->{'LIN'} or eval "$MAC_OS{$ha1} $HAN{$ha2} $OS_Version"; next;
     }elsif( my( $ha3,$ha4 ) = $data =~ /^\s*on_system\s+:linux,\s+macos:\s+:(.+)_or_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $re->{'MAC'} and eval "$MAC_OS{$ha3} $HAN{$ha4} $OS_Version"; next;
     }elsif( my( $ha5 ) = $data =~ /^\s*on_([^\s]+)\s+do/ ){
         $SPA = $IN = 1 if $MAC_OS{$ha5} and $MAC_OS{$ha5} ne $OS_Version; next;
     }

      if( $data =~ s/^\s*depends_on\s+xcode:.+"([^"]+)",\s+:build.*\n/$1/ ){
          $data = "0$data" if index($data,'.') == 1;
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
          $data = "0$data" if index($data,'.') == 1;
         if( $re->{'MAC'} and $data gt $Xcode ){
           $tap{"${name}un_xcode"} = 1;
            $tap{"$name$OS_Version2"} = 0;
         }elsif( $re->{'LIN'} ){
           $tap{"${name}un_Linux"} = 1;
            $tap{"${name}Linux"} = 0; # bottle #
         } next;
      }elsif( $data =~ s/\s*depends_on\s+arch:\s+:([^\s]+).*\n/$1/ and $UNAME ne $data ){
          $tap{"${name}un_xcode"} = $tap{"${name}un_Linux"} =1;
          $tap{"$name$OS_Version2"} = $tap{"${name}Linux"} = 0;
           next;
      }

     if( $data =~ /^\s*depends_on\s+"[^"]+"\s*=>\s+:test/ ){
         next;
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
          push @{$re->{'OS'}},"$name,$data,1" unless $tap{"$name$OS_Version2"};
     }elsif( my( $us3,$us4 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+)/ ){
       if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $MAC_OS{$us4} ){
        $tap{"${us3}uses"} .= "$name\t";
         $tap{"${name}deps"} .= "$us3\t";
       }
     }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"(?!.+:test).*\n/$1/ ){
       $tap{"${data}uses"} .= "$name\t";
        $tap{"${name}deps"} .= "$data\t";
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
  rmdir "$ENV{'HOME'}/.BREW_LIST/15";
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
   Uses_1( $tap{"${ls}uses"},$HA ) if $tap{"${ls}uses"};
  }
 }

 sub Glob_1{
 my( $brew,$mine,$loop ) = @_;
  my @GLOB = $brew ? glob "$re->{'CEL'}/$brew/*" : glob "$re->{'CEL'}/*/*";
  for my $glob(@GLOB){ my($name) = $glob =~ m|$re->{'CEL'}/([^/]+)/.*|;
   if( -f "$glob/INSTALL_RECEIPT.json" ){ my $in;
    open my $CEL,'<',"$glob/INSTALL_RECEIPT.json" or die " GLOB $!\n";
     while(my $cel=<$CEL>){
      unless( $cel =~ /\n/ ){
       $cel =~ s/.+"runtime_dependencies":\[([^]]*)].+/$1/;
       my @HE = $cel =~ /{"full_name":"([^"]+)","version":"[^"]+"}/g;
       for my $ls1(@HE){ my( %HA,%AL,$ne );
        if( $tap{"${ls1}uses"} ){ $HA{$_}++ for split '\t',$tap{"${ls1}uses"} }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls1 eq $mine;
         }else{ unless( $ls1 eq 'glibc' ){ next unless Glob_1( $ls1,$name,1 ); }
          if( $tap{"${ls1}alias"} and $tap{"${name}deps"} ){
           $AL{$_}++ for split '\t',$tap{"${ls1}alias"};
           $AL{$_} ? $ne++ : 0 for split '\t',$tap{"${name}deps"};
          } next if $ne;
          if( $re->{'LIN'} and $ls1 ne 'linux-headers@5.15' ){
           $tap{"${ls1}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls1\t";
          }elsif( $re->{'MAC'} ){
           $tap{"${ls1}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls1\t";
          }
         }
        }
       }
      }else{ my( %HA,%AL,$ne );
       if( $in or $cel =~ /runtime_dependencies/ ){ $in = $cel =~ /]/ ? last : 1;
        my( $ls2 ) = $cel =~ /"full_name":\s*"([^"]+)".*/ ? $1 : next;
        if( $tap{"${ls2}uses"} ){ $HA{$_}++ for split '\t',$tap{"${ls2}uses"} }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls2 eq $mine;
         }else{ unless( $ls2 eq 'glibc' ){ next unless Glob_1( $ls2,$name,1 ); }
          if( $tap{"${ls2}alias"} and $tap{"${name}deps"} ){
           $AL{$_}++ for split '\t',$tap{"${ls2}alias"};
           $AL{$_} ? $ne++ : 0 for split '\t',$tap{"${name}deps"};
          } next if $ne;
          if( $re->{'LIN'} and $ls2 ne 'linux-headers@5.15' ){
           $tap{"${ls2}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls2\t";
          }elsif( $re->{'MAC'} ){
           $tap{"${ls2}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls2\t";
          }
         }
        }
       }
      }
     }
    close $CEL;
   }
  }1;
 } Glob_1;
}

sub Version_1{
 my @ls1 = split '\.|-|_',$_[0];
 $_[1] ? my @ls2 = split '\.|-|_',$_[1] : return 1;
 my $i = 0;
  for(;$i<@ls2;$i++){
   if( $ls1[$i] and $ls2[$i] =~ /[^\d]+/ ){
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
  my $FON;
 if( $re->{'MAC'} ){
 rmdir "$ENV{'HOME'}/.BREW_LIST/16";
 my( $in,$e ) = ( @CASK >> 1,0 ); delete $tap{"fontlist"} if $ARGV[0];
 $UNAME = $UNAME eq 'x86_64' ? 'intel' : 'arm';
  for my $dir2(@CASK){ my $ver;
   rmdir "$ENV{'HOME'}/.BREW_LIST/17" if $in == $e++;
    my( $dirs,$name ) = $dir2 =~ m|.+/(homebrew-cask.*)/Casks/(?:[^/]+/)*(.+)\.rb$|;
     $tap{"${name}m_ver"} = 1 if $dirs eq 'homebrew-cask-versions';
      $tap{"${name}mfont"} = 1 if $dirs eq 'homebrew-cask-fonts';
       $tap{"${name}cask"} = $dir2;
    my( $SPA,$CN,$IN,$CP1,$CP2,$FI ) = ( 0,0,0,0,0,1 );
     delete $tap{"${name}d_cask"}, delete $tap{"${name}formula"} if $ARGV[0];
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
      if( my( $cpu ) = $data =~ /^\s*on_(intel|arm)\s+do/ ){ if( $cpu eq $UNAME ){ $CN = $SPA= 1;
                                                             }else{ $CP1 = $CP2 = 1 } next;
      }elsif( $data !~ /^\s*end/ and $CP1 ){ $CP2++ if $data =~ /\s+do\s/; next;
      }elsif( $data =~ /^\s*end/ and $CP2 > 1 ){ $CP2--; next;
      }elsif( $data =~ /^\s*end/ and $CP1 ){ $CP1 = $CP2 = 0; next;
      }
     if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ and not $CN ){
       $tap{"${name}un_cask"} = 1 unless $ls1 !~ /^[<=>]+$/ or eval "$OS_Version $ls1 $MAC_OS{$ls2}";
     }elsif( $data =~ s/^\s*depends_on\s+formula:\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}formula"} .= "$data\t";
        $tap{"${data}u_form"} .= "$name\t"
         if not $tap{"${data}u_form"} or $tap{"${data}u_form"} !~ /$name\t/;
     }elsif( $data =~ /^\s*depends_on\s+cask:\s+/ or $IN ){
      if( $data =~ /^\s*depends_on\s+cask:\s+\[/ ){ $IN = 1; next; }
       if( $data =~ /^\s*\]/ ){ $IN = 0; next; }
      $data =~ s/^\s*"([^"]+)".*\n/$1/;
       $data =~ s/^\s*depends_on\s+cask:\s+"([^"]+)".*\n/$1/;
        $tap{"${name}d_cask"} .= "$data\t";
         $data =~ s|.+/([^/]+)|$1|;
          $tap{"${data}u_cask"} .= "$name\t"
           if not $tap{"${data}u_cask"} or $tap{"${data}u_cask"} !~ /$name\t/;
     }elsif( my( $ha1,$ha2 ) = $data =~ /^\s*on_([^\s]+)\s+:or_([^\s]+)\s+do/ ){
       $SPA = $CN = not eval "$MAC_OS{$ha1} $HAN{$ha2} $OS_Version" ? 1 : 0;
        $CP1 = $CP2 = $CN ? 0 : 1; next;
     }elsif( my( $ha3 ) = $data =~ /^\s*on_([^\s]+)\s+do/ ){
       $SPA = $CN = $MAC_OS{$ha3} eq $OS_Version ? 1 : 0;
        $CP1 = $CP2 = $CN ? 0 : 1; next;
     }elsif( $data !~ /^\s*end/ and $CN ){ $SPA++ if $data =~ /\s+do\s/;
      $tap{"${name}c_version"} = $data if $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/;
       if( my( $ls3,$ls4 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ ){
        $tap{"${name}un_cask"} = 1 unless $ls3 !~ /^[<=>]+$/ or eval"$OS_Version $ls3 $MAC_OS{$ls4}";
       } next;
     }elsif( $data =~ /^\s*end/ and $SPA > 1 ){ $SPA--; next;
     }elsif( $data =~ /^\s*end/ and $CN ){ $SPA = $CN = 0; next;
     }elsif( $data =~ s/^\s*version\s+[":]([^"\s]+)"?.*\n/$1/ ){
       $tap{"${name}c_version"} = $data unless $tap{"${name}c_version"};
     }elsif( $data =~ s/^\s*desc\s+"(.+)".*\n/$1/ ){
       $data =~ tr/\\//d if index($data,'\\') > 0;
       $tap{"${name}c_desc"} = $data;
     }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_name"} = $data;
     }
    }
   close $BREW;
  }
 }else{
  for my $dir3(@CASK){
   my( $name ) = $dir3 =~ m|.+/(.+)\.rb|;
    $tap{"${name}cask"} = $dir3; $tap{"${name}lfont"} = 1;
   open my $BREW,'<',$dir3 or die " tie Info_3 $!\n";
    while(my $data=<$BREW>){
     if( $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_version"} = $data;
     }elsif( $data =~ s/^\s*desc\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_desc"} = $data;
     }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
       $tap{"${name}c_name"} = $data;
     }
    }
   close $BREW;
  }
 }
 rmdir "$ENV{'HOME'}/.BREW_LIST/18";

unless( $ARGV[0] ){
 open my $FILE,'<',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE $!\n";
  my @LIST = <$FILE>;
 close $FILE;

   my( $TIN,$UAA,$AIA,$ACA,$BUI );
  @BREW = sort grep{ s|.+/(.+)\.rb|$1| }@BREW;
 if( $re->{'MAC'} ){
  for(@CASK){
   last unless m|$MY_HOME/Library/Taps/homebrew/homebrew-cask/Casks/|o;
    my( $name ) = m|.+/(.+)\.rb|;
     $ACA .= "$name \\\n";
  }
  @CASK = sort grep{ s|.+/(.+)\.rb|$1| }@CASK;
 }

  my( $COU,$IN ) = ( 0,0 );
 for(my $i=0;$i<@BREW;$i++){
  $TIN .= "$BREW[$i] \\\n" if $tap{"$BREW[$i]deps"} or $tap{"$BREW[$i]deps_b"} and not $tap{"$BREW[$i]$OS_Version2"};
  $UAA .= "$BREW[$i] \\\n" if $tap{"$BREW[$i]uses"};
  $AIA .= "$BREW[$i] \\\n";
   if( $tap{"$BREW[$i]build"} ){
    for my $b1( split '\t',$tap{"$BREW[$i]build"} ){
     $BUI .= "$BREW[$i] \\\n",last if not $tap{"${b1}$OS_Version2"} and
      ( $re->{'MAC'} and not $tap{"${b1}un_xcode"} or $re->{'LIN'} and not $tap{"${b1}un_Linux"} );
    }
   }
   for(;$COU<@LIST;$COU++){
    my( $ls1,$ls2,$ls3 ) = split '\t',$LIST[$COU];
     $tap{"$BREW[$i]ver"} = $tap{"$BREW[$i]f_version"}, last if $BREW[$i] lt $ls1;
      if( $BREW[$i] eq $ls1 ){
       $tap{"$BREW[$i]ver"} = Version_1( $ls2,$tap{"$BREW[$i]f_version"} ) ? $ls2 : $tap{"$BREW[$i]f_version"};
       $tap{"$BREW[$i]ver"} = $tap{"$BREW[$i]ver"}.$tap{"$BREW[$i]revision"} if $re->{'MAC'} and $tap{"$BREW[$i]revision"};
       $COU++; last;
      }
   }
   if( $re->{'MAC'} ){
     for(;$IN<@CASK;$IN++){
      last if $BREW[$i] lt $CASK[$IN];
       if($BREW[$i] eq $CASK[$IN]){
        $tap{"$CASK[$IN]so_name"} = 1;
        $IN++; last;
       }
     }
   }
 } my( $COM,$DEP,@TRE,%HAU );
  for my $br(glob "$re->{'CEL'}/*"){
   $br =~ s|.+/(.+)|$1|;
   if( $tap{"${br}deps"} ){ push @TRE,$br;
    $HAU{$_}++ for split '\t',$tap{"${br}deps"};
     $DEP .= "$br \\\n";
   } $COM .= "$br \\\n";
  }
 if( $re->{'MAC'} ){
  for my $ca(@CASK){
   $TIN .= "$ca \\\n" if $tap{"${ca}formula"} or $tap{"${ca}d_cask"};
   $UAA .= "$ca \\\n" if $tap{"${ca}u_cask"} or  $tap{"${ca}u_form"};
  }
  for my $gs(glob "$MY_BREW/Caskroom/*"){ my $ls;
   $gs =~ s|.+/(.+)|$1|;
   if( $tap{"${gs}d_cask"} ){
    $HAU{$_}++ for split '\t',$tap{"${gs}d_cask"};
     $ls = push @TRE,$gs;
      $DEP .= "$gs \\\n";
   }
   if( $tap{"${gs}formula"} ){
    $HAU{$_}++ for split '\t',$tap{"${gs}formula"};
     push @TRE,$gs unless $ls;
      $DEP .= "$gs \\\n";
   }
  }
 } my( $UCC,$TRE );
  $TRE .= $HAU{$_} ? '' : "$_ \\\n" for @TRE;
   $UCC .= "$_ \\\n" for sort keys %HAU;
    $TRE = ( $TRE and $TRE =~ s/(.+)\\\n$/{-d,-dd,-de}'[Delete item]:Delete:( \\\n$1 )' \\\n/s ) ? $TRE : '';
     $UCC = ( $UCC and $UCC =~ s/(.+)\\\n$/{-u,-ul}'[Uses list]:uses:( \\\n$1 )' \\\n/s )        ? $UCC : '';
      $AIA = ( $AIA and $AIA =~ s/(.+)\\\n$/'-ai[Formula Analytics]:Formula:( \\\n$1 )' \\\n/s ) ? $AIA : '';
       $ACA = ( $ACA and $ACA =~ s/(.+)\\\n$/'-ac[Cask Analytics]:Casks:( \\\n$1 )' \\\n/s )     ? $ACA : '';
  $TIN = ( $TIN and $TIN =~ s/(.+)\\\n$/{-t,-tt,-in}'[Depends item]:Depends:( \\\n$1 )' \\\n/s ) ? $TIN : '';
   $FON = ( $FON and $FON =~ s/(.+)\\\n$/'-p[Fonts list]:Fonts:( \\\n$1 )' \\\n/s )              ? $FON : '';
    $COM = ( $COM and $COM =~ s/(.+)\\\n$/{-co,-is}'[Library list]:Library:( \\\n$1 )' \\\n/s )  ? $COM : '';
     $UAA = ( $UAA and $UAA =~ s/(.+)\\\n$/'-ua[All uses list]:USES:( \\\n$1 )' \\\n/s )         ? $UAA : '';
      $DEP = ( $DEP and $DEP =~ s/(.+)\\\n$/'-ud[Depends list]:DEPS:( \\\n$1 )' \\\n/s )         ? $DEP : '';
       $BUI = ( $BUI and $BUI =~ s/(.+)\\\n$/'-bu[Bulid list]:Build:( \\\n$1 )' \\\n/s )         ? $BUI : '';
  my $TOP = "#compdef bl\n_bl(){\n_arguments '*::' \\\n$TRE$TIN$UAA$UCC$COM$DEP$AIA$ACA$BUI$FON}";
   no warnings 'closed';
  open my $dir,'>',"$re->{'COM'}/_bl";
   print $dir $TOP;
  close $dir;
}
untie %tap;
