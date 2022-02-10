google translate　　Please read in the atmosphere 

brew list command extended version: version 1.04_1

: how to use

After downloading, run ./init.sh in the brew_list-main folder

It takes a little time to create the cache file, the command is brew_list

Uninstall ./init.sh unlink in the brew_list-main folder

: Optional

'-l'option Formula list is displayed, regular expressions //

'-lb'option bottle install Formula list is displayed, regular expressions //

'-lx'option Can't install Formula list is displayed, regular expressions //

'-i'option Installed Formulas list is displayed

'-s'option Search Formula, regular expressions //

'-co'option Formula library list is displayed

'-in'option Formula required formula list is displayed

'-t'option Formula required formula is displayed by tree

'-tt'option Only formula required formula  is displayed by tree

'-de'option Unistall formula, don't need formula list is displayed

'-d'option Unistall formula, don't need formula is displayed by tree

'-dd'option Unistall formula, don't need only formula is displayed in order by tree

'-ddd'option Unistall formula, don't need only formula can uninstall in order by pipe.

Please check -dd or -de option (brew_list -ddd Formula | xargs brew uninstall).

'-u'option Installed formulas depend on Formulas is displayed

'-ua'option Formulas depend on All Formulas is displayed

'-g'option Independent Formulas is displayed

'-o'option Brew outdated command

'-' option Brew list command

Only Mac: Cask

'-c'option Cask list is displayed, regular expressions //

'-ct'option Cask Tap list is displayed, regular expressions //

'-ci'option Cask installed list is displayed

'-cx'option Casks can't installe list is displayed, regular expressions //

'-cs' option Formula and Cask same name list is displayed, regular expressions //

: Display mark

b mark is bottle installation Formula

k mark is a keg_only Formula

i mark is installed Formula

(i) Mark is Formula with version upgrade

e mark is can't built Formula

x mark is can't installed Formula

t mark Installed formula version upgrade can't installed 

Onle Mac: Cask

s mark is Formula and Cask same name: --cask option for installation

f mark is Cask requires Formula
