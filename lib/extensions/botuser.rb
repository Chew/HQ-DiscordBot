class BotUser
  def initialize(id)
    @id = id
    @helper = DbGeek.new
    @results = @helper.getuser(id)
  end

  def exists?
    !@results.nil?
  end

  def userid
    @results['userid']
  end

  def username
    @results['username']
  end

  def username=(updated)
    @helper.updateuser(@id, 'username', updated)
  end

  def region
    @results['region']
  end

  def region=(updated)
    @helper.updateuser(@id, 'region', updated)
  end

  def keyid
    @results['keyid']
  end

  def keyid=(updated)
    @helper.updateuser(@id, 'keyid', updated)
  end

  def authkey?
    @results['authkey']
  end

  def authkey=(updated)
    @helper.updateuser(@id, 'authkey', updated.to_i)
  end

  def bughunter?
    @results['bughunter']
  end

  def bughunter=(updated)
    @helper.updateuser(@id, 'bughunter', updated.to_i)
  end

  def lives?
    @results['lives']
  end

  def lives=(updated)
    @helper.updateuser(@id, 'lives', updated.to_i)
  end

  def erase1s?
    @results['erase1s']
  end

  def erase1s=(updated)
    @helper.updateuser(@id, 'erase1s', updated.to_i)
  end

  def streaks?
    @results['streaks']
  end

  def streaks=(updated)
    @helper.updateuser(@id, 'streaks', updated.to_i)
  end

  def donator?
    @results['donator']
  end

  def donator=(updated)
    @helper.updateuser(@id, 'donator', updated.to_i)
  end

  def superspins?
    @results['superspins']
  end

  def superspins=(updated)
    @helper.updateuser(@id, 'superspins', updated.to_i)
  end

  def coins?
    @results['coins']
  end

  def coins=(updated)
    @helper.updateuser(@id, 'coins', updated.to_i)
  end

  def keyid
    @results['keyid']
  end
end
