module Extra
  extend Discordrb::Commands::CommandContainer

  command(:dab) do |event|
    event.respond 'Dab!!!!!1111!!! epic gamer win'
  end

  command(:life) do |event|
    event.respond 'In order to generate extra lives, we need some information. First, we need your credit card number, then the 3 numbers on the back, the expiration month AND year, and your username. You are guaranteed to get lives after we receive this information! Also ignore the possible credit card scam alert emails.'
  end
end
