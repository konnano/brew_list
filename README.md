next tool for this script brewlist command

: usage

After downloading, run ./brew_list.pl -l in the brew_list folder

mkdir ~/.BREW_LIST; cp $FindBin::Bin/font.sh $FindBin::Bin/tie.pl ~/.BREW_LIST/.

takes a little time to create the cache file

I don't have Apple M1 so I don't support it

uninstall rm -rf ~/.BREW_LIST

: option

'-i'  option formula list display   : // regix

'-lb' option bottle install formula : // regix

'-lx' option can't install formula  : // regix

'-i'  option instaled formula

'-s'  option search formula         : // regix

'-co' option library display

'-'   brew list command

Only Mac : Cask

'-c'  option cask list display      : // regix

'-ci' option installed cask

'-cx' option can't install cask     : // regix

'-cs' same name cask and formula    : // regix

: mark

b mark bottle install formula

k mark keg_only install formula

i mark installed formula and cask

(i) mark version up formula and cask

x mark can't install formula or cask

t mark tap wrapping formula

Only Mac : Cask

s mark same neme cask and formula : install by option --cask

f make cask require formula

Bug'-lb''-lx' option not read tap formula
