class Commandz
  def initialize
    @commands = 0
  end

  def add
    @commands += 1
  end

  def reset
    @commands = 0
  end

  attr_reader :commands
  alias get commands
end
