class BotUser
  def initialize(id)
    @id = id
    @helper = DbGeek.new
    result = @helper.getuser(id)
    result.each do |row|
      @results = row
    end
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
    @results['authkey'] == 1
  end

  def authkey=(updated)
    @helper.updateuser(@id, 'authkey', updated.to_i)
  end

  def bughunter?
    @results['bughunter'] == 1
  end

  def authkey=(updated)
    @helper.updateuser(@id, 'authkey', updated.to_i)
  end

  def lives?
    @results['lives'] == 1
  end

  def lives=(updated)
    @helper.updateuser(@id, 'lives', updated.to_i)
  end

  def streaks?
    @results['streaks'] == 1
  end

  def streaks=(updated)
    @helper.updateuser(@id, 'streaks', updated.to_i)
  end

  def donator?
    @results['donator'] == 1
  end

  def donator=(updated)
    @helper.updateuser(@id, 'donator', updated.to_i)
  end
end
