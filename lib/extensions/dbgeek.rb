class DbGeek
  def initialize; end

  def newuser(id, username, region)
    DB.query("INSERT INTO `hqtriviabot_profiles` (`userid`, `username`, `region`, `keyid`, `authkey`, `bughunter`, `lives`, `streaks`, `donator`) VALUES ('#{id}', '#{username}', '#{region}', '', '0', '0', '0', '0', '0')")
  end

  def getuser(id)
    DB.query("SELECT * FROM `hqtriviabot_profiles` WHERE `userid` = #{id.to_i}")
  end
end
