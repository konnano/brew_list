use strict;
use warnings;
use NDBM_File;
use Fcntl ':DEFAULT';

my( $re,$OS_Version,$OS_Version2,%MAC_OS,%Mac_OS,$Xcode,%HAN,@BREW,@CASK,$NAM,$ACA,$FON,@FONT );
my $UNAME = `uname -m` !~ /arm64|aarch64/ ? 'x86_64' : 'arm64';
my $MY_BREW = $ENV{'Perl_B'}||`CO=\$(which brew);printf \${CO%/bin/brew} 2>/dev/null`||die" brew path not found\n";
my $MY_HOME = -d "$MY_BREW/Homebrew" ? "$MY_BREW/Homebrew" : $MY_BREW;

if( $^O eq 'darwin' ){ $re->{'MAC'} = 1;
 $OS_Version = `sw_vers -productVersion`;
  $OS_Version =~ s/^(10\.1[1-5]).*\n/$1/;
   $OS_Version =~ s/^(1[1-5]).+\n/$1.0/;
 $OS_Version2 = $UNAME eq 'arm64' ? "${OS_Version}M1" : $OS_Version;
 unless( $ARGV[0] ){
  $Xcode = `CC=\$(xcode-select -p);cat \${CC%/*}/version.plist 2>/dev/null|
            sed -nE '/ShortVersionString/{n;s/[^0-9]+([0-9.]+).+/\\1/;s/^([1-9]\\.)/0\\1/;p;}'`||0;
 }
  %MAC_OS = ('arm64_sequoia'=>'15.0M1','arm64_sonoma'=>'14.0M1','arm64_ventura'=>'13.0M1',
             'arm64_monterey'=>'12.0M1','arm64_big_sur'=>'11.0M1',
             'sequoia'=>'15.0','sonoma'=>'14.0','ventura'=>'13.0','monterey'=>'12.0',
             'big_sur'=>'11.0','catalina'=>'10.15','mojave'=>'10.14','high_sierra'=>'10.13',
             'sierra'=>'10.12','el_capitan'=>'10.11','all'=>'all');
  %Mac_OS = ('sequoia'=>'15.0','sonoma'=>'14.0','ventura'=>'13.0','monterey'=>'12.0','big_sur'=>'11.0',
             'catalina'=>'10.15','mojave'=>'10.14','high_sierra'=>'10.13','sierra'=>'10.12','el_capitan'=>'10.11');
}elsif( $^O eq 'linux' ){ $re->{'LIN'} = 1;
 $OS_Version2 = $UNAME eq 'x86_64' ? 'Linux' : 'Linux_arm';
}

 my $Cache = $re->{'MAC'} ? "$ENV{'HOME'}/Library/Caches/Homebrew" : "$ENV{'HOME'}/.cache/Homebrew";
 unless( $ARGV[0] or $ENV{'HOMEBREW_NO_INSTALL_FROM_API'} ){ rmdir "$ENV{'HOME'}/.BREW_LIST/11";
  mkdir "$ENV{'HOME'}/.BREW_LIST/parse";
  open my $J1,'<',"$Cache/api/formula.jws.json" or die" 1 brew cache $!\n";
   my $fo = <$J1>; close $J1; my $i;
   my @fo = split /[^\\]\\n/,$fo; $NAM = @fo >> 1;
    for( @fo ){  $i++; rmdir "$ENV{'HOME'}/.BREW_LIST/12" if $i == $NAM;
                tr/\\//d; my( $file ) = /"name":"([^"]+)"/;
                tr/[/\n/; tr/]/\n/; tr/{/\n/; tr/}/\n/; $file ||= '';
     open K,'>',"$ENV{'HOME'}/.BREW_LIST/parse/$file.txt" or die" 2 brew cache $!\n";
     print K $_; close K;
    }
  rmdir "$ENV{'HOME'}/.BREW_LIST/13";
 }

 my( $Time,%NA,$i )  = [localtime];
  my $TIME = sprintf "%04d-%02d-%02d",$Time->[5]+=1900,++$Time->[4],$Time->[3];
   my $DBM = $ARGV[0] ? 'DBM' : 'DBMG';
 tie my %tap,'NDBM_File',"$ENV{'HOME'}/.BREW_LIST/$DBM",O_RDWR|O_CREAT,0666 or die " tie DBM $!\n";
unless( $ENV{'HOMEBREW_NO_INSTALL_FROM_API'} ){
 unless( $ARGV[0] ){
  open my $K,'<',"$Cache/api/formula_aliases.txt" or die" 1 alias $!\n";
   while(<$K>){ chomp; my( $alias,$hand ) = split '\|';
    $tap{"${alias}alia"} = $hand;
    $tap{"${hand}alias"} .= "$alias\t";
   }
  close $K;
  opendir my $dir1,"$ENV{'HOME'}/.BREW_LIST/parse/" or die" 1 parse $!\n";
  for my $ls1(sort readdir $dir1){ next if index($ls1,'.') == 0;
   $i++; rmdir "$ENV{'HOME'}/.BREW_LIST/14" if $i == $NAM;
   my( $name,$u2,$b2,%HA1,%HA2,%LHA1,%LHA2,@ui,@ta,@lu,@sp ) = ( substr($ls1,0,-4),0 );
    for(0..11){ $ta[$_] = 1 } push @BREW,$name; $NA{$name}++;
     $tap{"${name}core"} = "$MY_HOME/Library/Taps/homebrew/homebrew-core/Formula/$name";
   open my $BREW,"$ENV{'HOME'}/.BREW_LIST/parse/$ls1" or die" 2 parse $!\n";
    while(my $data = <$BREW> ){
     unless( $ui[22] ){

       if( $ta[0] and $data =~ /^,"desc":"(.+)","license"/ ){ $tap{"${name}f_desc"} = $1; $ta[0] = 0 }
       if( $ta[1] and $data =~ /"versions":$/ ){ $ui[0] = 1; $ta[1] = 0; next }
       if( $ui[0] ){
        if( $data =~ /"stable":"([^"]+)"/ ){ $tap{"${name}f_version"} = $1 } $ui[0] = 0; next
       }

       if( $ta[2] and $data =~ /,"revision":(\d+),/ ){
           $tap{"${name}f_version"} = qq($tap{"${name}f_version"}_$1) if $1; $ta[2] = 0;
       }

       if( $ta[3] and $data =~ /"bottle":$/ ){ $ui[1] = 1; $ta[3] = 0; next }
       if( $ui[1] ){ $data =~ tr/,//d;
        $ui[2] = index($data,"\n") == 0 ? ++$ui[2] : 0; $data =~ s/"([^"]+)":\n/$1/;
         if( index($data,'all') == 0 or $MAC_OS{$data} and $MAC_OS{$data} eq $OS_Version2 or
             $re->{'LIN'} and $data eq 'x86_64_linux'){
              $tap{"${name}$OS_Version2"} = 1; $ui[1] = $ui[2] = 0; next;
         }
        $ui[1] = $ui[2] = 0 if $ui[2] > 1; next;
       }

       if( index($data,',"keg_only":true,') > 0 ){ $ui[3] = 1; next }
       if( $ui[3] ){
        if( $data =~ /":provided_by_macos"|":shadowed_by_macos"/ ){ $tap{"${name}pkeg"} = 1
                                                             }else{ $tap{"${name}keg"}  = 1 } $ui[3] = 0; next;
       }

       if( index($data,'"build_dependencies":') >= 0 ){ $ui[4] = 1; next }
       if( $ui[4] ){  chomp $data; $data =~ tr/"//d;
        for my $ls2(split ',',$data){ $LHA1{$ls2} = $HA1{$ls2} = 1; Bdep_1( $ls2,$name,1 );
        } $ui[4] = 0; next;
       }
       if( index($data,'"dependencies":') >= 0 ){ $ui[5] = 1; next }
       if( $ui[5] ){ chomp $data; $data =~ tr/"//d;
        for my $ls3(split ',',$data){ $LHA2{$ls3} = $HA2{$ls3} = 1; Depe_1( $ls3,$name,1 );
        } $ui[5] = 0; next;
       }

       if( index($data,'"uses_from_macos":') >= 0 ){ $ui[6] = 1; next }
       if( $ui[6] ){ if( index($data,"\n") == 0 ){ $ui[10] = 1; next }
                       chomp $data; $data =~ tr/"//d; $data =~ s/^,//;
       if( index($data,'uses_from_macos_bounds:') == 0 ){ $ui[7] = 1; $ui[6] = $ui[10] = 0; next }
        if( $data eq 'build,test' ){ $ui[23] = 1; next }
        my( $fom,$bui ) = split ':',$data if $ui[10] and substr($data,-1,1) ne ':';
         if( $bui and $bui eq 'build' or $ui[23] ){ $LHA1{$fom}++ if $fom;
          if( $re->{'LIN'} and $fom and $LHA1{$fom} < 2 ){ Bdep_1( $fom,$name ) }
         }elsif( $data =~ /(.+):$/ ){ $LHA1{$1}++;
          if( $re->{'LIN'} and $LHA1{$1} < 2 ){ Bdep_1( $1,$name ) }
         }elsif( index($data,',') > 0 ){ @sp = split ',',$data;
          for my $sp( @sp ){ $LHA2{$sp}++;
           if( $re->{'LIN'} and $LHA2{$sp} < 2 ){ Depe_1( $sp,$name ) }
          }
         }
         if( $ui[10] and index($data,',') > 0 ){ push @lu,@sp;;
         }elsif( $ui[10] and $bui and $bui eq 'build'){ push @lu,":$fom";
         }elsif( $ui[10] and $bui and $bui eq 'test'){ push @lu,"=$fom";
         }elsif( $ui[10] and $data =~ /(.+):$/ ){ push @lu,":$1";
         }elsif( not $ui[10] and index($data,',') > 0 ){ @lu = split ',',$data;
         }elsif( $data ){ push @lu,$data;
         } next;
       }

       if( $ui[7] and $re->{'MAC'} ){
        if( index($data,'"requirements":') >= 0 ){ $ui[7] = 0; next }
        if( index($data,'"variations":') >= 0 ){ $ui[7] = 0; $ui[22] = 1; next }
        if( index($data,"\n") == 0 ){ next }
        if( index($data,',') == 0 ){ $u2++; next }
         $data =~ s/^"since":"([^"]+)"\n/$1/;
         if( $Mac_OS{$data} and $Mac_OS{$data} > $OS_Version ){
          if( index($lu[$u2],':') == 0 and substr $lu[$u2],0,1,'' ){ $HA1{$lu[$u2]}++;
           unless( $HA1{$lu[$u2]} > 1 ){ Bdep_1( $lu[$u2],$name ) }
          }elsif( index($lu[$u2],'=') == 0 ){
          }else{ $HA2{$lu[$u2]}++;
           unless( $HA2{$lu[$u2]} > 1 ){ Depe_1( $lu[$u2],$name ) }
          }
         }
       }

       if( $ta[4] and $re->{'MAC'} and $data =~ /^"name":"xcode".+"version":null/ ){ $ui[8] = 1; $ta[4] = 0; next }
       if( $ui[8] ){
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[9] );
        if( $sp and $sp == 1 ){ $b2 ? Xcod_1( $name,1 ) : Xcod_1( $name );
          $ui[8] = $ui[9] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[8] = $ui[9] = $b2 = 0;
        } next;
       }

       if( $ta[5] and $re->{'MAC'} and $data =~ /^"name":"xcode".+"version":"([^"]+)"/ ){ $ui[10] = $1; $ta[5] = 0; next }
       if( $ui[10] ){ $ui[10] = "0$ui[10]" if index($ui[10],'.') == 1;
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[11] );
        if( $sp and $sp == 1 ){ $b2 ? Bxco_1( $name,$ui[10],1 ) : Bxco_1( $name,$ui[10] );
          $ui[10] = $ui[11] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[10] = $ui[11] = $b2 = 0;
        } next;
       }

       if( $ta[6] and $data =~ /^"name":"arch".+"version":"([^"]+)"/ and $1 ne $UNAME ){ $ui[12] = 1; $ta[6] = 0; next }
       if( $ui[12] ){
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[13] );
        if( $sp and $sp == 1 ){ $tap{"${name}un_xcode"} = $tap{"${name}un_Linux"} =1;
                                $tap{"$name$OS_Version2"} = $tap{"${name}Linux"} = 0;
          $ui[12] = $ui[13] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[12] = $ui[13] = $b2 = 0;
        } next;
       }

       if( $ta[7] and  $re->{'LIN'} and $data =~ /^"name":"macos".+"version":null/ ){ $ui[14] = 1; $ta[7] = 0; next }
       if( $ui[14] ){
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[15] );
        if( $sp and $sp == 1 ){ $tap{"${name}un_Linux"} = 1; $tap{"${name}Linux"} = 0;
          $ui[14] = $ui[15] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[14] = $ui[15] = $b2 = 0;
        } next;
       }

       if( $ta[8] and $re->{'MAC'} and $data =~ /^"name":"linux".+"version":null/ ){ $ui[16] = 1; $ta[8] = 0; next }
       if( $ui[16] ){
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[17] );
        if( $sp and $sp == 1 ){ $tap{"${name}un_xcode"} = 1; $tap{"$name$OS_Version2"} = 0;
          $ui[16] = $ui[17] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[16] = $ui[17] = $b2 = 0;
        } next;
       }

       if( $ta[9] and $re->{'MAC'} and $data =~ /^"name":"macos".+"version":"([^"]+)"/ ){ $ui[18] = $1; $ta[9] = 0; next }
       if( $ui[18] ){ my $m1 = substr($ui[18],2,1) ? $ui[18] : "$ui[18].0";
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[19] );
        if( $sp and $sp == 1 ){ if( $m1 > $OS_Version ){ $tap{"${name}un_xcode"} = 1; $tap{"$name$OS_Version2"} = 0 }
                                $tap{"${name}USE_OS"} = $m1;
          $ui[18] = $ui[19] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[18] = $ui[19] = $b2 = 0;
        } next;
       }

       if( $ta[10] and $re->{'MAC'} and $data =~ /^"name":"maximum_macos".+"version":"([^"]+)"/ ){ $ui[20] = $1; $ta[10] = 0; next }
       if( $ui[20] ){ my $m2 = substr($ui[20],2,1) ? $ui[20] : "$ui[20].0";
        if( index($data,'"build"') == 0 ){ $b2 = 1 }
        my $sp = Spec_1 ( $data,\$ui[21] );
        if( $sp and $sp == 1 ){ if( $m2 < $OS_Version ){ $tap{"${name}un_xcode"} = 1; $tap{"$name$OS_Version2"} = 0 }
          $ui[20] = $ui[21] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[20] = $ui[21] = $b2 = 0;
        } next;
       }

       if( $ta[11] and $data =~ /"disable_date":"([^"]+)"/ and $TIME gt $1 ){ $tap{"${name}disable"} = 1; $ta[11] = 0; next }

     }
     if( index($data,'"variations":') >= 0 ){ $ui[22] = 1; for(0..2){ $ta[$_] = 1 } next }
     if( $ui[22] ){ if( $re->{'LIN'} ){ %HA1 = %LHA1; %HA2 = %LHA2 }
      $data =~ s/^,?"([^"]+)":\n/$1/;
      if( $MAC_OS{$data} and $MAC_OS{$data} eq $OS_Version2 ){ $ui[0] = 1; next }
      if( $ui[0] and $MAC_OS{$data} ){ $ui[0] = 0 }
      if( $ui[0] ){

       if( index($data,'build_dependencies') >= 0 ){ $ui[1] = 1; next }
       if( $ui[1] ){ chomp $data; $data =~ tr/"//d;
        for my $ls4(split ',',$data){ $HA1{$ls4}++;
         unless( $HA1{$ls4} > 1 ){ Bdep_1( $ls4,$name ) }
        } $ui[1] = 0; next;
       }

       if( index($data,'dependencies') >= 0 ){ $ui[2] = 1; next }
       if( $ui[2] ){ chomp $data; $data =~ tr/"//d;
        for my $ls5(split ',',$data){ $HA2{$ls5}++;
         unless( $HA2{$ls5} > 1 ){ Depe_1( $ls5,$name ) }
        } $ui[2] = 0; next;
       }

       if( $ta[0] and $re->{'MAC'} and $data =~ /^"name":"xcode".+"version":null/ ){ $ui[3] = 1; $ta[0] = 0; next }
       if( $ui[3] ){
       my $sp = Spec_1 ( $data,\$ui[4] );
        if( $sp and $sp == 1 ){ $b2 ? Xcod_1( $name,1 ) : Xcod_1( $name ); $ui[3] = $ui[4] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[3] = $ui[4] = $b2 = 0;
        } next;
       }

       if( $ta[1] and $re->{'MAC'} and $data =~ /^"name":"xcode".+"version":"([^"]+)"/ ){ $ui[5] = $1; $ta[1] = 0; next }
       if( $ui[5] ){ if( index($ui[5],'.') == 1 ){ $ui[5] = "0$ui[5]" }
       my $sp = Spec_1 ( $data,\$ui[6] );
        if( $sp and $sp == 1 ){ $b2 ?  Bxco_1( $name,$ui[5],1 ) : Bxco_1( $name,$ui[5] ); $ui[5] = $ui[6] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[5] = $ui[6] = $b2 = 0;
        } next;
       }

       if( $ta[2] and $data =~ /^"name":"arch".+"version":"([^"]+)"/ and $1 ne $UNAME ){ $ui[7] = 1; $ta[2] = 0; next }
       if( $ui[7] ){
       my $sp = Spec_1 ( $data,\$ui[8] );
        if( $sp and $sp == 1 ){  $tap{"${name}un_xcode"} = $tap{"${name}un_Linux"} =1;
                                 $tap{"$name$OS_Version2"} = $tap{"${name}Linux"} = 0; $ui[7] = $ui[8] = $b2 = 0;
        }elsif( $sp and $sp == 2 ){ $ui[7] = $ui[8] = $b2 = 0;
        } next;
       }
      }
     }
     last if index($data,',"head_dependencies":') >= 0;
    }
   close $BREW;
  } closedir $dir1;
 }
 rmdir "$ENV{'HOME'}/.BREW_LIST/15";

  sub Spec_1{
   my( $data,$i ) = @_;
    if( index($data,'specs') >= 0 ){ $$i = 1; return }
    ( $$i and index($data,'"head"') == 0 ) ? ( return 2 ) : $$i ? ( return 1 ) : 0;
  }

  sub Bdep_1{
  my( $defa,$name,$ls ) = @_;
   $tap{"${defa}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
    $tap{"${name}deps_b"} .= "$defa\t";
     push @{$re->{'OS'}},"$name,$defa,1" unless not $ls or $tap{"$name$OS_Version2"};
  }

  sub Depe_1{
  my( $defa,$name,$ls ) = @_;
   $tap{"${defa}uses"} .= "$name\t";
    $tap{"${name}deps"} .= "$defa\t";
     push @{$re->{'OS'}},"$name,$defa,1" if $ls;
  }

  sub Xcod_1{
  my( $name,$bu ) = @_;
   if( not $Xcode ){
    if( $bu ){
     $tap{"${name}un_xcode"} = 1;
      $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
    }else{
     $tap{"${name}un_xcode"} = 1;
      $tap{"$name$OS_Version2"} = 0;
    }
   }
  }

  sub Bxco_1{
  my( $name,$xc,$bu ) = @_;
   if( $xc gt $Xcode ){
    if( $bu ){
     $tap{"${name}un_xcode"} = 1;
      $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
    }else{
     $tap{"${name}un_xcode"} = 1;
      $tap{"$name$OS_Version2"} = 0;
    }
   }
  }

 unless( $ARGV[0] ){
  mkdir "$ENV{'HOME'}/.BREW_LIST/cparse";
  open my $J2,'<',"$Cache/api/cask.jws.json" or die" 1 cask cache $!\n";
   my $an = <$J2>; close $J2;
  my @an = split /[^\\]\\n/,$an;
   for( @an ){ tr/\\//d; my( $file ) = /"token":"([^"]+)"/; tr/,/\n/;
               s/"variations":\{/"variations":\n/; $file ||= '';
    open my $K,'>',"$ENV{'HOME'}/.BREW_LIST/cparse/$file.txt" or die" 2 cask cache $!\n";
     print $K "$_\n"; close $K;
   } rmdir "$ENV{'HOME'}/.BREW_LIST/16";

  if( $re->{'MAC'} ){
  my $CPU = $UNAME eq 'x86_64' ? 'intel' : 'arm';
   opendir my $dir2,"$ENV{'HOME'}/.BREW_LIST/cparse/" or die" 1 cparse $!\n";
   for my $ls2(sort readdir $dir2){ next if index($ls2,'.') == 0;
    my( $name,$u2,$ato,$url,@ui,@ta ) = ( substr($ls2,0,-4),'' );
     for(0..2){ $ta[$_] = 1 } push @CASK,$name;
      $tap{"${name}cask"} = "$MY_HOME/Library/Taps/homebrew/homebrew-cask-fonts/Caks/$name";
    open my $CASK,'<',"$ENV{'HOME'}/.BREW_LIST/cparse/$ls2" or die" 2 cparse $!\n";
     while(my $data = <$CASK>){
      unless( $ui[9] ){
       if( $ta[0] and $data =~ /"full_token":"([^"]+)"/ ){ $tap{"${name}c_name"} = $1; $ta[0] = 0 }
       if( index($data,'"desc":') == 0 ){ $ui[0] = 1 }
       if( $ui[0] ){
        if( index($data,'"homepage":') == 0 ){ $ui[0] = $ui[1] = 0; next }
        if( not $ui[1] and $data =~ /^"desc":"([^"]+)"$/ ){ $tap{"${name}c_desc"} = $1; $ui[0] = 0; next;
        }elsif( not $ui[1] and $data =~ /^"desc":"(.+)"$/ ){ $tap{"${name}c_desc"} = $1; $ui[0] = 0; next;
        }elsif( not $ui[1] and $data =~ /"desc":"([^"]+)\n$/ ){ $tap{"${name}c_desc"} .= "$1,"; $ui[1] = 1; next;
        }elsif( $ui[1] and $data =~/([^"]+)\n$/ ){ $tap{"${name}c_desc"} .= "$1,"; next;
        }elsif( $ui[1] and $data =~ /([^"]+)"\n$/ ){ $tap{"${name}c_desc"} .= $1; $ui[0] = $ui[1] = 0; next }
       }

       if( $ta[1] and $data =~ /"url":"([^"]+)"/ ){ $url = $1; $ta[1] = 0 }
       if( index($data,':"Casks/font/') >= 0 ){
        if( $re->{'MAC'} ){ $tap{"${name}mfont"} = 1; push @FONT,"$name\n";
         ( $tap{"${name}font"} ) = $url =~ /(.+(?:ttf|otf|dfont))$/;
         if( $tap{"${name}font"} ){
           $tap{'fontlist'} .= "$name\t";
            $FON .= "$name \\\n";
         }
        } last;
       }

       if( index($data,'"version":') == 0 ){ $ui[2] = 1 }
       if( $ui[2] ){ if( index($data,'"installed":') == 0 ){ $ui[2] = $ui[3] = 0; next }
        if( not $ui[3] and $data =~ /^"version":"([^"]+)"$/ ){ $tap{"${name}c_version"} = $1; $ui[2] = 0; next;
        }elsif( not $ui[3] and $data =~ /"version":"([^"]+).*\n$/ ){ $tap{"${name}c_version"} .= "$1,"; $ui[3] = 1; next;
        }elsif( $ui[3] and $data =~ /^([^"]+)\n$/ ){ $tap{"${name}c_version"} .= "$1,"; next;
        }elsif( $ui[3] and $data =~ /^([^"]+)".*\n$/ ){ $tap{"${name}c_version"} .= $1; $ui[2] = $ui[3] = 0; next }
       }

       if( index($data,'"depends_on":') == 0 ){ $ui[4] = 1 }
       if( $ui[4] ){ if( index($data,'"conflicts_with":') == 0 ){ $ui[4] = $ui[5] = $ui[6] = 0; next }
        if( index($data,'"depends_on":{}') == 0 ){ $ato = 1;
        }elsif( $data =~ /"arch":\[\{"type":"([^"]+)"/ and $1 ne $CPU ){ $tap{"${name}un_cask"} = 1; next;
        }elsif( $data =~/"macos":\{"([^"]+)":\["([^"]+)"]}/ ){ Macs_1( $name,$1,$2 ); next;
        }elsif( $data =~/"cask":\["([^"]+)"]/ ){ Cask_1( $name,$1 ); next;
        }elsif( $data =~ /"formula":\["([^"]+)"]/ ){ Form_1( $name,$1 ); next;
        }elsif( $data =~ /"cask":\["([^"]+)"$/ ){ Cask_1( $name,$1 ); $ui[5] = 1; next;
        }elsif( $data =~ /"formula":\["([^"]+)"$/ ){ Form_1( $name,$1 ); $ui[6] = 1; next;
        }elsif( $data =~ /"macos":\{"==":\["([^"]+)"$/ ){ $u2 .= "$1\t"; next;
        }elsif( $data =~ /^"([^"]+)"$/ ){
         if( $ui[5] ){ Cask_1( $name,$1 ) }elsif( $ui[6] ){ Form_1( $name,$1 ) }elsif( $u2 ){ $u2 .= "$1\t" } next;
        }elsif( $data =~ /^"([^"]+)"]}/ ){
         if( $ui[5] ){ Cask_1( $name,$1 ) }elsif( $ui[6] ){ Form_1( $name,$1 ) }elsif( $u2 ){ $u2 .= $1;
                    for my $os(split "\t","$u2"){ my $m1 = substr($os,2,1) ? $os : "$os.0";
                     unless( $m1 == $OS_Version ){ $tap{"${name}un_cask"} = 1;
                     }elsif( $m1 == $OS_Version ){ $tap{"${name}un_cask"} = 0; last }
                    }
         } next;
        }
       }
       if( $ta[2] and $data =~ /"disable_date":"([^"]+)"/ and $TIME gt $1 ){ $tap{"${name}c_disable"} = 1; $ta[2] = 0; }
      }
      if( index($data,'"variations":') >= 0 ){ $ui[9] = 1; next }
      if( $ui[9] ){
       my( $os ) = $data =~ /^"([^"]+)":\{"/;
       if( $os and $MAC_OS{$os} and $MAC_OS{$os} eq $OS_Version2 ){ $ui[0] = 1; next;
       }elsif( $os and $MAC_OS{$os} and $MAC_OS{$os} ne $OS_Version2 ){ $ui[0] = 0; next }
       if( $ui[0] ){
        if( not $ui[1] and $data =~ /"version":"([^"]+)\n$/ ){ $tap{"${name}v_version"} .= "$1,"; $ui[1] = 1; next;
        }elsif( $ui[1] and $data =~ /^([^"]+)\n$/ ){ $tap{"${name}v_version"} .= "$1,"; next;
        }elsif( $ui[1] and $data =~ /^([^"]+)".*\n$/ ){ $tap{"${name}v_version"} .= $1; $ui[1] = 0; next;
        }elsif( $data =~ /"version":"([^"]+)"/ ){
           $tap{"${name}v_version"} = $1;
        }elsif( index($data,'"depends_on":{}') == 0 ){
           $tap{"${name}un_cask"} = 0;
        }elsif( $data =~ /"depends_on":\{"macos":\{"([^"]+)":\["([^"]+)"]/ ){
           $ato ? Macs_1( $name,$1,$2 ) : Macs_1( $name,$1,$2,1 );
        }
       }
      }
      if( eof $CASK ){ $ACA .= "$name \\\n" }
     } close $CASK;
   }closedir $dir2;
  }
 }
 rmdir "$ENV{'HOME'}/.BREW_LIST/17";

  sub Form_1{
   my( $name,$fo ) = @_;
    $tap{"${name}formula"} .= "$fo\t";
     $tap{"${fo}u_form"} .= "$name\t" if not $tap{"${fo}u_form"} or $tap{"${fo}u_form"} !~ /$name\t/;
  }

  sub Cask_1{
   my( $name,$ca ) = @_;
    $tap{"${name}d_cask"} .= "$ca\t";
     $tap{"${ca}u_cask"} .= "$name\t" if not $tap{"${ca}u_cask"} or $tap{"${ca}u_cask"} !~ /$name\t/;
  }

  sub Macs_1{
   my( $name,$kaku,$os,$val ) = @_;
    $os = substr($os,2,1) ? $os : "$os.0";
    if( $kaku =~ /^[<=>]{1,2}$/ and $os =~ /^[\d.]+$/  ){
     unless( $val or eval"$OS_Version $kaku $os" ){ $tap{"${name}un_cask"} = 1;
     }elsif( eval"$OS_Version $kaku $os" ){ $tap{"${name}un_cask"} = 0;
     }
    }
  }
   if( not $ARGV[0] or $ARGV[0] == 1 ){
    if( $re->{'LIN'} and -d "$MY_HOME/Library/Taps/homebrew/homebrew-linux-fonts/Formula" ){
        Dirs_1( "$MY_HOME/Library/Taps/homebrew/homebrew-linux-fonts/Formula",0,1 ); $re->{'font'} = 1;
    }
   }
   Dirs_1( "$MY_HOME/Library/Taps",1,0 ) unless $ARGV[0]; my( @BR,@CA );

  sub Dirs_1{
  my( $dir,$ls,$cask ) = @_;
   opendir my $DIR,$dir or die " DIR $!\n";
    for my $an( sort readdir $DIR ){ next if index($an,'.') == 0;
      next if $ls and $an =~ /homebrew$|homebrew-core$|homebrew-cask$|homebrew-bundle$|homebrew-services$|
                              homebrew-aliases$|homebrew-cask-versions$|homebrew-command-not-found
                              homebrew-cask-fonts$|homebrew-linux-fonts/x;
      if( not $cask and $an =~ /\.rb$/ ){ local $/;
       open K,'<',"$dir/$an" or die" rb_file $!\n"; my $br = <K>; close K;
        if( $br =~ /desc\s*"/ ){ push @BR,"$dir/$an" } return;
      }
      -d "$dir/$an" ? Dirs_1( "$dir/$an",$ls,$cask) :( $cask and $an =~ /\.rb$/ ) ?
                      push @CA,"$dir/$an" : ( $an =~ /\.rb$/ ) ? push @BR,"$dir/$an" : 0;
    }
   closedir $DIR;
  }

  for my $dir1( @BR ){
   my( $name,$bot,$os,@ta ) = $dir1 =~ m|.+/(.+)\.rb$|; $tap{"${name}core"} = $dir1;
    for(0..2){ $ta[$_] = 1 }
    if( $NA{$name} ){ $tap{$name} = 1; $name = "$name/tap" }
     $tap{"${name}core"} = $dir1; push @BREW,$name;
   open my $BR1,$dir1 or die" tie Info_3 $!\n";
   while( my $data = <$BR1> ){
    if( $ta[0] and $data =~ /^\s*desc\s*"(.+)"/ ){ $data =~ tr/\\//d; $tap{"${name}f_desc"} = $1; $ta[0] = 0 }
    if( $ta[1] and $data =~ /^\s*bottle\s+do/ ){ $bot = 1; $ta[1] = 0 }
     if( $bot ){
      unless( $os ){ for(keys %MAC_OS){ $os = $_ if $MAC_OS{$_} eq $OS_Version2 } $os = 'x86_64_linux' if $re->{'LIN'} }
       if( $ta[2] and $data =~ /,\s*$os:\s*"|,\s*all:\s*"/o ){ $tap{"${name}$OS_Version2"} = 1; $ta[2] = $bot = 0 }
     }
    if( $bot and $data =~ /^\s+end/ ){ $bot = 0 }
   } close $BR1;
  }

  if( $re->{'LIN'} ){
   for my $dir3( @CA ){
    my( $dirs,$name,@ta ) = $dir3 =~ m|.+/(homebrew-[^/]+)/(?:[^/]+/)*(.+)\.rb$|;
     for(0..2){ $ta[$_] = 1 }
    if( $dirs eq 'homebrew-linux-fonts' ){ push @CASK,$name;
     $tap{"${name}cask"} = $dir3; $tap{"${name}lfont"} = 1;
     open my $BR3,'<',$dir3 or die " tie Info_3 $!\n";
      while(my $data=<$BR3>){
       if( $ta[0] and $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}c_version"} = $data; $ta[0] = 0;
       }elsif( $ta[1] and $data =~ s/^\s*desc\s+"(.+)".*\n/$1/ ){
        $data =~ tr/\\//d; $tap{"${name}c_desc"} = $data; $ta[1] = 0;
       }elsif( $ta[2] and $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}c_name"} = $data; $ta[2] = 0;
       }
      }
     close $BR3;
    }
   }
  }
   undef @CA; undef @BR;
  unless( $ARGV[0] ){
   @BREW = sort @BREW;
   @CASK = sort @CASK;
  }
}else{
 if( $re->{'MAC'} ){
   $re->{'CLANG'} = `/usr/bin/clang --version|sed -E '/Apple/!d;s/.+clang-([^.]+).+/\\1/'` || 0 unless $ARGV[0];
   %MAC_OS = ('15.0M1'=>'arm64_sequoia','15.0'=>'sequoia','14.0M1'=>'arm64_sonoma','14.0','sonoma',
              '13.0M1'=>'arm64_ventura','13.0'=>'ventura','12.0M1'=>'arm64_monterey','12.0'=>'monterey',
              '11.0M1'=>'arm64_big_sur','11.0'=>'big_sur','10.15'=>'catalina',
              '10.14'=>'mojave','10.13'=>'high_sierra','10.12'=>'sierra','10.11'=>'el_capitan');
      %HAN = ('newer'=>'>','older'=>'<');
   Dirs_2( "$MY_HOME/Library/Taps/homebrew/homebrew-cask/Casks",0,1 )
     if -d "$MY_HOME/Library/Taps/homebrew/homebrew-cask/Casks" and not $ARGV[0];
 }

   unless( $ARGV[0] ){
    Dirs_2( "$MY_HOME/Library/Taps/homebrew/homebrew-core/Formula",0,0 );
     Dirs_2( "$MY_HOME/Library/Taps/homebrew/homebrew-core/Aliases",0,0 );
      Dirs_2( "$MY_HOME/Library/Taps",1,0 );
   }
   if( not $ARGV[0] or $ARGV[0] == 1 ){
    if( $re->{'LIN'} and -d "$MY_HOME/Library/Taps/homebrew/homebrew-linux-fonts/Formula" ){
        Dirs_2( "$MY_HOME/Library/Taps/homebrew/homebrew-linux-fonts/Formula",0,1 );
    }
   } rmdir "$ENV{'HOME'}/.BREW_LIST/11";

  sub Dirs_2{
  my( $dir,$ls,$cask ) = @_;
   opendir my $DIR,$dir or die " DIR $!\n";
    for my $an( sort readdir $DIR ){ next if index($an,'.') == 0;
     next if $ls and $an =~ /homebrew$|homebrew-core$|homebrew-cask$|homebrew-bundle$|homebrew-services$|
                             homebrew-aliases$|homebrew-cask-versions$|homebrew-command-not-found$
                             homebrew-cask-fonts$|homebrew-linux-fonts$/x;
      if( $ls and not $cask and $an =~ /\.rb$/ ){ local $/;
       open K,'<',"$dir/$an" or die" rb_file $!\n"; my $br = <K>; close K;
        if( $br =~ /desc\s*"/ ){ push @BREW,"$dir/$an" } return;
      }
       -d "$dir/$an" ? Dirs_2( "$dir/$an",$ls,$cask ) : -l "$dir/$an" ? push @{$re->{'ALIA'}},"$dir/$an" :
     ( $cask and $an =~ /\.rb$/ ) ? push @CASK,"$dir/$an" : ( $an =~ /\.rb$/ ) ? push @BREW,"$dir/$an" : 0;
    }
   closedir $DIR;
  }

 unless( $ARGV[0] ){
  for my $alias( @{$re->{'ALIA'}} ){
   my $hand = readlink $alias;
   $alias =~ s|.+/(.+)|$1|;
    $hand =~ s|.+/(.+)\.rb$|$1|;
   $tap{"${alias}alia"} = $hand;
    $tap{"${hand}alias"} .= "$alias\t";
  }
   my( $in,$e ) = @BREW >> 2;
    my @in = ( $in << 1,$in * 3 );
     my( $IN,$KIN,$SPA ) = ( 0,0,0 );
  for my $dir1( @BREW ){ my $bot;
   if( $re->{'MAC'} ){ $e++;
    $e == $in ? rmdir "$ENV{'HOME'}/.BREW_LIST/12" :
    $e == $in[0] ? rmdir "$ENV{'HOME'}/.BREW_LIST/13" :
    $e == $in[1] ? rmdir "$ENV{'HOME'}/.BREW_LIST/14" : 0;
   }
   my( $name ) = $dir1 =~ m|.+/(.+)\.rb$|; $NA{$name}++;
    $tap{$name} = 1,$name = "$name/tap" if $NA{$name} > 1;
     $tap{"${name}core"} = $dir1;
   open my $BREW,'<',$dir1 or die " tie Info_1 $!\n";
    while(my $data=<$BREW>){ last if $data =~ /^\s*def\s+install/;
      if( $data =~ /^\s*bottle\s+do/ ){
       $KIN = $bot = 1; next;
      }elsif( $KIN and $data =~ /^\s*rebuild/ ){
        next;
      }elsif( $KIN and $data !~ /^\s*end/ ){
        if( $data =~ /.*,\s+all:/ ){
         $tap{"${name}14.0M1"}= $tap{"${name}14.0"}  = $tap{"${name}13.0M1"}=
         $tap{"${name}13.0"}  = $tap{"${name}12.0M1"}= $tap{"${name}12.0"}  =
         $tap{"${name}11.0M1"}= $tap{"${name}11.0"}  = $tap{"${name}10.15"} =
         $tap{"${name}10.14"} = $tap{"${name}10.13"} = $tap{"${name}10.12"} =
         $tap{"${name}10.11"} = $tap{"${name}Linux"} = 1; $KIN = 0; next;
        }
         if( $re->{'LIN'} ){
          if( $data =~ s/.*x86_64_linux:.*\n/Linux/ ){ $tap{"$name$data"} = 1; $KIN = 0 } next;
         }else{
          if( $data =~ s/.*[^_]$MAC_OS{$OS_Version2}:.*\n/$OS_Version2/o ){ $tap{"$name$data"} = 1; $KIN = 0 } next;
         }
      }elsif( $KIN and $data =~ /^\s*end/ ){
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
          $SPA = $IN = 1 if $re->{'LIN'} or eval "$Mac_OS{$ha1} $HAN{$ha2} $OS_Version"; next;
      }elsif( my( $ha3,$ha4 ) = $data =~ /^\s*on_system\s+:linux,\s+macos:\s+:(.+)_or_([^\s]+)\s+do/ ){
          $SPA = $IN = 1 if $re->{'MAC'} and eval "$Mac_OS{$ha3} $HAN{$ha4} $OS_Version"; next;
      }elsif( my( $ha5 ) = $data =~ /^\s*on_([^\s]+)\s+do/ ){
          $SPA = $IN = 1 if $Mac_OS{$ha5} and $Mac_OS{$ha5} ne $OS_Version; next;
      }

       if( $data =~ /^\s*disable!\s+date:\s+"([^"]+)",/ and $TIME gt $1 ){
           $tap{"${name}disable"} = 1;
       }elsif( $re->{'MAC'} and $data =~ s/^\s*depends_on\s+xcode:.+"([^"]+)",\s+:build.*\n/$1/ ){
         $data = "0$data" if index($data,'.') == 1;
          if( $data gt $Xcode ){
           $tap{"${name}un_xcode"} = 1;
            $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
          } next;
       }elsif( $re->{'MAC'} and $data =~ /^\s*depends_on\s+xcode:\s+:build/ ){
          if( not $Xcode ){
           $tap{"${name}un_xcode"} = 1;
            $tap{"${name}un_xcode"} = 0 if $tap{"$name$OS_Version2"};
          } next;
       }elsif( $re->{'MAC'} and $data =~ s/^\s*depends_on\s+xcode:\s*"([^"]+)".*\n/$1/ ){
         $data = "0$data" if index($data,'.') == 1;
          if( $data gt $Xcode ){
            $tap{"${name}un_xcode"} = 1;
             $tap{"$name$OS_Version2"} = 0;
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
         if( $ds5 =~ /^[<=>]{1,2}$/ and eval "$re->{'CLANG'} $ds5 $ds6" ){
          $tap{"${ds4}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
           $tap{"${name}deps_b"} .= "$ds4\t";
         }
      }elsif( $re->{'MAC'} and my( $ds7,$ds8,$ds9 ) =
        $data =~ /^\s*depends_on\s+"([^"]+)"\s+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
         if( $ds8 =~ /^[<=>]{1,2}$/ and eval "$re->{'CLANG'} $ds8 $ds9" ){
          $tap{"${ds7}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
           $tap{"${name}deps_b"} .= "$ds7\t";
         }
      }elsif( $re->{'LIN'} and $data =~ s/^\s*uses_from_macos\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
        $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
         $tap{"${name}deps_b"} .= "$data\t";
      }elsif( my( $us1,$us2 ) =
        $data =~ /^\s*uses_from_macos\s+"([^"]+)"\s+=>.+:build,\s+since:\s+:([^\s]+)/ ){
         if( $re->{'LIN'} or $OS_Version < $Mac_OS{$us2} ){
          $tap{"${us1}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
           $tap{"${name}deps_b"} .= "$us1\t";
         }
      }elsif( $data =~ s/^\s*depends_on\s+"([^"]+)"\s+=>\s+\[?:build.*\n/$1/ ){
         $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
          $tap{"${name}deps_b"} .= "$data\t";
           push @{$re->{'OS'}},"$name,$data,1" unless $tap{"$name$OS_Version2"};
      }elsif( my( $us3,$us4 ) = $data =~ /^\s*uses_from_macos\s+"([^"]+)",\s+since:\s+:([^\s]+)/ ){
        if( $re->{'LIN'} or $re->{'MAC'} and $OS_Version < $Mac_OS{$us4} ){
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
       }elsif( not $bot and $data =~ s/^\s*tag:\s+"v([^"[a-zA-Z]-]+).*?".*\n/$1/ ){
         $tap{"${name}f_version"} = $data;
       }elsif( not $bot and $data =~ s/^\s*desc\s+"(.+)".*\n/$1/ ){
         $data =~ tr/\\//d; $tap{"${name}f_desc"} = $data;
       }elsif( not $bot and $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
         $tap{"${name}f_name"} = $data;
       }elsif( not $bot and $data =~ s/^\s*revision\s+(\d+).*\n/$1/ ){
         $tap{"${name}revision"} = "_$data";
       }

     if( $data =~ /^\s*keg_only\s+:.+_by_macos/ ){
       $tap{"${name}pkeg"} = 1;
     }elsif( $data =~ /^\s*keg_only/ ){
       $tap{"${name}keg"} = 1;
     }elsif( $data =~ /^\s*depends_on\s+:macos/ ){
       $tap{"${name}un_Linux"} = 1; $tap{"${name}Linux"} = 0;
     }elsif( $data =~ /^\s*depends_on\s+:linux/ ){
       $tap{"${name}un_xcode"} = 1;
     }elsif( my( $cs1,$cs2,$cs3 ) =
            $data =~ /^\s*depends_on\s+macos:\s+:([^\s]*)\s+if\s+Development[^\s]+\s+([^\s]+)\s+(\d+)/ ){
      $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and
       $cs2 =~ /^[<=>]{1,2}$/ and eval "$re->{'CLANG'} $cs2 $cs3" and $Mac_OS{$cs1} > $OS_Version;
        $tap{"${name}USE_OS"} = $Mac_OS{$cs1};
     }elsif( $data =~ s/^\s*depends_on\s+macos:\s+:([^\s]*).*\n/$1/ ){
      if( $re->{'MAC'} and $OS_Version and $Mac_OS{$data} > $OS_Version ){
           $tap{"${name}un_xcode"} = 1; $tap{"${name}$OS_Version2"} = 0;
      } $tap{"${name}USE_OS"} = $Mac_OS{$data};
     }elsif( $data =~ s/^\s*depends_on\s+maximum_macos:\s+\[?:([^,\s]+).*\n/$1/ ){
       $tap{"${name}un_xcode"} = 1 if $re->{'MAC'} and $OS_Version and $Mac_OS{$data} < $OS_Version;
     }
    }
   close $BREW;
  }
 }

  if( $re->{'MAC'} ){
  rmdir "$ENV{'HOME'}/.BREW_LIST/15";
  my( $in,$e ) = ( @CASK >> 1,0 );
  my $UNAME2 = $UNAME eq 'x86_64' ? 'intel' : 'arm';
   for my $dir2( @CASK ){
    my( $SPA,$CN,$IN,$CP1,$CP2,$FI,$DW,$OW,$ver,$i ) = ( 0,0,0,0,0,1,0,0 );
    rmdir "$ENV{'HOME'}/.BREW_LIST/16" if $in == $e++;
     my( $dirs,$name ) = $dir2 =~ m|.+/([^/]+)/[^/]+/(.+)\.rb$|;
      $tap{"${name}cask"} = $dir2;
    open my $BREW,'<',$dir2 or die " tie Info_2 $!\n";
     while(my $data=<$BREW>){ $i++;
      if( $dirs eq 'font' and $FI ){
       $tap{"${name}cask"} = "$MY_HOME/Library/Taps/homebrew/homebrew-cask-fonts/Caks/$name";
       $tap{"${name}mfont"} = 1; push @FONT,"$name\n" if $i == 1;
       $ver = $1 if $data =~ /^\s*version\s+"([^"]+)"/;
       ( $tap{"${name}font"} ) = $data =~ /^\s*url\s+"(.+(?:ttf|otf|dfont))"/;
        if( $tap{"${name}font"} ){
         $tap{"${name}font"} =~ s/\Q#{version}\E/$ver/g;
          $tap{'fontlist'} .= "$name\t";
           $FON .= "$name \\\n"; $FI = 0;
        }
      }
       if( my( $cpu ) = $data =~ /^\s*on_(intel|arm)\s+do/ ){ if( $cpu eq $UNAME2 ){ $CN = $SPA= 1;
                                                              }else{ $CP1 = $CP2 = 1 } next;
       }elsif( $data !~ /^\s*end/ and $CP1 ){ $CP2++ if $data =~ /\s+do\s/; next;
       }elsif( $data =~ /^\s*end/ and $CP2 > 1 ){ $CP2--; next;
       }elsif( $data =~ /^\s*end/ and $CP1 ){ $CP1 = $CP2 = 0; next;
       }
      if( my( $ls1,$ls2 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ and not $CN ){
        $tap{"${name}un_cask"} = 1 unless $ls1 !~ /^[<=>]{1,2}$/ or eval "$OS_Version $ls1 $Mac_OS{$ls2}";
      }elsif( my( $arch ) = $data =~ /^\s*depends_on\s+arch:\s+:([^\s]+)/ ){
        $tap{"${name}un_cask"} = 1 if $UNAME ne $arch;
      }elsif( not $DW and $data =~ /depends_on\s+formula:\s+%w\[/ ){ $DW = 1;
      }elsif( $DW and $data =~ /^\s*]/ ){ $DW = 0;
      }elsif( $DW and $data =~ s/^\s*([^\s]+)\n/$1/ ){
        $tap{"${name}formula"} .= "$data\t";
         $tap{"${data}u_form"} .= "$name\t"
          if not $tap{"${data}u_form"} or $tap{"${data}u_form"} !~ /$name\t/;
      }elsif( not $OW and $data =~ /depends_on\s+macos:\s+\[/ ){ $OW = 1; next;
      }elsif( $OW and $data =~ /^\s*]/ ){ $OW = 0; next;
      }elsif( $OW and $data =~ s/^\s*:([^\s]+),\n/$1/ ){ my $os;
        for(keys %Mac_OS){ $os = $_ if $Mac_OS{$_} eq $OS_Version }
         if( $data ne $os ){ $tap{"${name}un_cask"} = 1 }else{ $OW = $tap{"${name}un_cask"} = 0 }
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
      }elsif( my( $del ) = $data =~ /disable!\s+date:\s+"([^"]+)"/ and $TIME gt $1 ){
        $tap{"${name}c_disable"} = 1;
      }elsif( my( $ha1,$ha2 ) = $data =~ /^\s*on_([^\s]+)\s+:or_([^\s]+)\s+do/ ){
        $SPA = $CN = not eval "$Mac_OS{$ha1} $HAN{$ha2} $OS_Version" ? 1 : 0;
         $CP1 = $CP2 = $CN ? 0 : 1; next;
      }elsif( my( $ha3 ) = $data =~ /^\s*on_([^\s]+)\s+do/ ){
        $SPA = $CN = $Mac_OS{$ha3} eq $OS_Version ? 1 : 0;
         $CP1 = $CP2 = $CN ? 0 : 1; next;
      }elsif( $data !~ /^\s*end/ and $CN ){ $SPA++ if $data =~ /\s+do\s/;
       $tap{"${name}v_version"} = $data if not $tap{"${name}v_version"} and $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/;
        if( my( $ls3,$ls4 ) = $data =~ /^\s*depends_on\s+macos:\s+"([^\s]+)\s+:([^\s]+)"/ ){
         $tap{"${name}un_cask"} = 1 unless $ls3 !~ /^[<=>]{1,2}$/ or eval"$OS_Version $ls3 $Mac_OS{$ls4}";
        }elsif( my( $ls5 ) = $data =~ /^\s*depends_on\s+macos:\s+:([^\s]+)/ ){
         $tap{"${name}un_cask"} = 1 if $OS_Version < $Mac_OS{$ls5}
        } next;
      }elsif( $data =~ /^\s*end/ and $SPA > 1 ){ $SPA--; next;
      }elsif( $data =~ /^\s*end/ and $CN ){ $SPA = $CN = 0; next;
      }elsif( $data =~ s/^\s*version\s+[":]([^"\s]+)"?.*\n/$1/ ){
        $tap{"${name}c_version"} = $data unless $tap{"${name}c_version"};
      }elsif( $data =~ s/^\s*desc\s+"(.+)".*\n/$1/ ){
        $data =~ tr/\\//d; $tap{"${name}c_desc"} = $data;
      }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}c_name"} = $data;
      }
     }
    close $BREW;
   }
  }else{
    for my $dir3( @CASK ){
    my( $dirs,$name ) = $dir3 =~ m|.+/(homebrew-[^/]+)/(?:[^/]+/)*(.+)\.rb$|;
     if( $dirs eq 'homebrew-linux-fonts' ){
      $tap{"${name}cask"} = $dir3; $tap{"${name}lfont"} = 1;
      open my $BREW,'<',$dir3 or die " tie Info_3 $!\n";
       while(my $data=<$BREW>){
        if( $data =~ s/^\s*version\s+"([^"]+)".*\n/$1/ ){
         $tap{"${name}c_version"} = $data;
        }elsif( $data =~ s/^\s*desc\s+"(.+)".*\n/$1/ ){
         $data =~ tr/\\//d; $tap{"${name}c_desc"} = $data;
        }elsif( $data =~ s/^\s*name\s+"([^"]+)".*\n/$1/ ){
         $tap{"${name}c_name"} = $data;
        }
       }
      close $BREW;
     }
    }
   }

  unless( $ARGV[0] ){
   @BREW = sort grep{ s|.+/(.+)\.rb|$1| }@BREW;
  if( $re->{'MAC'} ){
   for( @CASK ){
    last unless m|$MY_HOME/Library/Taps/homebrew/homebrew-cask/Casks/|o;
     my( $name ) = m|.+/(.+)\.rb|;
      $ACA .= "$name \\\n";
   }
   @CASK = sort grep{ s|.+/(.+)\.rb|$1| }@CASK;
  }
 }
 rmdir "$ENV{'HOME'}/.BREW_LIST/17";
}

if( not $ARGV[0] or $ARGV[0] == 2 ){
 sub Glob_1{
 my( $brew,$mine,$loop ) = @_;
  my @GLOB = $brew ? glob "$MY_BREW/Cellar/$brew/*" : glob "$MY_BREW/Cellar/*/*";
  for my $glob( @GLOB ){ my($name) = $glob =~ m|$MY_BREW/Cellar/([^/]+)/.*|;
   if( -f "$glob/INSTALL_RECEIPT.json" ){ my $in;
    open my $CEL,'<',"$glob/INSTALL_RECEIPT.json" or die " GLOB $!\n";
     while(my $cel=<$CEL>){
      if( index($cel,"\n") < 0 ){
       my( $col ) = $cel =~ /"runtime_dependencies":\[([^]]*)]/;
       my @HE = $col =~ /{"full_name":"([^"]+)","version":"[^"]+"}/g;
       for my $ls1( @HE ){ my( %HA,%AL,$ne );
        if( $tap{"${ls1}uses"} ){ $HA{$_}++ for split '\t',$tap{"${ls1}uses"} }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls1 eq $mine;
         }else{ unless( $ls1 eq 'glibc' ){ next unless Glob_1( $ls1,$name,1 ); }
          if( $tap{"${ls1}alias"} and $tap{"${name}deps"} ){
           $AL{$_}++ for split '\t',$tap{"${ls1}alias"};
           $AL{$_} ? $ne++ : 0 for split '\t',$tap{"${name}deps"};
          } next if $ne;
          if( $re->{'MAC'} or $re->{'LIN'} and $ls1 ne 'linux-headers@5.15' ){
           $tap{"${ls1}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls1\t";
          }
         }
        }
       }
       if( $cel =~ s/.+"tap":"([^"]+)",.+/$1/ ){
        $tap{"${name}_tap"} = 1 if index($cel,'homebrew/core') < 0;
       }
      }else{ my( %HA,%AL,$ne );
       if( $in or $cel =~ /runtime_dependencies/ ){ $in = $cel =~ /]/ ? 0 : 1;
        my( $ls2 ) = $cel =~ /"full_name":\s*"([^"]+)".*/ ? $1 : next;
        if( $tap{"${ls2}uses"} ){ $HA{$_}++ for split '\t',$tap{"${ls2}uses"} }
        unless( $HA{$name} ){
         if( $loop ){ return if $ls2 eq $mine;
         }else{ unless( $ls2 eq 'glibc' ){ next unless Glob_1( $ls2,$name,1 ); }
          if( $tap{"${ls2}alias"} and $tap{"${name}deps"} ){
           $AL{$_}++ for split '\t',$tap{"${ls2}alias"};
           $AL{$_} ? $ne++ : 0 for split '\t',$tap{"${name}deps"};
          } next if $ne;
          if( $re->{'MAC'} or $re->{'LIN'} and $ls2 ne 'linux-headers@5.15' ){
           $tap{"${ls2}uses"} .= "$name\t";
           $tap{"${name}deps"} .= "$ls2\t";
          }
         }
        }
       }
       if( $cel =~ s/^\s+"tap":\s+"([^"]+)".*\n/$1/ ){
        $tap{"${name}_tap"} = 1 if index($cel,'homebrew/core') < 0; last;
       }
      }
     }
    close $CEL;
   }
  }1;
 } Glob_1;
}

unless( $ARGV[0] ){
 rmdir "$ENV{'HOME'}/.BREW_LIST/18";
 if( $re->{'MAC'} ){ my %HA;
  for( @{$re->{'OS'}} ){
   my( $name,$data,$ls ) = split ',';
   if( not $ls and $tap{"${data}USE_OS"} and $tap{"${data}USE_OS"} <= $OS_Version ){
    $tap{"${data}build"} .= "$name\t" unless $tap{"$name$OS_Version2"};
     $tap{"${name}deps_b"} .= "$data\t";
   }elsif( $ls and $tap{"${data}USE_OS"} and $tap{"${data}USE_OS"} > $OS_Version ){
    Uses_1( $name,\%HA );
   }
  }
 }

 sub Uses_1{
 my( $name,$HA ) = @_;
  for my $ls( split '\t',$name ){
   $HA->{$ls}++;
   if( $HA->{$ls} < 2 ){
    $tap{"$ls$OS_Version2"} = 0 if $tap{"$ls$OS_Version2"};
     $tap{"${ls}un_xcode"} = 1;
   }
   Uses_1( $tap{"${ls}uses"},$HA ) if $tap{"${ls}uses"};
  }
 }

 sub Version_1{
  my @ls1 = split '\.|-|_',$_[0];
  $_[1] ? my @ls2 = split '\.|-|_',$_[1] : return 1;
  my $i = 0;
   for( ;$i<@ls2;$i++ ){
    if( $ls1[$i] and $ls2[$i] ){
     if( $ls1[$i] =~ /[^\d]+/ or $ls2[$i] =~ /[^\d]+/ ){
      if( $ls1[$i] gt $ls2[$i] ){ return 1;
      }elsif( $ls1[$i] lt $ls2[$i] ){ return;
      }
     }else{
      if( $ls1[$i] and $ls1[$i] > $ls2[$i] ){ return 1;
      }elsif( $ls1[$i] and $ls1[$i] < $ls2[$i] ){ return;
      }
     }
    }
   }
  $ls1[$i] ? 1 : 0;
 }

 open my $FILE,'<',"$ENV{'HOME'}/.BREW_LIST/brew.txt" or die " FILE $!\n";
  my @LIST = <$FILE>;
 close $FILE;

  my( $TIN,$UAA,$AIA,$BUI );

  my( $COU,$IN ) = ( 0,0 );
 for( my $i=0;$i<@BREW;$i++ ){
  $TIN .= "$BREW[$i] \\\n" if $tap{"$BREW[$i]deps"} or $tap{"$BREW[$i]deps_b"} and not $tap{"$BREW[$i]$OS_Version2"};
  $UAA .= "$BREW[$i] \\\n" if $tap{"$BREW[$i]uses"};
  $AIA .= "$BREW[$i] \\\n";
   if( $tap{"$BREW[$i]alias"} ){
    for my $a1( split '\t',$tap{"$BREW[$i]alias"} ){
     $UAA .= "$a1 \\\n" if $tap{"${a1}uses"} or $tap{"${a1}u_cask"} or $tap{"${a1}u_form"};
     $BUI .= "$a1 \\\n" if $tap{"${a1}build"};
    }
   }
   if( $tap{"$BREW[$i]build"} ){
    for my $b1( split '\t',$tap{"$BREW[$i]build"} ){
     $BUI .= "$BREW[$i] \\\n",last if not $tap{"${b1}$OS_Version2"} and
      ( $re->{'MAC'} and not $tap{"${b1}un_xcode"} or $re->{'LIN'} and not $tap{"${b1}un_Linux"} );
    }
   }
   for( ;$COU<@LIST;$COU++ ){
    my( $ls1,$ls2,$ls3 ) = split '\t',$LIST[$COU];
     $tap{"$BREW[$i]ver"} = $tap{"$BREW[$i]f_version"}, last if $BREW[$i] lt $ls1;
      if( $BREW[$i] eq $ls1 ){
       $tap{"$BREW[$i]ver"} = Version_1( $ls2,$tap{"$BREW[$i]f_version"} ) ? $ls2 : $tap{"$BREW[$i]f_version"};
       $tap{"$BREW[$i]ver"} = $tap{"$BREW[$i]ver"}.$tap{"$BREW[$i]revision"} if $re->{'MAC'} and $tap{"$BREW[$i]revision"};
       $COU++; last;
      }
   }
   if( $re->{'MAC'} ){
     for( ;$IN<@CASK;$IN++ ){
      last if $BREW[$i] lt $CASK[$IN];
       if($BREW[$i] eq $CASK[$IN]){
        $tap{"$CASK[$IN]so_name"} = 1;
        $IN++; last;
       }
     }
   }
 } my( $COM,$DEP,@TRE,%HAU );
  for my $br( glob "$MY_BREW/Cellar/*" ){
   $br =~ s|.+/(.+)|$1|;
   if( $tap{"${br}deps"} ){ push @TRE,$br;
    $HAU{$_}++ for split '\t',$tap{"${br}deps"};
     $DEP .= "$br \\\n";
   } $COM .= "$br \\\n";
  }
 if( $re->{'MAC'} ){
  for my $ca( @CASK ){
   $TIN .= "$ca \\\n" if $tap{"${ca}formula"} or $tap{"${ca}d_cask"};
   $UAA .= "$ca \\\n" if $tap{"${ca}u_cask"} or  $tap{"${ca}u_form"};
  }
  for my $gs( glob "$MY_BREW/Caskroom/*" ){ my $ls;
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
  open my $dir,'>',"$MY_BREW/share/zsh/site-functions/_bl";
   print $dir $TOP;
  close $dir;
}
untie %tap;

 if( $re->{'MAC'} and not $ARGV[0] ){ my $sort = '';
   for( sort @FONT ){ $sort .= $_ }
   open my $F,'>',"$ENV{'HOME'}/.BREW_LIST/Q_TAP.txt" or die" font list $!\n";
   print $F "3\n0\n$sort"; close $F;
 }
