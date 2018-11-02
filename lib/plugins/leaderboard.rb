module Leaderboard
  extend Discordrb::Commands::CommandContainer

  command(:leaderboard, aliases: %i[lb leader rank ranks], min_args: 0, max_args: 1) do |event, *hahayes|
    if type == 'weekly'
      type = 1
    elsif ['all-time', 'all', 'alltime'].include? type
      type = 0
    end
    type = type.to_i

    leaders = RestClient.get('https://api-quiz.hype.space/users/leaderboard',
                             params: { mode: type },
                             Authorization: CONFIG['api'],
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

    10.times do |excuse|
      output[excuse] = "\##{excuse + 1}: #{leadernames[excuse]} - $#{leadermoney[excuse]} (#{leaderwins[excuse]} wins)"
    end

    tie = if type.zero?
            'All-Time'
          else
            'Weekly'
          end

    begin
      event.channel.send_embed do |embed|
        embed.title = 'Top 10 Leaderboards for ' + tie
        embed.colour = '36399A'
        embed.description = output.join("\n")
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
