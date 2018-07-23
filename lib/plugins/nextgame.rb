module RandomQuestion
  extend Discordrb::Commands::CommandContainer

  command(%i[nextgame next game]) do |event|
    data = RestClient.get('https://api-quiz.hype.space/shows/now',
                          params: { type: 'hq' },
                          Authorization: CONFIG['api'],
                          'Content-Type': :json)

    data = JSON.parse(data)

    begin
      event.channel.send_embed do |embed|
        embed.title = 'Next HQ Game'
        embed.colour = '36399A'

        embed.add_field(name: 'Prize:', value: data['upcoming'][0]['prize'])

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Show Time')
        embed.timestamp = Time.parse(data['upcoming'][0]['time'])
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowski here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
