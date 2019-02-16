module Eval
  extend Discordrb::Commands::CommandContainer

  command(:eval) do |event, *code|
    break unless event.user.id == CONFIG['owner_id'] || event.user.id == 484040243818004491

    begin
      event.channel.send_embed do |e|
        e.title = '**Evaluated Successfully**'

        prefix = event.message.content.tr("\n", ' ').gsub(code.join(' '), '')

        evaluated = eval event.message.content.gsub(prefix, '').tr("\n", ';')

        e.description = evaluated.to_s
        e.color = '00FF00'
      end
    rescue StandardError, ScriptError => f
      event.channel.send_embed do |e|
        e.title = '**Evaluation Failed!**'

        e.description = f.to_s
        e.color = 'FF0000'
      end
    end
  end
end
