module NextGame
  extend Discordrb::Commands::CommandContainer

  command(:nextgame, aliases: [:next]) do |event, *stuff|
    stuff = stuff.join(' ').downcase

    kind = []
    kind.push 'general'
    kind.delete 'general' if stuff.include?('sports') || stuff.include?('words')
    kind.push 'sports' if stuff.include? 'sports'
    kind.push 'words' if stuff.include? 'words'

    data = RestClient.get('https://api-quiz.hype.space/shows/schedule',
                          Authorization: CONFIG['api'],
                          'x-hq-stk': 'MQ==',
                          'x-hq-client': 'iOS/1.3.27 b121',
                          'Content-Type': :json)

    data = JSON.parse(data)

    # active = data['active']

    showstuff = ''

    data['shows'].each do |show|
      next unless showstuff == ''
      showstuff = show if kind.include? show['vertical']
    end

    begin
      if showstuff['prizeCents'].nil?
        prize = showstuff['prizePoints']
        points = true
      else
        prize = (showstuff['prizeCents'] / 100).to_s
        points = false
      end
    rescue NoMethodError
      begin
        event.channel.send_embed do |embed|
          embed.title = 'No Games Match Given Criteria'
          embed.colour = 'E6286E'
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'No Games Match Given Criteria!'
      end
      break
    end

    gametype = if showstuff['vertical'] == 'general'
                 'Trivia'
               elsif showstuff['vertical'] == 'sports'
                 'Sports'
               elsif showstuff['vertical'] == 'words'
                 'Words'
               else
                 'Unknown'
               end

    begin
      event.channel.send_embed do |embed|
        embed.title = 'Upcoming HQ Game'
        embed.colour = '36399A'
        embed.footer = { text: 'Show Time' }
        embed.timestamp = Time.parse(showstuff['startTime'])

        if points
          embed.add_field(name: 'Prize', value: "#{prize.to_i.to_sc} points", inline: true)
        else
          embed.add_field(name: 'Prize', value: "$#{prize.to_i.to_sc}", inline: true)
        end
        embed.add_field(name: 'Type', value: gametype, inline: true)
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
