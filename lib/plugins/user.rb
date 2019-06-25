module User
  extend Discordrb::Commands::CommandContainer

  command(:id, min_args: 0) do |event, *namearg|
    name = namearg.join(' ') unless namearg.length.zero?
    key = CONFIG['api']

    findid = RestClient.get('https://api-quiz.hype.space/users',
                            params: { q: name },
                            Authorization: key,
                            'Content-Type': :json)

    iddata = JSON.parse(findid)['data']

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

          teste = RestClient.get('https://api-quiz.hype.space/users/me',
                                 Authorization: key,
                                 'x-hq-client': 'iOS/1.4.15 b146',
                                 'Content-Type': :json)

          teste = JSON.parse(teste)

          unless teste['username'].casecmp(profile.username).zero?
            key = CONFIG['api']
            extra = false
            event.respond 'Auth key doesn\'t match your profile username, not returning any extra stats!'
          end
        end
      end

      findid = RestClient.get('https://api-quiz.hype.space/users',
                              params: { q: name },
                              Authorization: key,
                              'Content-Type': :json)

      iddata = JSON.parse(findid)['data']

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

      data = if extra
               HQTrivia.new(key).me
             else
               HQ.user(id)
             end

      leader = data.leaderboard

      wrank = leader.weekly_rank
      arank = leader.alltime_rank

      showrank = !(wrank == arank && wrank == 101)

      ranks = []

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
      amountwon.push leader.total

      xp = []
      xp.push data.season_xp.current_points
      xp.push data.season_xp.remaining_points || 0
      xp.push data.season_xp.current_level

      xpshow = if xp[0] == (xp[0] + xp[1])
                 'Max Points Achieved!'
               else
                 "Points: #{xp[0].to_sc} / #{(xp[0] + xp[1]).to_sc}"
               end

      # amountwon.push "Words: #{currency}#{centswords / 100}" if words

      begin
        event.channel.send_embed do |embed|
          embed.author = { name: "User stats for #{data.username}", url: "https://stats.hqtrivia.pro/user/#{data.username}" }
          embed.colour = '36399A'

          embed.add_field(name: 'Game Stats', value: [
            "Games Played - #{data.games_played}",
            "Win Count - #{data.win_count}"
          ].join("\n"), inline: true)

          unclaimed = leader.unclaimed
          amountwon.push [" (#{unclaimed} unclaimed)"] unless ['$0', '£0', '€0', 'A$0'].include? unclaimed

          embed.add_field(name: 'Amount Won', value: amountwon.join("\n"), inline: true)

          embed.add_field(name: 'High Score', value: "#{data.high_score} questions", inline: true)

          embed.add_field(name: 'Badges', value: "#{data.badges_count} / 33 badges", inline: true)

          embed.add_field(name: 'Ranking', value: ranks.join("\n"), inline: true) if showrank

          if xp[0].positive?
            embed.add_field(name: 'Season XP', value: [
              "Level: #{xp[2]}",
              xpshow
            ].join("\n"), inline: true)
          end

          if namearg.length.zero? && user.exists? && extra
            powerups = []
            powerups.push("<:extra_life:515015386517995520> - #{data.lives}") if profile.lives?
            powerups.push("<:erasers:525522341111791626> - #{data.erasers}") if profile.erase1s?
            powerups.push("<:superspin:558466764250546197> - #{data.super_spins}") if profile.superspins?

            embed.add_field(name: 'Power-Ups', value: powerups.join("\n"), inline: true) unless powerups.empty?
            if profile.streaks?
              embed.add_field(name: 'Streak Info', value: [
                "#{data.streak_info.target - data.streak_info.current} days left",
                "#{data.streak_info.total} total streak"
              ].join("\n"), inline: true)
            end
          end

          embed.footer = { text: 'Account created on' }
          embed.timestamp = data.created
          embed.thumbnail = { url: data.avatar_url }
        end
        msg.delete
      rescue Discordrb::Errors::NoPermission
        event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
      end
    rescue RestClient::Forbidden => e
      msg.edit '<:xmark:314349398824058880> 403 Forbidden Error occured getting stats. This incident has been reported. Join the support server with `hq, invite`'

      Raven.user_context(id: event.user.id)

      Raven.extra_context(channel_id: event.channel.id, server_id: event.server.id, message: event.message.content, data: data, key: key)
      Raven.capture_exception(e)
      nil
    rescue StandardError => e
      puts 'Error'
      msg.edit '<:xmark:314349398824058880> Unknown Error occured getting stats. This incident has been reported. Join the support server with `hq, invite`'
      event.bot.channel(572_532_026_125_582_336).send_embed do |embed|
        embed.title = 'Command `hq, user` Errored'
        embed.description = e
      end
      Raven.user_context(id: event.user.id)

      Raven.extra_context(channel_id: event.channel.id, server_id: event.server.id, message: event.message.content, data: data, key: key)
      Raven.capture_exception(e)
      nil
    end
  end
end
