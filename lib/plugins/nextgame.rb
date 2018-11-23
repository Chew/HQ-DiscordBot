module NextGame
  extend Discordrb::Commands::CommandContainer

  command(:nextgame, aliases: [:next]) do |event, type = 'us'|
    dbuser = BotUser.new(event.user.id)
    if dbuser.exists? && type.nil?
      type = dbuser.type
    elsif type.nil?
      type = 'us'
    end

    stk = case type.downcase
          when 'uk'
            'Mg=='
          else
            'MQ=='
          end

    data = if type.downcase.include?('word')
             RestClient.get('https://api-quiz.hype.space/shows/now',
                            Authorization: CONFIG['api'],
                            'x-hq-client': 'iOS/1.3.27 b121',
                            'Content-Type': :json)
           else
             RestClient.get('https://api-quiz.hype.space/shows/now',
                            params: { type: 'hq' },
                            'x-hq-stk': stk,
                            'Content-Type': :json)
           end

    data = JSON.parse(data)

    active = data['active']

    kind = if active
             if data['vertical'] == 'general'
               'Normal'
             elsif data['vertical'] == 'sports'
               'Sports'
             elsif data['vertical'] == 'words'
               'Words'
             else
               'Unknown'
             end
           elsif data['upcoming'][0]['vertical'] == 'general'
             'Normal'
           elsif data['upcoming'][0]['vertical'] == 'sports'
             'Sports'
           elsif data['upcoming'][0]['vertical'] == 'words'
             'Words'
           else
             'Unknown'
           end

    prize = if active
              data['prize'].to_s
            else
              data['upcoming'][0]['prize']
            end

    begin
      event.channel.send_embed do |embed|
        if active
          embed.title = 'HQ is Live!'
          embed.colour = 'E6286E'
        else
          embed.title = 'Upcoming HQ Game'
          embed.colour = '36399A'
          embed.footer = { text: 'Show Time' }
          embed.timestamp = Time.parse(data['upcoming'][0]['time'])
        end

        embed.add_field(name: 'Prize', value: prize, inline: true)
        embed.add_field(name: 'Type', value: kind, inline: true)
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
