module Extra
  extend Discordrb::Commands::CommandContainer

  command(:dab) do |event|
    event.respond 'Dabbed!111!!11!!!1!!11!!11!!11!! epic gamer win'
  end

  command(:life) do |event|
    event.respond 'In order to generate extra lives, we need some information. First, we need your credit card number, then the 3 numbers on the back, the expiration month AND year, and your username. You are guaranteed to get lives after we receive this information! Also ignore the possible credit card scam alert emails.'
  end

  command(:answer) do |event|
    event.respond 'Print the results of live question on HQ Trivia .ac (channel id).'
  end

  command(:epic) do |event|
    event.respond 'Okay, now this is epic.'
  end

  command(:its) do |event|
    event.respond 'https://cdn.discordapp.com/attachments/440364222392827904/514152155578630167/IMG_3911.PNG'
  end

  command(:t) do |event, user|
    event.channel.send_embed do |e|
      e.description = "#{user} is qt"
    end
  end
end
