module Badges
  extend Discordrb::Commands::CommandContainer

  ROLE_ID = JSON.parse({
    'Business': '<:business_badge:503357666211659797>',
    'Celebrity': '<:entertainment_badge:503357666106802176>',
    'Geography': '<:geography_badge:503357666408529920>',
    'History': '<:history_badge:503357666354003981>',
    'Literature': '<:literature_badge:503357666362654741>',
    'Movies': '<:movies_badge:503357666240757761>',
    'Music': '<:music_badge:503357666912108546>',
    'Nature': '<:nature_badge:503357666794668032>',
    'Science': '<:science_badge:503357666463055882>',
    'Sports': '<:sports_badge:503357666794405919>',
    'TV': '<:tv_badge:503365650165661716>'
  }.to_json).freeze

  command(:badges) do |event, *namearg|
    name = namearg.join(' ') unless namearg.length.zero?
    user = BotUser.new(event.user.id)
    if user.exists? && namearg.length.zero?
      profile = user
      name = profile.username
    elsif namearg.length.zero?
      name = event.user.display_name
    end

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

    data = RestClient.get("https://api-quiz.hype.space/achievements/v2/#{id}",
                          Authorization: key,
                          'Content-Type': :json)

    data = JSON.parse(data)

    username = RestClient.get("https://api-quiz.hype.space/users/#{id}",
                              Authorization: key,
                              'Content-Type': :json)

    username = JSON.parse(username)['username']

    # families = %w[Business Celebrity Geography History Literature Movie Music Nature Science Sports TV]

    max = 1_100
    total = 0

    begin
      event.channel.send_embed do |embed|
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Badge stats for #{username}")
        embed.colour = '36399A'

        data['families'].each do |e|
          tot = e['earnedAchievements'][2]['progressPct']
          tot = 100 if tot > 100
          total += tot
          name = e['name']

          output = []
          output += ["Level 1 - #{e['earnedAchievements'][0]['progressPct'].round(2)}%"] unless e['earnedAchievements'][0]['progressPct'] >= 100
          output += ["Level 2 - #{e['earnedAchievements'][1]['progressPct'].round(2)}%"] unless e['earnedAchievements'][1]['progressPct'] >= 100
          output += ["Level 3 - #{e['earnedAchievements'][2]['progressPct'].round(2)}%"] unless e['earnedAchievements'][2]['progressPct'] >= 100

          output += ['COMPLETE!'] if output.length.zero?

          output = [output[0]] if output.length.positive?

          embed.add_field(name: "#{ROLE_ID[name]} - #{name}", value: output.join("\n"), inline: true)
        end

        embed.add_field(name: '​', value: '​', inline: true)

        embed.title = "#{(total / max * 100).round(2)}% completion"
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
