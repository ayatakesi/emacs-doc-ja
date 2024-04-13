# emacs-doc-ja
GNU Emacsに同梱されているマニュアルを日本語化するためのメッセージカタログを保守するためのリポジトリです。

# 機能
当該リポジトリが提供するファイルとオリジナルの対応文書をpo4a, gettext等のOSSプログラムにより日本語化します。

> [!CAUTION]
> 日本語化に使用するプログラム、特に日本語化の核ともいえるpo4aについてはバージョン間の互換性が乏しく、更に新たなバージョンの付与に関する法則性がまったく予期できないため、Github Actionsでのビルドを優先するために、`ubuntu-latest`の`apt`でインストールされるバージョンを使用することにします。

# 使い方
日本語化したいバージョンのタグをチェックアウトしたら`make all`で英語の`*.texi`が`*-ja.texi`に日本語化されます。

# 利用方法
日本語化した`*-ja.texi`は通常のtexiを処理するコマンドで処理して、種々フォーマットの文書を作成できます。例は`japanese_texis/Makefile.example`を参照してください(`make -f Makefile.example info`とでもして試すこともできます)。

# Hacking
日本語texiの生成は翻訳前のtexi(`original_texis`配下のtexi)とPOファイルを入力に作成しています。当該リポジトリのみで日本語化を完結できるように必要な翻訳前のtexiをリポジトリ内に保有していますが、`emacs/Makefile`や`lispref/Makefile`でシェル関数の引数に`original_texis`を指定している箇所を変更すれば、別の場所(たとえばネットで入手したtarballで展開された`$TARBALL_ROOT/doc/emacs`)を指定して実行することもできます。
