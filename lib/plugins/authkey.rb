module AuthKey
  extend Discordrb::Commands::CommandContainer

  command(:authkey, min_args: 0) do |event, *args|
    unless event.channel.pm?
      event.respond 'This command only works in DMs!'
      event.message.delete
      break
    end

    if args.empty?
      event.respond 'No key specified, make sure you get a key from <https://chew.pw/hqbot/authkey>'
      break
    end

    m = event.respond '<a:loading:393852367751086090> Checking your profile...'
    user = BotUser.new(event.user.id)
    unless user.exists?
      m.edit "<:xmark:314349398824058880> You don't have a profile! Type `hq, profile` and try again."
      break
    end
    m.edit "<:check:314349398811475968> Profile found!\n<a:loading:393852367751086090> Checking to see if key is valid..."
    key = args.join(' ')
    key = "Bearer #{key}" unless key.include?('Bearer ')
    begin
      testing = HT.get('users/me', key)
    rescue RestClient::Unauthorized
      m.edit "<:check:314349398811475968> Profile found!\n<:xmark:314349398824058880> Key is invalid! Did you copy it correctly?"
      break
    end
    m.edit "<:check:314349398811475968> Profile found!\n<:check:314349398811475968> Key is valid!"
    file = 'keys.json'
    keys = JSON.parse(File.read(file))
    keys[testing['userId'].to_s] = key
    File.open(file, 'w') do |f|
      f.write(JSON.pretty_generate(keys))
    end
    DBHelper.updateuser(event.user.id, 'authkey', 1)
    DBHelper.updateuser(event.user.id, 'keyid', testing['userId'])

    m.edit "<:check:314349398811475968> Profile found!\n<:check:314349398811475968> Key is valid!!\n\nBe sure to modify your profile on the official profile editing site found here: <https://chew.pw/hqbot>.\n\nYour key will expire in 3 months."
  end

  command(:keystatus) do |event|
    user = BotUser.new(event.user.id)
    unless user.exists?
      m.edit "<:xmark:314349398824058880> You don't have a profile! Type `hq, profile` and try again."
      break
    end
    keys = JSON.parse(File.read('keys.json'))

    decoded_token = JWT.decode keys[user.keyid].gsub('Bearer ', ''), nil, false
    event.channel.send_embed do |embed|
      embed.description = 'Your key will expire at'
      embed.timestamp = Time.at(decoded_token[0]['exp'])
    end
  end

  command(:expiredkeys) do |event|
    break unless event.user.id == CONFIG['owner_id']

    keys = JSON.parse(File.read('keys.json'))

    gone = []

    keys.each do |key, data|
      decoded_token = JWT.decode data.gsub('Bearer ', ''), nil, false
      expire = Time.at(decoded_token[0]['exp'])
      gone.push(key) if expire < Time.now
    end

    event.channel.send_embed do |embed|
      embed.description = "Expired Key IDs\n#{gone.join("\n")}"
    end
  end
end
