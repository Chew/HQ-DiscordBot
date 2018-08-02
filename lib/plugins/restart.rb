module Restart
  extend Discordrb::Commands::CommandContainer

  command(:restart) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "You can't restart! (If you are the owner of the bot, you did not configure properly! Otherwise, stop trying to update the bot!)"
      break
    end
    event.respond 'Restarting the bot without updating...'
    sleep 1
    exec('ruby run.rb')
  end

  command(:update) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "You can't update! (If you are the owner of the bot, you did not configure properly! Otherwise, stop trying to update the bot!)"
      return
    end
    event.respond 'Restarting and Updating!'
    sleep 1
    `git pull`
    exec('ruby run.rb')
  end

  command(:updates) do |event|
    `git fetch` if event.user.id == CONFIG['owner_id']
    response = `git rev-list origin/master | wc -l`.to_i
    commits = `git rev-list master | wc -l`.to_i
    if commits.zero?
      event.respond "Your machine doesn't support git or it isn't working!"
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
            e.description = "You are #{response - commits} commit(s) behind! Run `%^update` to update.\n**Here are up to 5 most recent commits.**\n#{`git log master..origin/master --pretty=format:\"[%h](http://github.com/Chewsterchew/HQ-DiscordBot/commit/%H) - %s\" -5`}"
            e.color = 'FF0000'
          end
        end
      rescue Discordrb::Errors::NoPermission
        event.respond "SYSTEM ERRor, I CANNot SEND THE EMBED, EEEEE. Can I please have the 'Embed Links' permission? Thanks, appriciate ya."
      end
    end
  end

  command(:shoo) do |event|
    break unless event.user.id == CONFIG['owner_id']
    event.send_temporary_message('I am shutting dowm, it\'s been a long run folks!', 3)
    sleep 3
    exit
  end
end
