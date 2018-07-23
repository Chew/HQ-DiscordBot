require 'discordrb'
require 'rest-client'
require 'json'
require 'yaml'
require 'nokogiri'
require 'open-uri'
puts 'All dependencies loaded'

CONFIG = YAML.load_file('config.yaml')
puts 'Config loaded from file'

Bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: ["<@#{CONFIG['client_id']}> ", 'hq, ', 'HQ, ', 'hq,', 'HQ,', 'hq', 'HQ']

puts 'Initial Startup complete, loading all plugins...'

Starttime = Time.now

Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each { |file| require file }

Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each do |wow|
  bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
  command = bob[0][7..bob[0].length]
  command.delete!("\n")
  command = Object.const_get(command)
  Bot.include! command
  puts "Plugin #{command} successfully loaded!"
end

Bot.server_create do |event|
  Bot.channel(471_092_848_238_788_608).send_embed do |e|
    e.title = 'I did a join'

    e.add_field(name: 'Server Name', value: event.server.name, inline: true)
    e.add_field(name: 'Server ID', value: event.server.id, inline: true)
    e.add_field(name: 'Server Count', value: event.bot.servers.count, inline: true)
    e.add_field(name: 'User Count', value: event.server.members.count, inline: true)

    userid = CONFIG['owner_id'].to_i
    user = Bot.user(userid)

    e.add_field(name: 'Are you on it?', value: event.server.members.include?(user), inline: true)

    e.color = '00FF00'
  end
end

Bot.server_delete do |event|
  Bot.channel(471_092_848_238_788_608).send_embed do |e|
    e.title = 'I did a leave'

    e.add_field(name: 'Server Name', value: event.server.name, inline: true)
    e.add_field(name: 'Server ID', value: event.server.id, inline: true)
    e.add_field(name: 'Server Count', value: event.bot.servers.count, inline: true)

    e.color = 'FF0000'
  end
end

puts 'Done loading plugins! Finalizing start-up'

Bot.ready do |_event|
  Bot.game = 'with Scott Rogowski! | hq, help'
  sleep 180
  redo
end

puts 'Bot is ready!'
Bot.run
