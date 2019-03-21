puts 'Initial Startup complete, loading all plugins...'

require_relative 'extensions/array'
require_relative 'extensions/integer'
require_relative 'extensions/float'

require_relative 'extensions/dbgeek'
require_relative 'extensions/commandz'
require_relative 'extensions/botuser'
require_relative 'extensions/servers'

DBHelper = DbGeek.new

Commands = Commandz.new

Starttime = Time.now

ServerManager = Servers.new(CONFIG['shards'])

Scheduler = Rufus::Scheduler.new

def loadpls
  Bot.clear!
  Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each do |wow|
    load wow
    require wow
    bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
    command = bob[0][7..bob[0].length]
    command.delete!("\n")
    command = Object.const_get(command)
    Bot.include! command
    puts "Plugin #{command} successfully loaded!"
  end
end

Scheduler.in '10h' do
  puts "Restarting the bot..."
  sleep 1
  exec("pm2 restart #{Bot.shard_key[0]}")
end

loadpls

Bot.command(:reload) do |event|
  break unless event.user.id == CONFIG['owner_id']

  loadpls
  event.respond 'Reloaded sucessfully!'
end

Bot.server_create do |event|
  ServerManager.post(event.bot.servers.count, event.bot.shard_key[0])
  event.bot.channel(471_092_848_238_788_608).send_embed do |e|
    e.title = 'I did a join'

    e.add_field(name: 'Server Name', value: event.server.name, inline: true)
    e.add_field(name: 'Server ID', value: event.server.id, inline: true)
    e.add_field(name: 'Server Count', value: event.bot.servers.count, inline: true)
    e.add_field(name: 'Shard', value: event.bot.shard_key[0].to_s, inline: true)
    e.add_field(name: 'User Count', value: event.server.members.count, inline: true)

    e.color = '00FF00'
  end
end

Bot.server_delete do |event|
  ServerManager.post(event.bot.servers.count, event.bot.shard_key[0])
  event.bot.channel(471_092_848_238_788_608).send_embed do |e|
    e.title = 'I did a leave'

    e.add_field(name: 'Server Name', value: event.server.name, inline: true)
    e.add_field(name: 'Server ID', value: event.server.id, inline: true)
    e.add_field(name: 'Server Count', value: event.bot.servers.count, inline: true)
    e.add_field(name: 'Shard', value: event.bot.shard_key[0].to_s, inline: true)

    e.color = 'FF0000'
  end
end

# Bot.message(contains: /'hq, '/) do |event|
#  Commands.add
#  puts "Command ran by #{event.user.distinct} (#{event.user.id}): #{event.message.content}"
#  nil
# end

puts 'Done loading plugins! Finalizing start-up'

hosts = ['Scott Rogowsky', 'Matt Richards', 'Sarah Pribis', 'David Magidoff', 'Tyler West', 'Lauren Gambino', 'Sharon Carpenter', 'Beric Livingstone', 'Emma Tattenbaum', 'Anna Roisman', 'Sian Welby', 'Leonie Zeumer', 'Lara Falkner', 'Kathryn Goldsmith', 'Jimmy Kimmel', "Charlie O'Connor", 'Alexandra Maurer', 'James Veitch', 'Neil Patrick Harris']

Bot.ready do |_event|
  Bot.game = "with #{hosts.sample}! | hq, help"
  sleep 180
  redo
end

puts 'Bot is ready!'

Bot.run
