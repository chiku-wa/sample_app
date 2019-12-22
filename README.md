# Railsチュートリアルのサンプルアプリケーションです

このアプリケーションは、以下の教材をもとに作成したサンプルアプリケーションです。
[*Ruby on Railsチュートリアル*](https://railstutorial.jp)

### ■ライセンス
[*Ruby on Railsチュートリアル*](https://railstutorial.jp)内にあるソースコードはMITライセンス(著作権表記を記しておけば自由に改造、使用することができる)と、Beerwareライセンス(開発者に出会った時にビールを奢ることができる権利)のもとで公開されています。
詳細は[LICENSE.md](LICENSE.md)を参照してください。

### ■前準備
#### 環境変数の設定
* メール送信用のSMTP設定
メール送信するために、SMTP設定を.envファイルに定義しておくこと。

[本番用]
```bash
export SMTP_MAIL_ADDRESS=smtp.gmail.com
export SMTP_PORT=587
export SMTP_DOMAIN=smtp.gmail.com
export SMTP_USER_NAME=<Gmailのアカウント>
export SMTP_PASSWORD=<Gmailのパスワード>
```

[開発用]
.env
```bash
SMTP_MAIL_ADDRESS=localhost
SMTP_PORT=1025
```

### ■使い方

#### <u>1.Gitリポジトリをクローンする</u>
まずは手元のローカルPCにこのリポジトリをcloneしてください。

#### <u>2.bundle installする</u>
以下のコマンドを実行して、bundle installしてください。この時、ローカルPCは開発環境とするため、productionでしか使用しないgemはインストールしないように--without productionオプションを付与します。
```bash
$ bundle install --without production
```

#### <u>3.マイグレーションを実行する</u>
以下のコマンドでDBに対してマイグレーションを実行します。
```bash
$ rails db:migrate
```

#### <u>4.テストを実行する</u>
以下のコマンドでテストを実行してください。
```bash
$ bundle exec rspec
```

#### <u>5.サーバを起動する</u>
テストが問題なかった場合、以下のコマンドでRailsアプリケーションを実行してください。
```bash
$ rails server
```
