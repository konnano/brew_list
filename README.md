brew list コマンド拡張版 : version 1.11_4 　[English README is here ](https://github.com/konnano/brew_list/blob/main/README.en.md)

: 使用方法
```
brew tap konnano/brew_list

brew install brew_list
```
もしくはダウンロード後、brew_list-mainフォルダー内で ./init.sh を実行して下さい

キャッシュファイル作成に少し時間がかかります、コマンドは__brew_list__です

アンインストールはbrew_list-mainフォルダー内で ./init.sh unlink

デフォルトは英語表示です　./init.sh JA オプション追加で日本語表示されます

日本語版で英語表示させるにははbrew_list -l などで引数 ENにして下さい 正規表現は２番目の引数になります

: オプション

'-l' オプションでFormulaリストが表示されます、最初の引数でFormula検索、2番目の引数'.'で全文検索 

'-lb' オプションでボトルインストールFormulaが表示されます、//で正規表現が使えます

'-lx' オプションでインストールできないFormulaが表示されます、//で正規表現が使えます

'-i' オプションでインストール済みFormulaリストが表示されます

'-s' オプションでFormulaの検索ができます、//で正規表現が使えます

'-co' オプションでFormulaのライブラリーが表示されます

'-in' オプションでインストールに必要なFormulaが表示されます

'-t' オプションでインストールに必要なFormulaがtree表示されます

'-tt' オプションでインストールに必要なFormulaのみtree表示されます

'-de' オプションでアンインストール後に必要ないFormulaが表示されます

'-d' オプションでアンインストール後に必要ないFormulaがtree表示されます

'-dd' オプションでアンインストール後に必要ないFormulaのみがtree表示されます

'-ddd' オプションでアンインストールで必要ないFormulaを順番にアンインストール出来ます

　削除は　-ddや　-deでよく確認して下さい

'-u' オプションでFormulaに依存しているインストール済みFormulaが表示されます

'-ua' オプションでFormulaに依存している全てのFormulaが表示されます

'-ud' オプションでFormulaに依存されてるFormulaが表示されます

'-ul' オプションでFormulaに依存されてるFormulaの数が表示されます

'-is' オプションでFormulaのサイズ順に表示されます

'-g' オプションで依存されてないFormulaが表示されます

'-o' オプションで brew outdated コマンド

'-' オプションで brew list コマンド

'-ai' オプションで解析データ( 引数なし 365d,引数 1 30d,引数 2 90d )ソート

Only 　Mac : Cask

'-c' オプションでCaskリストが表示されます、最初の引数でFormula検索、2番目の引数'.'で全文検索 

'-ct' オプションでCaskのTapリストが表示されます、最初の引数でFormula検索、2番目の引数'.'で全文検索 

'-ci' オプションでCaskインストール済みリストが表示されます

'-cx' オプションでインストールできないCaskが表示されます、//で正規表現が使えます

'-cs' オプションで同名のFormulaとCaskが表示されます、//で正規表現が使えます

'-cd' オプションでCaskが必要とするCaskとFormulaが一覧表示されます

'-ac' オプションで解析データ( 引数なし 365d,引数 1 30d,引数 2 90d )ソート

: 表示マーク

b マークはボトルインストールFormula

k マークはkeg_onlyのFormula

i マークはインストール済みFormula

(i) マークはバージョンアップのあるFormula

e マークはダウンロードされてインストールされてないFormulaかビルドできないFormula

x マークはインストールできないFormula

t マークはバージョンアップでインストール出来なくなったFormula

Onle Mac : Cask

s マークは同名のFormulaとCask : インストールには --caskオプション

f マークはFormulaを必要とするCask

c マークはCaskaを必要とするCask
