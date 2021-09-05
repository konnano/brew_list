brew list コマンド強化版

: 使用方法

ダウンロード後、brew_listフォルダー内で ./init.sh を実行して下さい

キャッシュファイル作成に少し時間がかかります、コマンドはbrew_listです

アンインストールはbrew_listフォルダー内で ./init.sh unlink

: オプション

'-l' オプションでFormulaリストが表示されます、//で正規表現が使えます

'-lb' オプションでボトルインストールFormulaが表示されます、//で正規表現が使えます

'-lx' オプションでインストールできないFormulaが表示されます、//で正規表現が使えます

'-i' オプションでインストール済みFormulaリストが表示されます

'-co' オプションでFormulaのライブラリーが表示されます

'-s' オプションでFormulaの検索ができます、//で正規表現が使えます

'-in' オプションでインストールに必要なFormulaが表示されます

'-t' オプションでインストールに必要なFormulaがtree表示されます

'-o' オプションで brew outdated コマンド

'-' オプションで brew list コマンド

Only 　Mac : Cask

'-c' オプションでCasksリストが表示されます、//で正規表現が使えます

'-ci' オプションでCasksインストール済みリストが表示されます

'-cx' オプションでインストールできないCaskが表示されます、//で正規表現が使えます

'-cs' オプションで同名のFormulaとCaskが表示されます、//で正規表現が使えます

: 表示マーク

b マークはボトルインストールFormula

k マークはkeg_onlyのFormula

i マークはインストール済みFormula

(i) マークはバージョンアップのあるFormula

e マークはビルドできないFormula

x マークはインストールできないFormula

t マークはtapでラップされたFormula

Onle Mac : Cask

s マークは同名のFormulaとCask : インストールには --caskオプション

f マークはFormulaを必要とするCask
