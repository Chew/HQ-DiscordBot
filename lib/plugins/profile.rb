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

    begin
      event.channel.send_embed do |embed|
        embed.title = "HQBot Profile for #{event.user.name}"
        embed.colour = '36399A'

        embed.add_field(name: 'HQ Username', value: data['username'], inline: true)
        embed.add_field(name: 'Region', value: data['region'], inline: true)

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Change with: hq, set [type] [option]')
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowski here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:set) do |event, type, setting|
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
end
