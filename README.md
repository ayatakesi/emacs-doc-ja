# emacs-doc-ja
GNU Emacsに同梱されているマニュアルを日本語化するためのメッセージカタログを保守するためのリポジトリです。

# 機能
当該リポジトリが提供するファイルとオリジナルの対応文書をpo4a, gettext等のOSSプログラムにより日本語化します。

# 使い方
日本語化したいバージョンのタグをチェックアウトしたら`make all`で英語の`*.texi`が`*-ja.texi`に日本語化されます。

# 利用方法
日本語化した`*-ja.texi`は通常のtexiを処理するコマンドで処理して、種々フォーマットの文書を作成できます。例は`japanese_texis/Makefile.example`を参照してください(`make -f Makefile.example info`とでもして試すこともできます)。
