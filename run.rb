puts "Let's start that bot!"

ARGV.each do |e|
  puts "Argument found: #{e}"
end

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
rescue Mysql2::Error::ConnectionError
  puts 'Unable to connect to the database. Good going!'
  exit
end

puts 'Connected to database'

prefixes = ["<@#{CONFIG['client_id']}>", 'hq,', 'HQ,', 'hq', 'HQ', 'Hq', 'Hq,'].freeze

Bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: prefixes,
                                          ignore_bots: true,
                                          num_shards: CONFIG['shards'],
                                          shard_id: ARGV[0].to_i,
                                          spaces_allowed: true

require_relative 'lib/hq'
