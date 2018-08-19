module Question
  extend Discordrb::Commands::CommandContainer

  command(:question) do |event, delay = 10|
    delay = delay.to_i
    if delay > 60
      msg = 'What kind of question has a longer than minute time to answer the question?'
      delay = 60
    elsif delay.zero? || delay == -1
      msg = 'Answer will not be revealed...'
    elsif delay < 2
      msg = 'What kind of question gives you less than 2 seconds to answer it?'
      delay = 2
    end
    filename = "profiles/#{event.user.id}.yaml"
    if File.exist?(filename)
      profile = YAML.load_file(filename)
      if profile['donator'].nil? || profile['donator'] == false
        event.respond 'Hey, Scott Rogowsky here, because this command is in beta, only donators may use this command, but it will be available to everyone very soon!'
        break
      end
    else
      event.respond 'Hey, Scott Rogowsky here, because this command is in beta, only donators may use this command, but it will be available to everyone very soon!'
      break
    end
    data = JSON.parse(RestClient.get('http://api.chew.pro/hq/random'))
    m = event.channel.send_embed(msg) do |embed|
      embed.title = data['question']['question']
      embed.colour = 0x66e8a9
      embed.description = [
        data['question']['choice1'],
        data['question']['choice2'],
        data['question']['choice3']
      ].join("\n")

      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'HQ Random Question')
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Answer will be revealed in ' + delay.to_s + ' seconds...') unless delay.zero? || delay == -1
    end
    if delay.zero? || delay == -1
      break
    else
      sleep delay
    end
    cor = data['question']['correct']
    c1 = data['question']['choice1'] + ' - ' + data['choices']['picked1']
    c2 = data['question']['choice2'] + ' - ' + data['choices']['picked2']
    c3 = data['question']['choice3'] + ' - ' + data['choices']['picked3']
    case cor
    when '1'
      c1 = ':heavy_check_mark:' + c1
      c2 = ':x:' + c2
      c3 = ':x:' + c3
    when '2'
      c1 = ':x:' + c1
      c2 = ':heavy_check_mark:' + c2
      c3 = ':x:' + c3
    when '3'
      c1 = ':x:' + c1
      c2 = ':x:' + c2
      c3 = ':heavy_check_mark:' + c3
    end
    m.edit('', Discordrb::Webhooks::Embed.new(
                 title: data['question']['question'],
                 description: [c1, c2, c3].join("\n"),
                 footer: {text: 'This question was asked:'},
                 timestamp: Time.parse(data['game']['time'])
               ))
  end
end
