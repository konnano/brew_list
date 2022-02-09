brew list コマンド拡張版  :  version 1.04

MacOS10.9から対応します10.8以前は現在のhomebrewインストール出来ないのでわかりません

10.13メインなので新しいバージョンは行けるだろうと。。。特にApple M1は妄想で対応してます

: 使用方法

ダウンロード後、brew_list-mainフォルダー内で ./init.sh を実行して下さい

キャッシュファイル作成に少し時間がかかります、コマンドはbrew_listです

アンインストールはbrew_list-mainフォルダー内で ./init.sh unlink

: オプション

'-l' オプションでFormulaリストが表示されます、//で正規表現が使えます

'-lb' オプションでボトルインストールFormulaが表示されます、//で正規表現が使えます

'-lx' オプションでインストールできないFormulaが表示されます、//で正規表現が使えます

'-i' オプションでインストール済みFormulaリストが表示されます

'-s' オプションでFormulaの検索ができます、//で正規表現が使えます

'-co' オプションでFormulaのライブラリーが表示されます

'-in' オプションでインストールに必要なFormulaが表示されます

'-t' オプションでインストールに必要なFormulaがtree表示されます

'-de' オプションでアンインストール後に必要ないFormulaが表示されます

'-d' オプションでアンインストール後に必要ないFormulaがtree表示されます

'-u' オプションでFormulaに依存しているインストール済みFormulaが表示されます

'-ua' オプションでFormulaに依存している全てのFormulaが表示されます

'-g' オプションで依存されてないFormulaが表示されます

'-o' オプションで brew outdated コマンド

'-' オプションで brew list コマンド

Only 　Mac : Cask

'-c' オプションでCaskリストが表示されます、//で正規表現が使えます

'-ct' オプションでCaskのTapリストが表示されます、//で正規表現が使えます

'-ci' オプションでCaskインストール済みリストが表示されます

'-cx' オプションでインストールできないCaskが表示されます、//で正規表現が使えます

'-cs' オプションで同名のFormulaとCaskが表示されます、//で正規表現が使えます

: 表示マーク

b マークはボトルインストールFormula

k マークはkeg_onlyのFormula

i マークはインストール済みFormula

(i) マークはバージョンアップのあるFormula

e マークはビルドできないFormula

x マークはインストールできないFormula

t マークはバージョンアップでインストール出来なくなったFormula

Onle Mac : Cask

s マークは同名のFormulaとCask : インストールには --caskオプション

f マークはFormulaを必要とするCask
