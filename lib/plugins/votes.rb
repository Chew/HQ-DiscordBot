module Votes
  extend Discordrb::Commands::CommandContainer

  command(:votes) do |event|
    voterbois = DBHelper.getvotes(event.user.id)

    month = voterbois[0]
    all = voterbois[1]

    begin
      event.channel.send_embed do |embed|
        embed.title = 'HQ Trivia Bot Voting'
        embed.colour = 0xd084
        embed.url = 'https://discordbots.org/bot/463127758143225874/vote'

        embed.add_field(name: 'Your Vote Count', value: [
          "Week - #{month}",
          "All-Time - #{all}"
        ].join("\n"), inline: true)
        if Bot.server(463_178_169_105_645_569).members.include? event.user
          embed.add_field(name: 'Your Current Vote Perks', value: 'None! (Yet!)', inline: true)
        else
          embed.add_field(name: 'Your Current Vote Perks', value: 'Sorry, but you need to be on the [HQ Trivia Bot server](https://discord.gg/Wr2yawT) to get sweet perks.', inline: true)
        end
        if !CONFIG['dbotsorg'].nil? && DBL.stats.verifyvote(event.user.id)
          embed.add_field(name: 'Can vote now?', value: 'Nope! Thanks for voting :D', inline: true)
        elsif !CONFIG['dbotsorg'].nil?
          embed.add_field(name: 'Can vote now?', value: 'Yes! [Vote](https://discordbots.org/bot/463127758143225874/vote) for perks!', inline: true)
        end
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
