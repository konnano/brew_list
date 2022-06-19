brew list command extended version: version 1.09_4

: how to use
```
brew tap konnano/brew_list

brew install brew_list
```
OR After downloading, run ./init.sh in the brew_list-main folder

It takes a little time to create the cache file, the command name is brew_list

Uninstall ./init.sh unlink in the brew_list-main folder

: Optional

'-l' option　Formula list is displayed, First argument Formula search, Second argument '.' Full-text search

'-lb' option　bottle install Formula list is displayed, regular expressions //

'-lx' option　Can't install Formula list is displayed, regular expressions //

'-i' option　Installed Formula list is displayed

'-s' option　Search Formula, regular expressions //

'-co' option　Formula library list is displayed

'-in' option　Formula required Formula list is displayed

'-t' option　Formula required Formula is displayed by tree

'-tt' option　Only Formula required Formula is displayed by tree

'-de' option　Unistall Formula, don't need Formula list is displayed

'-d' option　Unistall Formula, don't need Formula is displayed by tree

'-dd' option　Unistall Formula, don't need only Formula is displayed in order by tree

'-ddd' option　Unistall Formula, don't need only Formula, uninstall list in order by pipe.

Please check -dd or -de option   ( brew_list -ddd Formula | xargs brew uninstall )

'-u' option　Installed Formula depend on Formula is displayed

'-ua' option　Formula depend on All Formula is displayed

'-is' option Display in order of size

'-g'option　Independent Formula is displayed

'-o'option　Brew outdated command

'-' option　Brew list command

'-ai' Analytics Data ( not argument 365d or argument 1 30d,2 90d )sort

  Only Mac: Cask

'-c' option　Cask list is displayed, First argument Formula search, Second argument '.' Full-text search

'-ct' option　Cask Tap list is displayed, First argument Formula search, Second argument '.' Full-text search

'-ci' option　Cask installed list is displayed

'-cx' option　Cask can't installe list is displayed, regular expressions //

'-cs' option　Formula and Cask same name list is displayed, regular expressions //

'-cd' option Display the required list of casks

'-ac' Analytics Data ( not argument 365d or argument 1 30d,2 90d )sort

 : Display mark

b mark is bottle installation Formula

k mark is a keg_only Formula

i mark is installed Formula

(i) mark is Formula with version upgrade

e mark is Formula downloaded and not installed or Foumula can't built

x mark is can't installed Formula

t mark Installed formula version upgrade can't installed

  Onle Mac: Cask

s mark is Formula and Cask same name: --cask option for installation

f mark is Cask requires Formula

c mark is Cask requires Cask
