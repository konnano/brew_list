brew list コマンド強化版

: 使用方法

ダウンロード後、brew_listフォルダー内で ./init.sh を実行して下さい

~/.BREW_LIST フォルダが作られ font.sh と tie.pl がコピーされます

brew_list.pl が Macは /usr/local/bin/brew_list にコピーされます

Linuxは /home/linuxbrew/.linuxbrew/bin/brew_list にコピーされます

キャッシュファイル作成に少し時間がかかります

アンインストールはbrew_listフォルダー内で ./init.sh unlink

: オプション

'-l' オプションでFormulaリストが表示されます、//で正規表現が使えます

'-lb' オプションでボトルインストールFormulaが表示されます、//で正規表現が使えます

'-lx' オプションでインストールできないFormulaが表示されます、//で正規表現が使えます

'-in' オプションでインストールに必要なFormulaが表示されます

'-i' オプションでインストール済みFormulaリストが表示されます

'-s' オプションでFormulaの検索ができます、//で正規表現が使えます

'-co' オプションでFormulaのライブラリーが表示されます

'-' オプションで brew list コマンド

Only 　Mac : Cask

'-c' オプションでCasksリストが表示されます、//で正規表現が使えます

'-ci' オプションでCasksインストール済みリストが表示されます

'-cx' オプションでインストールできないCaskが表示されます、//で正規表現が使えます

'-cs' オプションで同名のFormulaとCaskが表示されます、//で正規表現が使えます

: 表示マーク

bマークはボトルインストールFormula

kマークはkeg_onlyのFormula

iマークはインストール済みFormula

(i)マークはバージョンアップのあるFormula

xマークはインストールできないFormula

tマークはtapでラップされたFormula

Onle Mac : Cask

s マークは同名のFormulaとCask : インストールには --caskオプション

f マークはFormulaを必要とするCask
