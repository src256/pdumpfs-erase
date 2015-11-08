pdumpfs-erase
==============

- pdumpfsのバックアップ内容から不要なファイルを削除するスクリプト。
- 年月日ベースで古いものを削除したり、指定のパスを削除したりできる。


## 実行環境

- Windows
- Ruby 2

Windowsのディククトリ削除コマンドを直接呼び出しているのでWindows以外では動作しません。

## インストール方法

pdumpfs-erase.rbを適当な場所にコピーして使ってください。

## 使用方法

時間単位でexpire
```
ruby pdumpfs-erase.rb -k 5Y12M24W30D R:\pc1\pdumpfs\d R:\pc1\pdumpfs\local R:\pc1\pdumpfs\users
```


## ライセンス

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)
