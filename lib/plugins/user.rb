module User
  extend Discordrb::Commands::CommandContainer

  command(:id, min_args: 0) do |event, *namearg|
    name = namearg.join(' ') unless namearg.length.zero?
    key = CONFIG['api']

    findid = HT.get("users?q=#{URI.encode_www_form_component(name)}", key)

    iddata = findid['data']

    if iddata.length.zero?
      begin
        event.channel.send_embed do |embed|
          embed.title = 'Error while searching for stats'
          embed.colour = 'E6286E'
          embed.description = 'Username not found.'
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'That user doesn\'t exist!'
      end
      break
    end

    id = iddata[0]['userId']

    event.respond "HQ User ID for #{iddata[0]['username']} is #{id}"
  end

  command(:user, aliases: [:stats], min_args: 0) do |event, *namearg|
    msg = event.respond '<a:loading:393852367751086090> Getting user data <a:loading:393852367751086090>'
    begin
      keys = JSON.parse(File.read('keys.json'))
      name = namearg.join(' ') unless namearg.length.zero?
      key = CONFIG['api']
      extra = false
      if namearg.empty?
        user = BotUser.new(event.user.id)
        if user.exists?
          profile = user
          name = profile.username
        else
          name = event.user.display_name
        end

        if user.exists? && profile.authkey?
          extra = true
          key = keys[profile.keyid]

          teste = HT.get("users/me", key)

          unless teste['username'].casecmp(profile.username).zero?
            key = CONFIG['api']
            extra = false
            event.respond 'Auth key doesn\'t match your profile username, not returning any extra stats!'
          end
        end
      end

      findid = HT.get("users?q=#{URI.encode_www_form_component(name)}", key)

      iddata = findid['data']

      if iddata.length.zero?
        begin
          msg.edit(
            '', Discordrb::Webhooks::Embed.new(
                  title: 'Error while searching for stats',
                  description: 'Username not found.',
                  color: 0xE6286E
                )
          )
        rescue Discordrb::Errors::NoPermission
          msg.edit 'That user doesn\'t exist!'
        end
        next
      end

      id = iddata[0]['userId']

      data = HT.get("users/#{id}", key)

      leader = data['leaderboard']

      wrank = leader['weekly']['rank']
      arank = leader['alltime']['rank']

      showrank = !(wrank == arank && wrank == 101)

      ranks = []

      wrank = leader['weekly']['rank']
      arank = leader['alltime']['rank']

      if wrank == 101
        hey = 'No wins this week'
      else
        prefix = case wrank.to_s.split('').last.to_i
                 when 1
                   'st'
                 when 2
                   'nd'
                 when 3
                   'rd'
                 else
                   'th'
                 end
        hey = "#{wrank}#{prefix}"
      end

      prefix = case arank.to_s.split('').last.to_i
               when 1
                 'st'
               when 2
                 'nd'
               when 3
                 'rd'
               else
                 'th'
               end
      sup = "#{arank}#{prefix}"

      ranks += ["Weekly: #{hey}"]
      ranks += ["All-Time: #{sup}"]

      amountwon = []
      # amountwon.push leader['alltime']['total']
      amountwon.push data['leaderboard']['total']

      #xp = []
      #xp.push data['seasonXp'][0]['currentPoints']
      #xp.push data['seasonXp'][0]['remainingPoints'] || 0
      #xp.push data['seasonXp'][0]['currentLevel']['level']

      #xpshow = if xp[0] == (xp[0] + xp[1])
      #           'Max Points Achieved!'
      #         else
      #           "Points: #{xp[0].to_sc} / #{(xp[0] + xp[1]).to_sc}"
      #         end

      # amountwon.push "Words: #{currency}#{centswords / 100}" if words

      begin
        event.channel.send_embed do |embed|
          embed.author = { name: "User stats for #{data['username']}", url: "https://stats.hqtrivia.pro/user/#{data['username']}" }
          embed.colour = '36399A'

          embed.add_field(name: 'Game Stats', value: [
            "Games Played - #{data['gamesPlayed']}",
            "Win Count - #{data['winCount']}"
          ].join("\n"), inline: true)

          unclaimed = data['leaderboard']['unclaimed']
          amountwon.push [" (#{unclaimed} unclaimed)"] unless ['$0', '£0', '€0', 'A$0'].include? unclaimed

          embed.add_field(name: 'Amount Won', value: amountwon.join("\n"), inline: true)

          embed.add_field(name: 'High Score', value: "#{data['highScore']} questions", inline: true)

          embed.add_field(name: 'Badges', value: "#{data['achievementCount']} / 33 badges", inline: true)

          embed.add_field(name: 'Ranking', value: ranks.join("\n"), inline: true) if showrank

          #if xp[0].positive?
          #  embed.add_field(name: 'Season XP', value: [
          #    "Level: #{xp[2]}",
          #    xpshow
          #  ].join("\n"), inline: true)
          #end

          if namearg.length.zero? && user.exists? && extra
            powerups = []
            powerups.push("<:extra_life:515015386517995520> - #{data['items']['lives']}") if profile.lives?
            powerups.push("<:erasers:525522341111791626> - #{data['erase1s']}") if profile.erase1s?
            powerups.push("<:superspin:558466764250546197> - #{data['items']['superSpins']}") if profile.superspins?
            powerups.push("#{data['coins']} Coins") if profile.coins?

            embed.add_field(name: 'Power-Ups', value: powerups.join("\n"), inline: true) unless powerups.empty?
            if profile.streaks?
              embed.add_field(name: 'Streak Info', value: [
                "#{data['streakInfo']['target'] - data['streakInfo']['current']} days left",
                "#{data['streakInfo']['total']} total streak"
              ].join("\n"), inline: true)
            end
          end

          embed.footer = { text: 'Account created on' }
          embed.timestamp = Time.parse(data['created'])
          embed.thumbnail = { url: data['avatarUrl'].to_s }
        end
        msg.delete
      rescue Discordrb::Errors::NoPermission
        event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
      end
    rescue RestClient::Forbidden
      msg.edit '<:xmark:314349398824058880> Error occurred getting stats: the bot is currently experiencing an outage on HQ\'s end. Join the support server with `hq, invite`'
    rescue StandardError => e
      puts e
      puts e.backtrace
      puts 'Error'
      msg.edit '<:xmark:314349398824058880> Error occurred getting stats. This incident has been reported. Join the support server with `hq, invite`'
      Raven.user_context(id: event.user.id)

      Raven.extra_context(channel_id: event.channel.id, server_id: event.server.id || nil, message: event.message.content, data: data)
      Raven.capture_exception(e)
      nil
    end
  end
end
