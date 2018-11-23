require 'discordrb'
require 'rest-client'
require 'json'
require 'yaml'
require 'open-uri'
require 'dblruby'
require 'mysql2'
puts 'All dependencies loaded'

CONFIG = YAML.load_file('config.yaml')
puts 'Config loaded from file'

DBL = DBLRuby.new(CONFIG['dbotsorg'], CONFIG['client_id'])
puts 'Properly Instantiated DBL!'

begin
  DB = Mysql2::Client.new(
    host: CONFIG['db']['host'],
    username: CONFIG['db']['username'],
    password: CONFIG['db']['password'],
    database: CONFIG['db']['database'],
    reconnect: true
  )
  puts 'Connected to database'
rescue Mysql2::Error::ConnectionError
  puts 'Unable to connect to the database. Good going!'
  exit
end

prefixes = ["<@#{CONFIG['client_id']}>", 'hq,', 'HQ,', 'hq', 'HQ', 'Hq', 'Hq,'].freeze

Bots = Array.new(CONFIG['shards'], nil)

Bots.length.times do |amount|
  Bots[amount] = Discordrb::Commands::CommandBot.new(token: CONFIG['token'],
                                                     client_id: CONFIG['client_id'],
                                                     prefix: prefixes,
                                                     ignore_bots: true,
                                                     num_shards: CONFIG['shards'],
                                                     shard_id: amount.to_i,
                                                     spaces_allowed: true,
                                                     compress_mode: :stream)
end
require_relative 'lib/hq'
