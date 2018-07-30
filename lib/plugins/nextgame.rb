module RandomQuestion
  extend Discordrb::Commands::CommandContainer

  command(%i[nextgame next game]) do |event, region|
    filename = "profiles/#{event.user.id}.yaml"
    if File.exist?(filename) && region.nil?
      data = YAML.load_file(filename)
      region = data['region']
    else
      region = 'us'
    end

    case region.downcase
    when 'us'
      key = CONFIG['api']
    when 'uk'
      key = CONFIG['apiuk']
    when 'de'
      event.respond "Germany times are not supported yet!"
    when 'au'
      key = CONFIG['apiau']
    end
    data = RestClient.get('https://api-quiz.hype.space/shows/now',
                          params: { type: 'hq' },
                          Authorization: key,
                          'Content-Type': :json)

    data = JSON.parse(data)

    active = data['active']

    kind = if active
             if data['vertical'] == 'general'
               'Normal Show'
             elsif data['vertical'] == 'sports'
               'Sports Show'
             else
               'Unknown Show'
             end
           else
             if data['upcoming'][0]['vertical'] == 'general'
               'Normal Show'
             elsif data['upcoming'][0]['vertical'] == 'sports'
               'Sports Show'
             else
               'Unknown Show'
             end
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

        embed.add_field(name: 'Prize:', value: prize, inline: true)
        embed.add_field(name: 'Type', value: kind, inline: true)
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowski here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
