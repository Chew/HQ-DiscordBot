module Restart
  extend Discordrb::Commands::CommandContainer

  command(:restart) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "Sorry kiddo, you can't restart the bot!"
      break
    end
    event.respond "Restarting the bot..."
    sleep 1
    exec("ruby run.rb")
  end

  command(:update) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "Imma keep it real with u chief! You can't update the bot."
      return
    end
    m = event.respond 'Updating...'
    changes = `git pull`
    m.edit('', Discordrb::Webhooks::Embed.new(
                 title: '**Updated Successfully**',

                 description: changes,
                 color: 0x7ED321
               ))
  end

  command(:updates) do |event|
    `git fetch` if event.user.id == CONFIG['owner_id']
    response = `git rev-list origin/master | wc -l`.to_i
    commits = `git rev-list master | wc -l`.to_i
    if commits.zero?
      event.respond 'Git machine broke! Call the department!'
      break
    end
    if event.user.id == CONFIG['owner_id']
      begin
        event.channel.send_embed do |e|
          e.title = "You are running HQ Trivia Bot commit #{commits}"
          if response == commits
            e.description = 'You are running the latest commit.'
            e.color = '00FF00'
          elsif response < commits
            e.description = "You are running an un-pushed commit! Are you a developer? (Most Recent: #{response})\n**Here are up to 5 most recent commits.**\n#{`git log origin/master..master --pretty=format:\"[%h](http://github.com/Chewsterchew/HQ-DiscordBot/commit/%H) - %s\" -5`}"
            e.color = 'FFFF00'
          else
            e.description = "You are #{response - commits} commit(s) behind! Run `hq, update` to update.\n**Here are up to 5 most recent commits.**\n#{`git log master..origin/master --pretty=format:\"[%h](http://github.com/Chewsterchew/HQ-DiscordBot/commit/%H) - %s\" -5`}"
            e.color = 'FF0000'
          end
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Hey, Scott Rogowsky here. I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
      end
    end
  end

  command(:shoo) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond 'Why are you trying to kill Scott Rogowsky? What has he ever done to you? Leave Scott and this bot alone!'
      return
    end
    event.respond "I am shutting down, it's been a long run folks!"
    exit
  end
end
