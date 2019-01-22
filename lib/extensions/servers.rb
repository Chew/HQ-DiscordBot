class Servers
  def initialize(shards)
    @shards = shards
  end

  attr_reader :shards

  def post(count, shard)
    DBL.stats.updateservercount(count, shard, @shards) unless CONFIG['dbotsorg'].nil?
    RestClient.post("https://discord.bots.gg/api/v1/bots/#{CONFIG['client_id']}/stats", { 'guildCount': count, 'shardCount': @shards, 'shardId': shard }, Authorization: CONFIG['dbotsgg'], 'Content-Type': :json) unless CONFIG['dbotsgg'].nil?
    true
  rescue StandardError
    false
  end

  def updateall(counts)
    counts.each_with_index do |e, i|
      return false unless post(e, i)
    end
    true
  end
end
