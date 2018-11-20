class DbGeek
  def initialize; end

  def newuser(id, username, region)
    DB.query("INSERT INTO `hqtriviabot_profiles` (`userid`, `username`, `region`, `keyid`, `authkey`, `bughunter`, `lives`, `streaks`, `donator`) VALUES ('#{id}', '#{username}', '#{region}', '', '0', '0', '0', '0', '0')")
  end

  def getuser(id)
    DB.query("SELECT * FROM `hqtriviabot_profiles` WHERE `userid` = #{id.to_i}")
  end

  def updateuser(id, item, value)
    DB.query("UPDATE `hqtriviabot_profiles` SET `#{item}` = '#{value}' WHERE `hqtriviabot_profiles`.`userid` = #{id.to_i}")
  end

  def getvotes(id)
    result = DB.query("SELECT * FROM `hqtriviabot_votes` WHERE `userid` = #{id.to_i}")
    results = ''
    result.each do |row|
      results = row
    end
    [results['month'], results['alltime']]
  end

  def getallvotes
    DB.query('SELECT * FROM `hqtriviabot_votes`')
  end
end
