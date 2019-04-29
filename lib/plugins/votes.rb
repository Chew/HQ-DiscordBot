module Votes
  extend Discordrb::Commands::CommandContainer

  command(:votes) do |event|
    voterbois = DBHelper.getvotes(event.user.id)

    month = voterbois[0] || 0
    all = voterbois[1] || 0

    begin
      event.channel.send_embed do |embed|
        embed.title = 'HQ Trivia Bot Voting'
        embed.colour = 0xd084
        embed.url = 'https://discordbots.org/bot/hq/vote'

        embed.description = '[Find the top voters!](https://chew.pw/hqbot/votes)'

        embed.add_field(name: 'Your Vote Count', value: [
          "Month - #{month}",
          "All-Time - #{all}"
        ].join("\n"), inline: true)
        if event.bot.server(463_178_169_105_645_569).members.include? event.user
          embed.add_field(name: 'Your Current Vote Perks', value: 'None! (Yet!)', inline: true)
        else
          embed.add_field(name: 'Your Current Vote Perks', value: 'Sorry, but you need to be on the [HQ Trivia Bot server](https://discord.gg/Wr2yawT) to get sweet perks.', inline: true)
        end
        unless CONFIG['dbotsorg'].nil?
          status = if DBL.stats.verifyvote(event.user.id)
                     'Nope! Thanks for voting :D'
                   else
                     'Yes! [Vote](https://discordbots.org/bot/hq/vote) for perks!'
                   end
          embed.add_field(name: 'Can vote now?', value: status, inline: true)

          tot = DBL.self

          totmonth = tot.monthlyvotes
          totalltime = tot.votes

          # hey = ["#{totmonth} (#{permonth}%)", "#{totalltime} (#{perall}%)"]
          hey = ["Month - #{totmonth}", "All-Time - #{totalltime} "]

          embed.add_field(name: 'Bot Votes', value: hey.join("\n"), inline: true)
        end
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
