module Eval
  extend Discordrb::Commands::CommandContainer

  command(:eval) do |event, *code|
    break unless event.user.id == CONFIG['owner_id']

    begin
      event.channel.send_embed do |e|
        e.title = '**Evaluated Successfully**'

        prefix = event.message.content.tr("\n", ' ').gsub(code.join(' '), '')

        evaluated = eval event.message.content.gsub(prefix, '').tr("\n", ';')

        e.description = evaluated.to_s
        e.color = '00FF00'
      end
    rescue StandardError, ScriptError => e
      event.channel.send_embed do |embed|
        embed.title = '**Evaluation Failed!**'

        embed.description = e.to_s
        embed.color = 'FF0000'
      end
    end
  end
end
