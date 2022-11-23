brew list command extended version: version 1.14_5

: how to use
```
brew tap konnano/brew_list
```
```
brew install brew_list
```
Or after downloading, run ./init.sh inside the brew_list-main folder

It will take some time to create the cache file, the command is bl

To uninstall, type ./init.sh unlink inside the brew_list-main folder

: option

'-l' option shows formula list, first argument is formula search, second argument '.' is full text search

'-lb' option shows bottle install formula, // allows regular expression

'-lx' option shows formulas that can't be installed, // allows you to use regular expressions

'-i' option shows installed formula list

'-s' option allows you to search formulas, // allows you to use regular expressions

'-co' option shows formula library

'-in' option shows the formula required for installation

'-t' option displays the formula required for installation as a tree

'-tt' option shows only the formulas required for installation as a tree

'-de' option shows formulas that are not needed after uninstall</br>
Enter the non-uninstall formula in the second argument

'-d' option shows unnecessary formula tree after uninstallation</br>
Enter the non-uninstall formula in the second argument

'-dd' option shows only formulas that are not needed after uninstalling.</br>
Enter the non-uninstall formula in the second argument

'-ddd' option can be used to uninstall formulas that are not needed for uninstallation.</br>
Enter the non-uninstall formula in the second argument

#### Please confirm deletion with -dd or -de ####

'-u' option shows installed formulas that depend on formula

'-ua' option shows all formulas that depend on formulas

The '-ud' option shows the formulas that are dependent on the formula, the second argument '.' the formulas that don't need the dependency

'-ul' option shows the number of formulas dependent on the formula

'-is' option to display formulas in order of size

'-g' option shows formulas that are not dependent

'-o' option brew outdated command

'-' option brew list command

'-ai' option sorts the analysis data (no argument 365d, argument 1 30d, argument 2 90d)

Only Mac: Cask

'-c' option shows Cask list, first argument is formula search, second argument '.' is full text search

'-ct' option shows Cask's Tap list, the first argument is Formula search, the second argument '.' is full text search.

'-ci' option shows the Cask installed list

'-cx' option displays Cask that cannot be installed, // allows regular expression

'-cs' option displays Formula and Cask with the same name, // allows regular expression

'-cd' option lists Casks and Formulas required by Cask

'-ac' option sorts analysis data (no argument 365d, argument 1 30d, argument 2 90d)

'-p' option allows QuickLook preview of Font (unstable) tab completion

'-ctp' option will give you a list of Fonts that can be QuickLook previewed

: display mark

b mark is the bottle installation formula

k mark is keg_only formula

i mark is an installed formula

(i) Marks are Formulas with version upgrades

e mark indicates a formula that has been downloaded but not installed or cannot be built.

x mark is a formula that cannot be installed

t mark is Formula that can no longer be installed due to version upgrade

One Mac : Cask

s marks Formula and Cask with the same name: --cask option for installation

f mark is a Cask that requires a formula

c marks Cask requiring Caska

p mark is a Font that can be previewed with QuickLook
