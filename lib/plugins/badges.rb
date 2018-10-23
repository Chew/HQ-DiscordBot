module Badges
  extend Discordrb::Commands::CommandContainer

  ROLE_ID = JSON.parse({
    'Business': ['<:categorybusiness_lg_1:504332837055496193>','<:categorybusiness_lg_2:504332836841455647>','<:categorybusiness_lg_3:504332839010172928>'],
    'Celebrity': ['<:categoryentertainment_lg_1:504332837110022145>','<:categoryentertainment_lg_2:504332838686949396>','<:categoryentertainment_lg_3:504332839702102016>'],
    'Geography': ['<:categorygeography_lg_1:504332839115030538>','<:categorygeography_lg_2:504332839123288064>','<:categorygeography_lg_3:504332839093927946>'],
    'History': ['<:categoryhistory_lg_1:504332836787060739>','<:categoryhistory_lg_2:504332837785436161>','<:categoryhistory_lg_3:504332838653657090>'],
    'Literature': ['<:categoryliterature_lg_1:504332837667733505>','<:categoryliterature_lg_2:504332838133563392>','<:categoryliterature_lg_3:504332837395103775>'],
    'Movies': ['<:categorymovies_lg_1:504332838338822147>','<:categorymovies_lg_2:504332838058065931>','<:categorymovies_lg_3:504332839035338762>'],
    'Music': ['<:categorymusic_lg_1:504332838569771008>','<:categorymusic_lg_2:504332838154534917>','<:categorymusic_lg_3:504332838951452690>'],
    'Nature': ['<:categorynature_lg_1:504332839668547604>','<:categorynature_lg_2:504332839182008341>','<:categorynature_lg_3:504332838724829185>'],
    'Science': ['<:categoryscience_lg_1:504332838695338025>','<:categoryscience_lg_2:504332839446380545>','<:categoryscience_lg_3:504332840322859018>'],
    'Sports': ['<:categorysports_lg_1:504332838938869763>','<:categorysports_lg_2:504332841631612929>','<:categorysports_lg_3:504332841547726859>'],
    'TV': ['<:categorytv_lg_1:504332838716440586>','<:categorytv_lg_2:504332839253311488>','<:categorytv_lg_3:504332839605501968>']
  }.to_json).freeze
  # replace emojis with ones on your server if you want however they should work as all bots have nitro powers.

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

          # prepare yourself for some digusting code
          level = 2
          level = 1 unless e['earnedAchievements'][1]['progressPct'] >= 100
          level = 0 unless e['earnedAchievements'][0]['progressPct'] >= 100

          output = []
          output += ["Level 1 - #{e['earnedAchievements'][0]['progressPct'].round(2)}%"] unless e['earnedAchievements'][0]['progressPct'] >= 100
          output += ["Level 2 - #{e['earnedAchievements'][1]['progressPct'].round(2)}%"] unless e['earnedAchievements'][1]['progressPct'] >= 100
          output += ["Level 3 - #{e['earnedAchievements'][2]['progressPct'].round(2)}%"] unless e['earnedAchievements'][2]['progressPct'] >= 100

          output += ['COMPLETE!'] if output.length.zero?

          output = [output[0]] if output.length.positive?

          embed.add_field(name: "#{ROLE_ID[name][level]} - #{name}", value: output.join("\n"), inline: true)
        end

        embed.add_field(name: '​', value: '​', inline: true)

        embed.title = "#{(total / max * 100).round(2)}% completion"
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
