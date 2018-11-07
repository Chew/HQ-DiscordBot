module Eval
  extend Discordrb::Commands::CommandContainer

  command(:eval) do |event, *code|
    break unless event.user.id == CONFIG['owner_id']

    begin
      event.channel.send_embed do |e|
        e.title = '**Evaluated Successfully**'

        evaluated = eval code.join(' ')

        e.description = evaluated.to_s
        e.color = '00FF00'
      end
    rescue StandardError => f
      event.channel.send_embed do |e|
        e.title = '**Evaluation Failed!**'

        e.description = f.to_s
        e.color = 'FF0000'
      end
    end
  end
end
