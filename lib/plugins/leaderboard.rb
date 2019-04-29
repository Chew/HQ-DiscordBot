module Leaderboard
  extend Discordrb::Commands::CommandContainer

  command(:leaderboard, aliases: %i[lb leader rank ranks], min_args: 0) do |event, *args|
    stuff = args.join(' ').downcase

    page = 1

    args.each do |e|
      page = e.to_i if e.to_i != 0
    end

    page = 10 if page > 11
    page = 1 if page < 1

    type = if stuff.include?('all')
             0
           else
             1
           end

    region = if stuff.include?('us')
               ['US', 'United States', 'MQ==']
             elsif stuff.include?('uk')
               ['UK', 'United Kingdom', 'Mg==']
             elsif stuff.include?('de')
               ['DE', 'Germany', 'Mw==']
             elsif stuff.include?('au')
               ['AU', 'Australia', 'NA==']
             else
               ['US', 'United States', 'MQ==']
             end

    words = stuff.include?('words')

    game = ('hq-words' if words)

    leaders = RestClient.get('https://api-quiz.hype.space/users/leaderboard',
                             params: { mode: type, type: game },
                             Authorization: CONFIG['api'],
                             'x-hq-stk': region[2],
                             'Content-Type': :json)

    leaders = JSON.parse(leaders)

    leadernames = []
    leadermoney = []
    leaderwins  = []

    leaders['data'].each do |wow|
      leadernames[leadernames.length] = wow['username']
      leadermoney[leadermoney.length] = format('%.2f', (wow['totalCents'].to_i / 100.0))
      leaderwins[leaderwins.length] = wow['wins']
    end

    output = []

    100.times do |excuse|
      output.push "\##{excuse + 1}: #{leadernames[excuse]} - $#{leadermoney[excuse]} (#{leaderwins[excuse]} wins)"
    end

    tie = if type.zero?
            'All-Time'
          else
            'Weekly'
          end

    wordshow = 'Words ' if words

    begin
      event.channel.send_embed do |embed|
        embed.title = "Leaderboards for #{wordshow}#{region[1]} #{tie} (page #{page})"
        embed.colour = '36399A'
        embed.description = output[0 + ((page - 1) * 10)..9 + ((page - 1) * 10)].join("\n")
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
