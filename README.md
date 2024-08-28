brew list コマンド拡張版(高速)

: 使用方法

```
brew install konnano/brew_list/brew_list
```

![brew-ezgif com-video-to-gif-converter](https://github.com/konnano/brew_list/assets/73874687/10f3a2f8-9c02-46dc-a759-71a76304f131)


コマンドは<strong>`bl`</strong>です


デフォルトは英語表示です bl -JA オプションで  
~/.JA_BREWがインストールされ日本語表示されます

日本語版で英語表示させるには bl -l などで最初の引数をENにして下さい  
Formulaや正規表現 // は２番目の引数です .(dot) の全文検索は３番目の引数になります

 ##### オプション

-l : オプションでFormulaのリストが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はFormulaや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-lb : オプションでボトルインストールFormulaのリストが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はFormulaや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-lx : オプションでインストー出来ないFormulaのリストが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はFormulaや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-i : オプションでインストール済みFormulaのリストが表示されます

-s : オプションでFormulaかCaskかFontを検索します  
引数はFormulaかCaskかFont、もしくは正規表現です //

-ss : オプションでインストール出来るFormulaかCaskのみや、Fontを検索します  
引数はFormulaかCaskかFont、もしくは正規表現です //

-co : オプションでFormulaのライブラリーが表示されます  
最初の引数はFormulaです、2番目の引数 .(dot) で $(brew --prefix)/bin 以下のみを表示します

-in : オプションでインストールに必要なFormulaやCaksがリスト表示されます  
引数にFormulaかCaskを記入して下さい

-t : オプションでインストールに必要なFormulaやCaskがTree表示されます  
引数にFormulaやCaskを記入して下さい

-tt : オプションでインストールに必要なFormulaやCaskのみがTree表示されます  
引数にFormulaやCaskを記入して下さい

-de : オプションでアンインストール後に必要ないFormulaやCaskがリスト表示されます  
最初の引数はFormulaやCaskです、アンインストールしないFormulaやCaskは２番目の引数に記入して下さい

-d : オプションでアンインストール後に必要ないFormulaやCaskがTree表示されます  
最初の引数はFormulaやCaskです、アンインストールしないFormulaやCaskは２番目以降の引数に記入して下さい  
２番目の引数に .(dot) を記入すればBuild Formulaも含まれます、その場合は  
アンインストールしないFormulaやCaskは３番目以降の引数に記入して下さい

-dd : オプションでアンインストール後に必要ないFormulaやCaskのみがTree表示されます  
最初の引数はFormulaやCaskです、アンインストールしないFormulaやCaskは２番目以降の引数に記入して下さい  
２番目の引数に .(dot) を記入すればBuild Formulaも含まれます、その場合は  
アンインストールしないFormulaやCaskは３番目以降の引数に記入して下さい

-ddd : オプションでアンインストールで必要ないFormulaやCaskを順番にアンインストール出来ます  
最初の引数はFormulaやCaskです、アンインストールしないFormulaやCaskは２番目以降の引数に記入して下さい  
２番目の引数に .(dot) を記入すればBuild Formulaも含まれます、その場合は  
アンインストールしないFormulaやCaskは３番目以降の引数に記入して下さい

　#### 削除は　-ddや　-deでよく確認して下さい ####

-u : オプションでFormulaに依存しているインストール済みFormulaが表示されます、引数はFormulaです

-ua : オプションでFormulaに依存している全てのFormulaが表示されます、引数はFormulaです

-ud : オプションでFormulaに依存されてるFormulaが表示されます  
引数が無けれはインストールされてる全てのFormulaが表示されます  
最初の引数でFormulaを指定すると、そのFormulaのみを表示します  
最初の引数が .(dot) の場合は依存を必要としないFormulaが表示されます

-ul : オプションでFormulaに依存されてるFormulaの数が表示されます  
引数が無けれはインストールされてる全てのFormulaが表示されます  
最初の引数でFormulaを指定すると、そのFormulaのみを表示します

-is : オプションでFormulaがサイズ順で表示されます  
引数が無けれはインストールされてる全てのFormulaが表示されます  
最初の引数でFormulaを指定すると、そのFormulaが必要とするFormulaのみを含めて表示します  
bl -is|sort -t : -k 3 でパイプすればインストールの日付順にソートされます

-g : オプションで依存されてないFormulaが表示されます  
bl -g|cat でパイプすれば brew leaves になります(Cask込み)

-o : オプションで brew outdated コマンド  
最初の引数で .(dot) で、outdated があればインストールされます

\- : オプションで brew list(高速) コマンド

-ai : オプションでFormulaの解析データが表示されます  
引数が無ければ less で全て表示されます  
( 引数 [0-8]でソートします ) もしくはFormulaです

-m : オプションで別の検索端末を開きます、カーソル移動はvimと同じです、終了は q になります

Only Mac : Cask

-c : オプションでCaskのリストが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はCaskや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-cf : オプションでFontのリストが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はFontや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-ci : オプションでインストール済みのCaskやFontがリスト表示されます

-cx : オプションでインストール出来ないCaskが表示されます  
引数が無ければ全て表示されます  
最初の引数はCaskや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-cs : オプションで同名のFormulaとCaskが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はCaskや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-cd : オプションでCaskが必要とするCaskとFormulaがTree表示されます

-ac : オプションでCaskの解析データが表示されます  
引数が無ければ less で全て表示されます  
( 引数 [0-2]でソートします ) もしくはCaskです

-p : オプションでFontをQuickLookプレビューできます ( 不安定 )  
引数はFontです、タブ補完が出来ます

-cfp : オプションでQuickLookプレビューできるFontリストが表示されます  
引数が無ければ全てリスト表示されます  
最初の引数はFontや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

 ##### 表示マーク

b : マークはボトルインストール出来るFormulaです

k,kp : マークはkeg_onlyのFormulaです

i : マークはインストール済みFormulaやCaskです

(i) : マークはバージョンアップのあるFormulaやCaskです

e : マークはダウンロードされてインストールされてないFormulaかビルドできないFormulaです

x,d : マークはインストールできないFormulaやCaskです

t : マークはバージョンアップでインストール出来なくなったFormulaやCaskです

Only Mac : Cask

s : マークは同名のFormulaとCaskです : インストールには --caskオプション

f : マークはFormulaを必要とするCaskです

c : マークはCaskaを必要とするCaskです

p : マークはQuickLookでプレビューできるFontです
