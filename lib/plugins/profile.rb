module Profile
  extend Discordrb::Commands::CommandContainer

  command(:profile) do |event|
    filename = "profiles/#{event.user.id}.yaml"
    unless File.exist?(filename)
      File.new(filename, 'w+')
      exconfig = YAML.load_file('profiles/0.yaml')
      exconfig['username'] = event.user.nickname || event.user.name
      File.open(filename, 'w') { |f| f.write exconfig.to_yaml }
    end

    data = YAML.load_file(filename)

    perks = []
    perks += ['Donator'] if data['donator']
    perks += ['Auth Key Donor'] if data['authkey']
    perks += ['Bug Hunter'] if data['bughunter']

    begin
      event.channel.send_embed do |embed|
        embed.title = "HQBot Profile for #{event.user.name}"
        embed.colour = '36399A'

        embed.add_field(name: 'HQ Username', value: data['username'], inline: true)
        embed.add_field(name: 'Region', value: data['region'], inline: true)
        embed.add_field(name: 'Special Perks', value: perks.join("\n"), inline: true) unless perks.length.zero?

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Change with: hq, set [type] [option]')
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowski here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:set) do |event, type, *setting|
    setting = setting.join(' ')
    filename = "profiles/#{event.user.id}.yaml"
    unless File.exist?(filename)
      File.new(filename, 'w+')
      exconfig = YAML.load_file('profiles/0.yaml')
      exconfig['username'] = event.user.nickname || event.user.name
      File.open(filename, 'w') { |f| f.write exconfig.to_yaml }
    end
    data = YAML.load_file(filename)
    case type.downcase
    when 'username', 'region'
      data[type.downcase] = setting
    else
      event.respond 'Invalid type!'
      break
    end
    File.open(filename, 'w') { |f| f.write data.to_yaml }
    event.respond ":+1: Successfully set `#{type}` to `#{setting}`"
  end

  command(:setperk) do |event, user, type, *setting|
    unless event.user.id == CONFIG['owner_id']
      event.respond 'Sorry, only the bot owner may set perks!'
      break
    end
    userid = Bot.parse_mention(user).id
    setting = setting.join(' ')
    filename = "profiles/#{userid}.yaml"
    unless File.exist?(filename)
      File.new(filename, 'w+')
      exconfig = YAML.load_file('profiles/0.yaml')
      exconfig['username'] = event.user.nickname || event.user.name
      File.open(filename, 'w') { |f| f.write exconfig.to_yaml }
    end
    data = YAML.load_file(filename)
    case type.downcase
    when 'donator', 'authkey', 'bughunter'
      data[type.downcase] = setting == 'true'
    else
      event.respond 'Invalid type!'
      break
    end
    File.open(filename, 'w') { |f| f.write data.to_yaml }
    event.respond ":+1: Successfully set `#{type}` to `#{setting}`"
  end
end
