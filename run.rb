require 'discordrb'
require 'rest-client'
require 'json'
require 'yaml'
require 'open-uri'
require 'dblruby'
require 'mysql2'
require 'rufus-scheduler'
puts 'All dependencies loaded'

CONFIG = YAML.load_file('config.yaml')
puts 'Config loaded from file'

DBL = DBLRuby.new(CONFIG['dbotsorg'], CONFIG['client_id'])
puts 'Properly Instantiated DBL!'

prefixes = ["<@#{CONFIG['client_id']}>", 'hq,', 'HQ,', 'hq', 'HQ', 'Hq', 'Hq,'].freeze

Bot = Discordrb::Commands::CommandBot.new(token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: prefixes,
                                          ignore_bots: true,
                                          num_shards: CONFIG['shards'],
                                          shard_id: ARGV[0].to_i,
                                          spaces_allowed: true,
                                          compress_mode: :stream)
require_relative 'lib/hq'
