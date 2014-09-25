foldering
=========

# 何をするプログラムか
あるフォルダ以下の（自分で撮影した）写真や動画を撮影日付でフォルダを作成して、そこに移動する。

# 使い方

```ruby create_table.rb```

で photo.db という sqlite3 の db を作成します。

```ruby main.rb FROM_DIR TO_DIR```

で、
FROM_DIR 内にある写真等を、
TO_DIR の下に yyyy/mm/dd/
というフォルダを作って、そこに移動します。
