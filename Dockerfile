FROM ruby:3.2.8

# 必要なライブラリやツールをインストール
# - build-essential: NokogiriなどC言語で書かれたGemのコンパイルに必要
# - nodejs, yarn: アセットパイプライン（JavaScript）の実行に必要
# - postgresql-client: PostgreSQLサーバーに接続するために必要
RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn postgresql-client

# 作業ディレクトリを作成・指定
RUN mkdir /sample-app
WORKDIR /sample-app

# Gemfileコピーしてbundle installを実行
ADD Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install

# アプリケーションディレクトリをコンテナにコピー
COPY . .

