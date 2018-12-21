module AuthKeyLife
  extend Discordrb::Commands::CommandContainer

  command(:getlife, min_args: 0) do |event|
    keys = JSON.parse(File.read('keys.json'))
    user = BotUser.new(event.user.id)

    if user.exists? && user.authkey?
      key = keys[user.keyid]

      uri = URI.parse('https://api-quiz.hype.space/easter-eggs/makeItRain')
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request['Authorization'] = key
      request['x-hq-client'] = 'iOS/1.3.27 b121'

      req_options = {
        use_ssl: uri.scheme == 'https'
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      data = JSON.parse(response.body)

      if data['error'].nil?
        begin
          event.channel.send_embed do |embed|
            embed.title = 'Thank you for being an AuthKey donor!'
            embed.colour = '36399A'
            embed.description = 'Your life has been sent.'
          end
        rescue Discordrb::Errors::NoPermission
          event.respond 'Your life has been sent!'
        end
      elsif data['error'] == 'Auth not valid'
        begin
          event.channel.send_embed do |embed|
            embed.title = 'Thank you for being an AuthKey donor!'
            embed.colour = 'E6286E'
            embed.description = 'Unfortunantly it appears your key has expired!'
          end
        rescue Discordrb::Errors::NoPermission
          event.respond 'Unfortunantly it appears your key has expired!'
        end
      elsif data['error'] == 'not authorized'
        begin
          event.channel.send_embed do |embed|
            embed.title = 'Thank you for being an AuthKey donor!'
            embed.colour = 'E6286E'
            embed.description = 'Unfortunantly you\'ve already claimed your free life this month!'
          end
        rescue Discordrb::Errors::NoPermission
          event.respond 'Unfortunantly you\'ve already claimed your free life this month!'
        end
      end
    else
      event.respond 'Only AuthKey donors may use this command!'
      break
    end
  end
end
