module Crypto
  extend Discordrb::Commands::CommandContainer

  command(:crypto) do |event|
    if event.user.id != CONFIG['owner_id']
      event.respond 'Only Chew may see her coin count. Sorry!'
      break
    end

    values = {}
    accounts = Client.accounts

    total = 0

    accounts.each do |account|
      next if account['currency'] == 'USD'
      if values[account['currency']].nil?
        values[account['currency']] = Coin.new(account['currency'], account['balance']['amount'].to_f, account['native_balance']['amount'].to_f)
      else
        values[account['currency']].add(account['balance']['amount'].to_f, account['native_balance']['amount'].to_f)
      end
      total += account['native_balance']['amount'].to_f
    end

    event.channel.send_embed do |e|
      e.title = "Chew's Coins"
      e.description = "Portfolio: $#{total.round(2)}"

      values.sort_by { |_e, f| f.usd }.reverse_each do |_v, a|
        e.add_field(name: "#{a.emoji} #{a.full}", value: "#{a.balance.round(8)} #{a.name} ($#{a.usd.round(2)})", inline: true)
      end
    end
  end
end
