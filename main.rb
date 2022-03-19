require "rubygems"
require "twitter"
require "sinatra"

# クライアントの初期化
client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV["TWITTER_CLIENT_CONSUMER_KEY"]
  config.consumer_secret = ENV["TWITTER_CLIENT_CONSUMER_SECRET"]
end

# ページ数（何ページ目まで取得するか）
# 最大3,200ツイート分まで遡って取得できる
# API利用制限に注意
PAGE = 3

def fetch_tweets(client, name)
  return (1..PAGE).map { |page|
    client.user_timeline(
      name,
      page: page,
      count: 200,
      include_rts: true,
      exclude_replies: true
    )
  }
  # [[1ページ目のツイート], [2ページ目のツイート], ...] の形を1次元配列に直す
  .inject(:+)
  # メディア付きのツイートに絞る
  .select(&:media?)
end

get "/" do
  @name = params["name"] || ""
  @tweets = fetch_tweets(client, @name)
  erb :index
end
