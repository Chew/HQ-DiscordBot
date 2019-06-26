module NextGame
  extend Discordrb::Commands::CommandContainer

  command(:nextgame, aliases: [:next]) do |event, *stuff|
    stuff = stuff.join(' ').downcase

    kind = []
    kind.push 'general'
    kind.delete 'general' if stuff.include?('sports') || stuff.include?('words')
    kind.push 'sports' if stuff.include? 'sports'
    kind.push 'words' if stuff.include? 'words'

    data = HT.get("shows/schedule", CONFIG['api'])

    # active = data['active']

    showstuff = ''

    data['shows'].each do |show|
      next unless showstuff == ''
      showstuff = show if kind.include? show['vertical']
    end

    begin
      prize = "$#{(showstuff['prizeCents'] / 100).to_i.to_sc}"

      prize = "#{prize}\n#{showstuff['prizePoints'] / 1_000_000}M points" unless showstuff['prizePoints'].nil? || showstuff['prizePoints'].zero?
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

        embed.add_field(name: 'Prize', value: prize, inline: true)
        embed.add_field(name: 'Type', value: gametype, inline: true)
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
