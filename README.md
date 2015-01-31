foldering
=========

# 何をするプログラムか

* 写真を日付でフォルダ分けしつつ、 db に写真ファイルの情報をDBへ保存
* 写真を、長辺を基準に 2048x2048 以下のサイズにリサイズ
* 保存してあるデータと比較してファイルが壊れていないかチェック

# 使い方

tmp フォルダ以下に処理したいファイル群を適当に置きます。

```ruby foldering move```

tmp 以下にある写真等を、
photo 以下に yyyy-mm-dd というフォルダを作って移動します。

ついでにハッシュ値等を photo/photo.db に保存します。
移動先のファイル名がかぶったら、ハッシュ値を比較して、同ファイルなら削除します。
.DS_Store, thumb.db などの os が排出するゴミファイルは削除します。
空になったフォルダは削除します。

```ruby foldering resize```

移動後の写真を対象に 2048x2048 以下にリサイズしつつ jpg にしたものを thumb/yyyy-mm-dd/FILE_NAME.CR2.jpg などの名前で保存します。
このネーミングの理由は、　xxx.NEF, xxx.CR2 が存在したとき対策です。
動画は対象としません。
2048x2048 なのは、iPad の長辺の解像度と Google 写真の無制限にアップロードできるサイズの都合です。

log/move.log に移動ログを書き出します。
log/resize.log にリサイズログを書き出します。

```ruby foldering validate```

db に保存されているハッシュ値と現在のファイルのハッシュ値を比較して、 db に保存したタイミングからファイルに変化がないかを確かめます。

# フォルダ構成
ファイルの移動（リサイズ）後は、以下のようになります。

* ROOT/tmp/FOLDER/IMAGE_FILE

から

* ROOT/photo/photo.db
* ROOT/photo/yyyy-mm-dd/FILE_NAME.EXT
* ROOT/thumb/yyyy-mm-dd/FILE_NAME.EXT.jpg

になります。

resized フォルダでなく thumb フォルダなのは、ターミナルでの補完機能で使いやすくするため。

