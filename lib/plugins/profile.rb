module Profile
  extend Discordrb::Commands::CommandContainer

  command(:profile) do |event|
    dbuser = BotUser.new(event.user.id)
    unless dbuser.exists?
      DBHelper.newuser(event.user.id, event.user.display_name, 'us')
      dbuser = BotUser.new(event.user.id)
    end

    perks = []
    perks += ['Donator'] if dbuser.donator?
    perks += ['Auth Key Donor'] if dbuser.authkey?
    perks += ['Bug Hunter'] if dbuser.bughunter?

    extras = []
    extras += ['Extra Lives'] if dbuser.lives?
    extras += ['Streak Info'] if dbuser.streaks?

    begin
      event.channel.send_embed do |embed|
        embed.title = "HQBot Profile for #{event.user.name}"
        embed.colour = '36399A'

        embed.add_field(name: 'HQ Username', value: dbuser.username, inline: true)
        embed.add_field(name: 'Region', value: dbuser.region, inline: true)
        embed.add_field(name: 'Extra User Stats', value: extras.join("\n"), inline: true) unless extras.length.zero?
        embed.add_field(name: 'Special Perks', value: perks.join("\n"), inline: true) unless perks.length.zero?

        embed.footer = { text: 'Change with: hq, set [type] [option]' }
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:set, min_args: 2) do |event, type, *setting|
    setting = setting.join(' ')
    dbuser = BotUser.new(event.user.id)
    unless dbuser.exists?
      DBHelper.newuser(event.user.id, event.server.member(event.user.id).display_name, 'us')
      dbuser = BotUser.new(event.user.id)
    end
    type = 'streaks' if type == 'streak'
    case type.downcase
    when 'username'
      dbuser.username = setting
    when 'region'
      setting.downcase!
      dbuser.region = if setting.include? 'us'
                        'us'
                      elsif setting.include? 'uk'
                        'uk'
                      elsif setting.include? 'de'
                        'de'
                      elsif setting.include? 'au'
                        'au'
                      else
                        'us'
                      end
    when 'lives', 'streaks'
      setting.downcase!
      choice = 0
      choice = 1 if %w[true on enabled].include? setting
      if dbuser.authkey?
        DBHelper.updateuser(event.user.id, type.downcase, choice.to_i)
      else
        event.respond ':-1: Unable to set: You must be an AuthKey donator to use this type!'
        break
      end
    else
      event.respond ':-1: Unable to set: Invalid type!'
      break
    end
    event.respond ":+1: Successfully set `#{type}` to `#{setting}`"
  end

  command(:setperk) do |event, user, type, setting|
    unless event.user.id == CONFIG['owner_id']
      event.respond 'Sorry, only the bot owner may set perks!'
      break
    end
    userid = Bot.parse_mention(user).id
    dbuser = BotUser.new(userid)
    DBHelper.newuser(userid, Bot.user(userid).displayname, 'us') unless dbuser.exists?
    case type.downcase
    when 'donator', 'authkey', 'bughunter', 'keyid'
      DBHelper.updateuser(userid, type, setting.to_i)
    else
      event.respond 'Invalid type!'
      break
    end
    event.respond ":+1: Successfully set `#{type}` to `#{setting}`"
  end
end
