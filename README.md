　:　使用方法

ダウンロード後フォルダー内で ./brew_list -l を実行して下さい

~/.BREW_LIST フォルダが作られ font.sh と tie.pl がコピーされます

キャッシュファイル作成に少し時間がかかります

/opt 配下にインストールされたHomebrewには対応してません

(Apple M1 持ってないので仕様がわかりません、パスなど詳しい部分教えて下さい)

アンインストールは ~/.BREW_LIST フォルダを削除して下さい

　: オプション

'-l' オプションでFormulaリストが表示されます、//で正規表現が使えます

'-i' オプションでFormulaインストール済みリストが表示されます

'-s' オプションで検索リストが表示されます、//で正規表現が使えます

'-co' オプションでライブラリーが表示されます

'-' オプションで brew list コマンド

Only Mac

'-c' オプションでCasksリストが表示されます、//で正規表現が使えます

'-ci' オプションでCasksインストール済みリストが表示されます

　： 表示マーク

bマークはボトルインストールフォーミュラ

kマークはkeg_onlyフォーミュラ

iマークはインストール済みフォーミュラ

(i)マークはバージョンアップのあるフォーミュラ

xマークはインストールできないフォーミュラ

tマークはtapでラップされたフォーミュラ
