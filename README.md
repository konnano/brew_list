brew list コマンド拡張版

: 使用方法

```
brew install konnano/brew_list/brew_list
```

![brew-ezgif com-video-to-gif-converter](https://github.com/konnano/brew_list/assets/73874687/10f3a2f8-9c02-46dc-a759-71a76304f131)


コマンドは<strong>`bl`</strong>です

デフォルトは英語表示です　 bl -JA オプションで日本語表示されます

日本語版で英語表示させるにははbl -l などで引数 ENにして下さい 正規表現は２番目の引数になります

: オプション

'-l' オプションでFormulaリストが表示されます、最初の引数でFormula検索、2番目の引数'.'で全文検索 

'-lb' オプションでボトルインストールFormulaが表示されます、//で正規表現が使えます

'-lx' オプションでインストールできないFormulaが表示されます、//で正規表現が使えます

'-i' オプションでインストール済みFormulaリストが表示されます

'-s' オプションでFormulaの検索ができます、//で正規表現が使えます

'-ss' オプションでFormulaの検索ができます(インストール出来ないFormulaを隠す)、//で正規表現が使えます

'-co' オプションでFormulaのライブラリーが表示されます

'-in' オプションでインストールに必要なFormulaが表示されます

'-t' オプションでインストールに必要なFormulaがtree表示されます

'-tt' オプションでインストールに必要なFormulaのみtree表示されます

'-de' オプションでアンインストール後に必要ないFormulaが表示されます<br/>
  アンインストールしないフォーミュラは２番目の引数に記入して下さい
            
'-d' オプションでアンインストール後に必要ないFormulaがtree表示されます<br/>
  アンインストールしないフォーミュラは２番目の引数に記入して下さい

'-dd' オプションでアンインストール後に必要ないFormulaのみがtree表示されます<br/>
  アンインストールしないフォーミュラは２番目の引数に記入して下さい

'-ddd' オプションでアンインストールで必要ないFormulaを順番にアンインストール出来ます
<br>  アンインストールしないフォーミュラは２番目の引数に記入して下さい

　#### 削除は　-ddや　-deでよく確認して下さい ####

'-u' オプションでFormulaに依存しているインストール済みFormulaが表示されます

'-ua' オプションでFormulaに依存している全てのFormulaが表示されます

'-ud' オプションでFormulaに依存されてるFormulaが表示されます、2番目の引数'.'で依存を必要としないFormula

'-ul' オプションでFormulaに依存されてるFormulaの数が表示されます

'-is' オプションでFormulaのサイズ順に表示されます

'-g' オプションで依存されてないFormulaが表示されます

'-o' オプションで brew outdated コマンド

'-' オプションで brew list コマンド

'-ai' オプションで解析データ ( 引数 [0-8] ソート ) もしくはFormula

Only 　Mac : Cask

'-c' オプションでCaskリストが表示されます、最初の引数でFormula検索、2番目の引数'.'で全文検索 

'-cf' オプションでFontリストが表示されます、最初の引数でFormula検索、2番目の引数'.'で全文検索 

'-ci' オプションでCaskインストール済みリストが表示されます

'-cx' オプションでインストールできないCaskが表示されます、//で正規表現が使えます

'-cs' オプションで同名のFormulaとCaskが表示されます、//で正規表現が使えます

'-cd' オプションでCaskが必要とするCaskとFormulaが一覧表示されます

'-ac' オプションで解析データ ( 引数 [0-2] ソート ) もしくはCask 

'-p' オプションでFontをQuickLookプレビューできます ( 不安定 ) タブ補完できます

'-cfp' オプションでQuickLookプレビューできるFontリストが表示されます

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

p マークはQuickLookでプレビューできるFont
