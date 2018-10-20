module NextGame
  extend Discordrb::Commands::CommandContainer

  command(%i[nextgame next game]) do |event, region|
    dbuser = BotUser.new(event.user.id)
    if dbuser.exists? && region.nil?
      region = dbuser.region
    elsif region.nil?
      region = 'us'
    end

    case region.downcase
    when 'us'
      stk = 'MQ=='
    when 'uk'
      stk = 'Mg=='
    when 'de'
      stk = 'Mw=='
    when 'au'
      stk = 'NA=='
    end
    data = RestClient.get('https://api-quiz.hype.space/shows/now',
                          params: { type: 'hq' },
                          'x-hq-stk': stk,
                          'Content-Type': :json)

    data = JSON.parse(data)

    active = data['active']

    kind = if active
             if data['vertical'] == 'general'
               'Normal'
             elsif data['vertical'] == 'sports'
               'Sports'
             else
               'Unknown'
             end
           elsif data['upcoming'][0]['vertical'] == 'general'
             'Normal'
           elsif data['upcoming'][0]['vertical'] == 'sports'
             'Sports'
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
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Show Time')
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
