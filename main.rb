require 'net/http'
require 'uri'
require "json"
require 'pp'
require 'dotenv'
Dotenv.load

SLACK_API_TOKEN = ENV['SLACK_API_TOKEN'] # slackAPI用に取得したtoken
COUNT = 1000 # チャンネルごとの取得するメッセージ数

# チャンネルリストの取得
def get_channel_list
  uri = URI.parse("https://slack.com/api/conversations.list")

  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Get.new(uri.request_uri)
  req["Authorization"] = "Bearer #{SLACK_API_TOKEN}"

  res = http.request(req)
  hash = JSON.parse(res.body)
  channels = hash["channels"]

  channel_lists = {}

  channels.each do |channel|
    channel_lists[channel["name"].to_sym] = channel["id"]
  end

  return channel_lists
end

# メッセージの取得
def get_reactions(channel_list)

  reactions = []

  channel_list.each do |name, id|
    uri = URI.parse("https://slack.com/api/conversations.history?inclusive=true&count=#{COUNT}&channel=#{id}")

    http = Net::HTTP.new(uri.host, uri.port)
  
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Authorization"] = "Bearer #{SLACK_API_TOKEN}"

    res = http.request(req)
  
    hash = JSON.parse(res.body)
    messages = hash["messages"]

    messages.each do |message|
      reactions << message["reactions"]
    end
  end

  return reactions.compact.flatten
end

# # 絵文字の集計
def count_emoji(reactions)
  results = Hash.new(0)

  reactions.each do |reaction|
    name = reaction["name"]
    results[name.to_sym] += reaction["count"]
  end

  puts "絵文字使用回数ランキング"
  result_data = []
  results.sort_by { |_, v| -v }.each do |result|
    result_data << result
    puts "#{result[0].to_s.rjust(30, " ")}:#{result[1]}回"
  end
end

channel_list = get_channel_list()
reactions = get_reactions(channel_list)
count_emoji(reactions)