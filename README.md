pdumpfs-erase
==============

- pdumpfsのバックアップ内容から不要なファイルを削除するスクリプト。
- 年月日ベースで古いものを削除したり、指定のパスを削除したりできる。


## 実行環境

以下の環境でテストしています。

- Windows 7
- Ruby 2 (RubyInstaller)

Windowsのディククトリ削除コマンドを直接呼び出しているので、今のところWindows以外では動作しません。

## インストール方法

pdumpfs-erase.rbを適当な場所にコピーして使ってください。

## 使用方法

時間単位で古いバックアップを削除する場合。直近の過去5年間の、年最初の1個目、12ヶ月間の月の最初の1個目、24週の週の最初1個目、30日間分を残す場合以下のように指定します。

```
ruby pdumpfs-erase.rb -k 5Y12M24W30D R:\pc1\pdumpfs\d R:\pc1\pdumpfs\local R:\pc1\pdumpfs\users
```

間違えて不要なフォルダをバックアップし、それを歴代のバックアップから完全に削除したい場合"-e"オプションを使います。

```
ruby pdumpfs-erase.rb -e home\sora\doc\BTSync R:\pc1\pdumpfs\d
```

"-n"オプションを追加して何が削除されるのか確認してから実行することをおすすめします。

## ライセンス

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)
