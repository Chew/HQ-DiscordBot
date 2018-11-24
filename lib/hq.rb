puts 'Initial Startup complete, loading all plugins...'

require_relative 'extensions/array'

require_relative 'extensions/dbgeek'
require_relative 'extensions/commandz'
require_relative 'extensions/botuser'

DBHelper = DbGeek.new

Commands = Commandz.new

Starttime = Time.now

def loadpls
  Bots.each(&:clear!)
  Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each do |wow|
    load wow
    require wow
    bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
    command = bob[0][7..bob[0].length]
    command.delete!("\n")
    command = Object.const_get(command)
    Bots.each do |bot|
      bot.include! command
    end
    puts "Plugin #{command} successfully loaded!"
  end
end

loadpls

Bots.each do |bot|
  bot.command(:reload) do |event|
    break unless event.user.id == CONFIG['owner_id']

    loadpls
    event.respond 'Reloaded sucessfully!'
  end

  def servers(servers)
    DBL.stats.updateservercount(servers, bot.shard_key[0], bot.shard_key[1]) unless CONFIG['dbotsorg'].nil?
    RestClient.post("https://discordsbestbots.xyz/api/bots/#{CONFIG['client_id']}", { 'guilds': DBL.stats.servers, 'shards': bot.shard_key[1] }, Authorization: CONFIG['dbbapi'], 'Content-Type': :json) unless CONFIG['dbbapi'].nil?
  end

  bot.server_create do |event|
    servers(event.bot.servers.count)
    event.bot.channel(471_092_848_238_788_608).send_embed do |e|
      e.title = 'I did a join'

      e.add_field(name: 'Server Name', value: event.server.name, inline: true)
      e.add_field(name: 'Server ID', value: event.server.id, inline: true)
      e.add_field(name: 'Server Count', value: event.bot.servers.count, inline: true)
      e.add_field(name: 'Shard', value: event.bot.shard_key[0].to_s, inline: true)
      e.add_field(name: 'User Count', value: event.server.members.count, inline: true)

      userid = CONFIG['owner_id'].to_i
      user = event.bot.user(userid)

      e.add_field(name: 'Are you on it?', value: event.server.members.include?(user), inline: true)

      e.color = '00FF00'
    end
  end

  bot.server_delete do |event|
    servers(event.bot.servers.count)
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

  bot.ready do |_event|
    bot.game = 'with Scott Rogowsky! | hq, help'
  end

  puts 'Bot is ready!'
end

Bots.each do |bot|
  bot.run(:async)
end

loop do
end
