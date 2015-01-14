foldering
=========

# 何をするプログラムか
写真を日付でフォルダ分けしつつ、 db に写真ファイルの情報をDBへ保存

# 使い方

tmp フォルダ以下に処理したいファイル群を適当に置きます。

```ruby sort.rb```

で、
tmp 以下にある写真等を、
photo 以下に yyyy-mm-dd というフォルダを作って移動します。

ついでにハッシュ値等を photo/photo.db に保存します。
移動先のファイル名がかぶったら、ハッシュ値を比較して、同ファイルなら削除します。
# TODO cache/queue.db に異動したファイルの相対パスを保存します。
# TODO .DS_Store, thumb.db などの os が排出するゴミファイルは削除します。
# TODO 空になったフォルダは削除します。

# TODO 写真を 2048x2048 以下にリサイズしつつ jpg にしたものを resized/yyyy-mm-dd/FILE_NAME.CR2.jpg などの名前で保存します。
このネーミングの理由は、　xxx.NEF, xxx.CR2 が存在したとき対策です。
動画はリサイズしません。

log/batch.log にログを書き出します。

# ROOT/tmp/FOLDER/IMAGE_FILE
# ROOT/photo/photo.db
# ROOT/photo/yyyy-mm-dd/FILE_NAME.EXT
# ROOT/resized/queue.db
# ROOT/resized/yyyy-mm-dd/FILE_NAME.EXT.jpg
