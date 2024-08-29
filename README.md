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

- ### オプション

-l : オプション  
Formulaのリストを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はFormulaや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-lb : オプション  
ボトルインストールFormulaのリストを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はFormulaや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-lx : オプション  
インストー出来ないFormulaのリストを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はFormulaや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-i : オプション  
インストール済みFormulaのリストを表示します  
( Linuxならtap linux-fontsも含まれます )

-s : オプション  
FormulaかCaskかFontを検索します  
引数はFormulaかCaskかFont、もしくは正規表現です //

-ss : オプション  
インストール出来るFormulaかCaskのみや、Fontを検索します  
引数はFormulaかCaskかFont、もしくは正規表現です //

-co : オプション  
Formulaのライブラリーを表示します  
最初の引数はFormulaです、2番目の引数 .(dot) で $(brew --prefix)/bin 以下のみを表示します

-in : オプション  
インストールに必要なFormulaやCaksをリスト表示します  
引数はFormulaかCaskです

-t : オプション  
インストールに必要なFormulaやCaskをTree表示します  
引数はFormulaかCaskです

-tt : オプション  
インストールに必要なFormulaやCaskのみをTree表示します  
引数はFormulaかCaskです

-de : オプション  
アンインストール後に必要ないFormulaやCaskをリスト表示します  
最初の引数はアンインストールするFormulaかCaskです  
アンインストールしないFormulaやCaskは２番目以降の引数になります

-d : オプション  
アンインストール後に必要ないFormulaやCaskをTree表示します  
最初の引数はアンインストールするFormulaかCaskです  
アンインストールしないFormulaやCaskは２番目以降の引数になります  
２番目の引数に .(dot) で Build Formulaも含まれます、その場合は  
アンインストールしないFormulaやCaskは３番目以降の引数になります

-dd : オプション  
アンインストール後に必要ないFormulaやCaskのみをTree表示します  
最初の引数はアンインストールするFormulaかCaskです  
アンインストールしないFormulaやCaskは２番目以降の引数になります  
２番目の引数に .(dot) で Build Formulaも含まれます、その場合は  
アンインストールしないFormulaやCaskは３番目以降の引数になります

-ddd : オプション  
アンインストールで必要ないFormulaやCaskを順番にアンインストール出来ます  
最初の引数はアンインストールするFormulaかCaskです  
アンインストールしないFormulaやCaskは２番目以降の引数になります  
２番目の引数に .(dot) で Build Formulaも含まれます、その場合は  
アンインストールしないFormulaやCaskは３番目以降の引数になります

　#### 削除は　-ddや　-deでよく確認して下さい ####

-u : オプション  
Formulaに依存してるインストール済みのFormulaを表示します、引数はFormulaです

-bu : オプション  
Formulaにビルド依存してるFormulaを表示します、引数はFormulaです

-ua : オプション  
Formulaに依存している全てのFormulaを表示します、引数はFormulaです

-ud : オプション  
Formulaに依存されてるFormulaを表示します  
引数が無けれはインストールされてる全てのFormulaを表示します  
最初の引数でFormulaを指定すると、そのFormulaのみを表示します  
最初の引数が .(dot) の場合は依存を必要としないFormulaを表示します

-ul : オプション  
Formulaに依存されてるFormulaの数を表示します  
引数が無けれはインストールされてる全てのFormulaを表示します  
最初の引数でFormulaを指定すると、そのFormulaのみの数を表示します

-is : オプション  
Formulaをサイズ順で表示します  
引数が無けれはインストールされてる全てのFormulaを表示します  
最初の引数でFormulaを指定すると、そのFormulaに依存するFormulaのみを表示します  
bl -is|sort -t : -k 3 でパイプすればインストールの日付順にソートされます

-g : オプション  
依存されてないFormulaやCask及びFontを表示します  
bl -g|cat でパイプすれば brew leaves (Cask込み) になります  
( Linuxならtap linux-fontsも含まれます )

-o : オプション  
brew outdated コマンドです  
最初の引数 .(dot) で、outdated があればインストールされます

\- : オプション  
brew list(高速) コマンドです  
( Linuxならtap linux-fontsも含まれます )

-ai : オプション  
Formulaの解析データを表示します  
引数が無ければ less で表示されます、終了は q になります  
( 引数 [0-8]でソートします ) もしくはFormulaです

-m : オプション  
別の検索端末を開きます、カーソル移動はvimと同じです、終了は q になります

Only Mac : Cask

-c : オプション  
Caskのリストを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はCaskや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-cf : オプション  
Fontのリストを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はFontや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-ci : オプション  
インストール済みのCaskやFontをリスト表示します

-cx : オプション  
インストール出来ないCaskを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はCaskや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-cs : オプション  
同名のFormulaとCaskを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はCaskや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

-cd : オプション  
Caskが必要とするCaskとFormulaをTree表示します

<details><summary>bl -cd ( Caskの依存関係です )</summary>

```
  [ require Cask and Formula ]
ace-link	VLCプレーヤーでAce Streamビデオストリームを再生できるメニューバーアプリ
├── c vlc	マルチメディアプレーヤー
└── c docker	コンテナ化されたアプリケーションとマイクロサービスを構築して共有する為のアプリ

betterdiscord-installer	BetterDiscordのインストーラー
└── c discord	音声及びテキストチャットソフトウェア

bricklink-partdesigner	独自のLEGOパーツをデザインする
└── c bricklink-studio	LEGOの指示を作成します 建てる/表現する

brl-cad-mged	BRL-CAD
└── c xquartz (I)	X.OrgXウィンドウシステムのオープンソースバージョン

 exists Formula and Cask ckan....
ckan	Kerbal Space ProgramのMod管理ソリューション
└── c mono-mdk	Microsoftの.NETFrameworkのオープンソース実装

dia	構造図を描く
└── c xquartz (I)	X.OrgXウィンドウシステムのオープンソースバージョン

docker-toolbox	Dockerツールボックス
└── c virtualbox	x86ハードウェア用のバーチャライザー

droidcam-obs	OBS Studioで携帯電話を直接カメラとして使用する
└── c obs	ライブストリーミングと画面録画用のオープンソースソフトウェア

endless-sky-high-dpi	Endless Sky用の、High-DPIプラグイン
└── c endless-sky	宇宙探査 取引と戦闘ゲーム

 Can't install free-gpgmail...
free-gpgmail	GnuPG暗号化電子メール用のApple Mailプラグイン
└── c gpg-suite-no-mail	ファイルを保護する為のツール

 exists Formula and Cask fs-uae....
fs-uae	Amigaエミュレーター
└── c fs-uae-launcher	Amigaエミュレータランチャー

godot-mono	2D/3D ゲームエンジン
└── c dotnet-sdk	開発者向けプラットフォーム

gstreamer-development	オープンソースのマルチメディアフレームワーク
└── c gstreamer-runtime	オープンソースのマルチメディアフレームワーク

inkstitch	機械刺繍デザイン用のInkscape拡張
└── c inkscape	ベクターグラフィックエディター

 Can't install intune-company-portal...
intune-company-portal	企業アプリへのアクセスを管理するアプリ データ/リソース
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

kactus	デザイナーの為の真のバージョン管理ツール
└── c sketch	デジタルデザイン及びプロトタイピングプラットフォーム

lando	Docker上に構築されたローカル開発環境とDevOpsツール
└── c docker	コンテナ化されたアプリケーションとマイクロサービスを構築して共有する為のアプリ

lando@edge	Docker上に構築されたローカル開発環境とDevOpsツール
└── c docker	コンテナ化されたアプリケーションとマイクロサービスを構築して共有する為のアプリ

lazarus	迅速なアプリケーション開発の為のIDE
├── c fpc-laz	Lazarus用のPascalコンパイラ
└── c fpc-src-laz	Lazarus用のPascalコンパイラソースファイル

 Can't install libreoffice-language-pack...
libreoffice-language-pack	LibreOfficeの代替言語のコレクション
└── c libreoffice	Freeのクロスプラットフォームオフィスパッケージ、最新バージョン

 Can't install libreoffice-still-language-pack...
libreoffice-still-language-pack	LibreOfficeの代替言語のコレクション
└── c libreoffice-still	Freeのクロスプラットフォームオフィスパッケージ、安定版は企業に推奨

microsoft-excel	表計算ソフトウェア
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

 Can't install microsoft-office...
microsoft-office	オフィスパッケージ
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

 Can't install microsoft-office-businesspro...
microsoft-office-businesspro	オフィスパッケージ
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

microsoft-outlook	メールクライアント
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

microsoft-powerpoint	プレゼンテーションソフトウェア
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

 Can't install microsoft-teams...
microsoft-teams	会う/チャット/電話 1ケ所で会議
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

microsoft-word	ワードプロセッサ
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

mkchromecast	オーディオ/ビデオ をGoogle Cast及びSonosデバイスにキャストする為のツール
└── c soundflower	サウンドフラワー

ncar-ncl (I)	科学データの分析と視覚化の為の通訳言語
├── c xquartz (I)	X.OrgXウィンドウシステムのオープンソースバージョン
└── f gcc (I)	GNUコンパイラコレクション

nordic-nrf-command-line-tools	Nordic nRF Semiconductors用のコマンドライン ツール
└── c segger-jlink	Segger J-Linkデバッグプローブ用のソフトウェア及びドキュメントパック

obs-advanced-scene-switcher	OBS Studioの自動シーンスイッチャー
└── c obs	ライブストリーミングと画面録画用のオープンソースソフトウェア

obs-ndi	OBS Studio用のNewTek NDI統合
└── c libndi	NDI SDK

 Can't install pieces...
pieces	コードスニペット、スクリーンショット、ワークフローコンテキスト
└── c pieces-os	Pieces for Developersセットを強化する ローカルデータストア/サーバー/MLエンジン

skype-for-business	Microsoftのインスタントメッセージングエンタープライズソフトウェア
└── c microsoft-auto-update	さまざまなMicrosoft製品の更新を提供します

softube-central	Softube製品のインストールとライセンスアクティベーション用のインストーラー
└── c ilok-license-manager	iLokデバイス用のソフトウェア

sonarr-menu	Sonarrを管理する為のメニューをステータスバーに追加するユーティリティ
└── c sonarr	Usenet及びBitTorrentユーザー向けのPVR

sonarr@beta	Usenet および BitTorrent ユーザー向けの PVR
└── c mono-mdk	Microsoftの.NETFrameworkのオープンソース実装

unity	3Dコンテンツ用のプラットフォーム
└── c unity-hub	Unityの管理ツール

unity-android-support-for-editor	UnityのAndroidターゲットサポート
└── c unity	3Dコンテンツ用のプラットフォーム

unity-ios-support-for-editor	UnityのiOSターゲットサポート
└── c unity	3Dコンテンツ用のプラットフォーム

unity-webgl-support-for-editor	UnityのWebGLターゲットサポート
└── c unity	3Dコンテンツ用のプラットフォーム

unity-windows-support-for-editor	UnityのWindows(Mono)ターゲットサポート
└── c unity	3Dコンテンツ用のプラットフォーム

universal-android-debloater	ルート権限を取得していないAndroidデバイスをデブロートする為にADBを使用するGUI
└── c android-platform-tools	AndroidSDKコンポーネント

veracrypt	TrueCryptに基づくセキュリティに焦点を当てたディスク暗号化ソフトウェア
└── c macfuse	ファイルシステム統合

 Can't install visual-studio...
visual-studio	統合開発環境
└── c mono-mdk-for-visual-studio	Microsoftの.NET Frameworkのオープンソース実装

 Can't install wine-stable...
wine-stable	Windowsアプリケーションを実行する為の互換性レイヤー
└── c gstreamer-runtime	オープンソースのマルチメディアフレームワーク

 Can't install wine@devel...
wine@devel	Windows アプリケーションを実行するための互換レイヤー
└── c gstreamer-runtime	オープンソースのマルチメディアフレームワーク

 Can't install wine@staging...
wine@staging	Windows アプリケーションを実行するための互換レイヤー
└── c gstreamer-runtime	オープンソースのマルチメディアフレームワーク

xamarin-mac	C#/.NET開発者にアクセスを提供します Objective-C/Swift API
└── c mono-mdk-for-visual-studio	Microsoftの.NET Frameworkのオープンソース実装

  [ require Formula ]
 Can't install applite...
applite	Homebrew用のユーザーに親しいGUIアプリ
└── f pinentry-mac	MacでのGPGのPinentry

aptible	Aptible Deployのコマンドラインツール 監査対応のアプリ導入プラットフォーム
└── f libfido2 (I)	USBを含むFIDO U2F及びFIDO 2.0のライブラリ機能を提供します

displaycal	Argyll CMSによるディスプレイのキャリブレーションと特性評価
└── f argyll-cms	ICC互換のカラーマネジメントシステム

dmidiplayer	マルチプラットフォームMIDIファイルプレーヤー
└── f fluid-synth	SoundFont2仕様に基づくリアルタイムソフトウェアシンセサイザー

doteditor	graphvizで使用されるDot言語用のGUIエディター
└── f graphviz (I)	AT＆T/ベル研究所のdotグラフ視覚化ソフトウェア

duplicati	安全に暗号化されたバックアップをクラウドに保存する
└── f mono	クロスプラットフォーム、オープンソースの.NET開発フレームワーク

geotag	画像のGeoロケーションエディター
└── f exiftool	EXIFメタデータを読み書きする為のPerlライブラリ

goneovim	Golangqtバックエンドを使用してGolangで記述されたNeovim GUI
└── f neovim	拡張性と敏捷性に焦点を当てた野心的なVimフォーク

google-cloud-sdk	Google Cloudでホストされているリソースとアプリケーションを管理する為のツールのセット
└── f python@3.12 (I)	オブジェクト指向プログラミング言語 インタプリタ/対話的

 Can't install gpgfrontend...
gpgfrontend	OpenPGP/GnuPG暗号 サインと鍵の管理ツール
└── f gnupg	GNU Pretty Good Privacy(PGP)パッケージ

 Can't install ibabel...
ibabel	Cheminformaticsツールキット、OpenBabelのGUI
└── f open-babel	化学ツールボックス

kapitainsky-rclone-browser	Rcloneブラウザー
└── f rclone	クラウドストレージ用のRsync

katrain	ゲームを分析して遊ぶ為のツールはKataGoからのAIフィードバックに対応しています
└── f katago	人間が提供する知識を使用しないニューラルネットワークGoエンジン

kiibohd-configurator	モジュラーコミュニティキーボードファームウェア
└── f dfu-util	USB programmer

 Can't install mactex...
mactex	GUIアプリケーションを使用した完全なTeX Liveディストリビューション
└── f ghostscript (I)	PostScriptとPDFのインタプリタ

 Can't install mactex-no-gui...
mactex-no-gui	GUIアプリケーションを使用しない完全なTeX Liveディストリビューション
└── f ghostscript (I)	PostScriptとPDFのインタプリタ

markdown-service-tools	マークダウン形式のテキストのサービスのコレクション
└── f multimarkdown	マークアップされたプレーンテキストを適切な形式のドキュメントに変換する

metasploit	侵入テストフレームワーク
└── f nmap	大規模ネットワーク用のポートスキャンユーティリティ

n1ghtshade	32ビットiOSデバイスの ダウングレード/脱獄を許可します
├── f libimobiledevice	iOSデバイスとネイティブに通信する為のライブラリ
├── f libirecovery	USB経由で iBoot/iBSS と通信する為のライブラリとユーティリティ
├── f libplist	AppleのバイナリとXML属性リスト用のライブラリ
├── f libusb	USBデバイスアクセス用のライブラリ
├── f libusbmuxd	iOSデバイス用のUSB multiplexor
├── f libzip (I)	読む為のCライブラリ 作成/zipアーカイブの変更
└── f openssl (I)	暗号化/SSL/TLS ツールキット

 exists Formula and Cask neovide....
neovide	Neovimクライアント
└── f neovim	拡張性と敏捷性に焦点を当てた野心的なVimフォーク

panwriter	Pandoc統合とページ化されたプレビューを備えたMarkdownエディター
└── f pandoc	マークアップ形式変換の万能ナイフ

 Can't install powershell...
powershell	コマンドラインシェルとスクリプト言語
└── f openssl (I)	暗号化/SSL/TLS ツールキット

 Can't install powershell@preview...
powershell@preview	コマンドラインシェルとスクリプト言語
└── f openssl (I)	暗号化/SSL/TLS ツールキット

 Can't install qv2ray...
qv2ray	広範な手続きをサポートするV2Ray GUIクライアント
└── f v2ray	ネットワーク制限をバイパスするプロキシを構築する為のプラットフォーム

rclone-browser	Rcloneブラウザー
└── f rclone	クラウドストレージ用のRsync

slack-cli	Slackアプリを作成/実行/デプロイするCLI
└── f deno	JavaScriptとTypeScriptの安全なランタイム

streamlink-twitch-gui	Streamlink用のマルチプラットフォームTwitch.tvブラウザー
└── f streamlink	さまざまなWebサイトからビデオプレーヤーにストリームを抽出する為のCLI

superslicer	3DモデルをGコード命令又はPNGレイヤーに変換します
└── f zstd (I)	Zstandardはリアルタイム圧縮アルゴリズムです

vmpk	仮想MIDIピアノキーボード
└── f fluid-synth	SoundFont2仕様に基づくリアルタイムソフトウェアシンセサイザー

vv	Neovimクライアント
└── f neovim	拡張性と敏捷性に焦点を当てた野心的なVimフォーク
```

</details>

-ac : オプション  
Caskの解析データを表示します  
引数が無ければ less で表示されます、終了は q になります  
( 引数 [0-2]でソートします ) もしくはCaskです

-p : オプション  
FontをQuickLookプレビュー出来ます( 不安定 )  
引数はFontです、zshシェルならタブ補完が出来ます

-cfp : オプション  
QuickLookプレビューできるFontリストを表示します  
引数が無ければ全てのリストを表示します  
最初の引数はFontや正規表現です // 、2番目の引数 .(dot) で全文検索出来ます

- ### 表示マーク

b : マークはボトルインストール出来るFormulaです

k,kp : マークはkeg_onlyのFormulaです

i : マークはインストール済みFormulaやCaskです

(i) : マークはバージョンアップのあるFormulaやCaskです

e : マークはダウンロード後インストールされてないFormulaかビルド出来ないFormulaです

x,d : マークはインストール出来ないFormulaやCaskです

t : マークはバージョンアップでインストール出来なくなったFormulaやCaskです

Only Mac : Cask

s : マークは同名のFormulaとCaskです : インストールには --caskオプション

f : マークはFormulaを必要とするCaskです

c : マークはCaskaを必要とするCaskです

p : マークはQuickLookでプレビューできるFontです
