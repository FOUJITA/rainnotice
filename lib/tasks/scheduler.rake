desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }

  url  = "http://www.drk7.jp/weather/xml/13.xml"
  xml  = open( url ).read.toutf8
  doc = REXML::Document.new(xml)
  xpath = 'weatherforecast/pref/area[4]/info'
  weather = doc.elements[xpath + '/weather'].text
  per06to12 = doc.elements[xpath + '/rainfallchance/period[2]l'].text
  per12to18 = doc.elements[xpath + '/rainfallchance/period[3]l'].text
  per18to24 = doc.elements[xpath + '/rainfallchance/period[4]l'].text
  min_per = 20 #最終的に30に変える
  if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
    word1 =
      ["いい朝だね！",
       "今日もよく眠れた？",
       "二日酔い大丈夫？",
       "早起きしてえらいね！",
       "いつもより起きるのちょっと遅いんじゃない？"].sample
    word2 =
      ["気をつけて行ってきてね！",
       "良い一日を！",
       "雨に負けずに今日も頑張ってね！",
       "今日も一日楽しんでいこうね！",
       "面白いことがあったら教えてね！行ってらっしゃい！"].sample
    push =
      "#{word1}\n今日は雨が降りそうだから傘を忘れないでね！\n降水確率はこんな感じだよ。\n 6〜12時　#{per06to12}％\n12〜18時　#{per12to18}％\n18〜24時　#{per18to24}％\n#{word2}"
    user_ids = "U96a2790cfba425cb1e422d6f00c3a877"
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end
  "OK"
end