next tool for this script brewlist command

 : usage

After downloading, run ./brew_list.pl -l in the folder

mkdir ~/.BREW_LIST; cp $FindBin::Bin/font.sh $FindBin::Bin/tie.pl ~/.BREW_LIST/.

takes a little time to create the cache file

I don't have Apple M1 so I don't support it

uninstall rm -rf ~/.BREW_LIST

 : option

'-i' option Formula list // regix

'-lb' option bottle install Formula // regix

'-lx' option not install Formula // regix

'-i' option instaled Formula

'-s' option search Formula // regix

'-co'option Library

'-' brew list command

Only Mac : Cask

'-c' option Cask list // regix

'-ci' option installed CASK

'-cx' option not install CASK // regix

'-cs' same name Formula and Cask // regix

 : mark

b mark bottle install Formula

k mark keg_only install Formula

i mark installed Formula

(i) mark version up Formula

x mark not install Formula or Cask

t mark tap wrapping Formula

Only Mac : Cask

s mark same neme Formula and Cask : install by option --cask

Bug'-lb''-lx' option not read tap formula
