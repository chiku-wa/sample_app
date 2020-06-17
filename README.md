# Railsチュートリアルのサンプルアプリケーションです

このアプリケーションは、以下の教材をもとに作成したサンプルアプリケーションです。
[*Ruby on Railsチュートリアル*](https://railstutorial.jp)

### ■ライセンス
[*Ruby on Railsチュートリアル*](https://railstutorial.jp)内にあるソースコードはMITライセンス(著作権表記を記しておけば自由に改造、使用することができる)と、Beerwareライセンス(開発者に出会った時にビールを奢ることができる権利)のもとで公開されています。
詳細は[LICENSE.md](LICENSE.md)を参照してください。

### ■使い方

#### 1.Gitリポジトリをクローンする
まずは手元のローカルPCにこのリポジトリをcloneしてください。

#### 2.bundle installする
以下のコマンドを実行して、bundle installしてください。この時、ローカルPCは開発環境とするため、productionでしか使用しないgemはインストールしないように--without productionオプションを付与します。
```bash
$ bundle install --without production
```

#### 3.マイグレーションを実行する
以下のコマンドでDBに対してマイグレーションを実行します。
```bash
$ rails db:migrate
```

#### 4.テストを実行する
以下のコマンドでテストを実行してください。
```bash
$ bundle exec rspec
```

#### 5.サーバを起動する
テストが問題なかった場合、以下のコマンドでRailsアプリケーションを実行してください。
```bash
$ rails server
```
