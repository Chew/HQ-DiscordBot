module User
  extend Discordrb::Commands::CommandContainer

  command(:user, min_args: 0, max_args: 1) do |event, name|
    filename = "profiles/#{event.user.id}.yaml"
    if File.exist?(filename) && name.nil?
      data = YAML.load_file(filename)
      name = data['username']
    else
      name = event.user.nickname || event.user.name
    end

    findid = RestClient.get('https://api-quiz.hype.space/users',
                            params: { q: name },
                            Authorization: CONFIG['api'],
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

    data = RestClient.get("https://api-quiz.hype.space/users/#{id}",
                          Authorization: CONFIG['api'],
                          'Content-Type': :json)

    data = JSON.parse(data)

    begin
      event.channel.send_embed do |embed|
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "User stats for #{data['username']}", url: URI.escape(data['referralUrl']))
        embed.colour = '36399A'

        embed.add_field(name: 'Game Stats', value: [
          "Games Played - #{data['gamesPlayed']}",
          "Win Count - #{data['winCount']}"
        ].join("\n"), inline: true)

        embed.add_field(name: 'Amount Won', value: data['leaderboard']['total'], inline: true)

        embed.add_field(name: 'High Score', value: "#{data['highScore']} questions", inline: true)

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Account created on')
        embed.timestamp = Time.parse(data['created'])
        embed.thumbnail = { url: data['avatarUrl'].to_s }
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowski here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
