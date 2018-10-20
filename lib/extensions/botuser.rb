class BotUser
  def initialize(id)
    result = DbGeek.new.getuser(id)
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

  def region
    @results['region']
  end

  def keyid
    @results['keyid']
  end

  def authkey?
    @results['authkey'] == 1
  end

  def bughunter?
    @results['bughunter'] == 1
  end

  def lives?
    @results['lives'] == 1
  end

  def streaks?
    @results['streaks'] == 1
  end

  def donator?
    @results['donator'] == 1
  end
end
