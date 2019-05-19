class Coin
  TRANSLATIONS = {
    'BTC' => ['Bitcoin', '<:bitcoin:568244517787009063>'],
    'BCH' => ['Bitcoin Cash', '<:bitcoin_cash:568244517745197089>'],
    'ETH' => ['Ethereum', '<:ethereum:568244517766037514>'],
    'ETC' => ['Ethereum Classic', '<:ethereum_classic:568244517732352000>'],
    'LTC' => ['Litecoin', '<:litecoin:568244517803917322>'],
    'BAT' => ['Basic Attention Token', '<:basic_attention_token:568244517778489424>'],
    'ZRX' => ['0x', '<:0x:568244517799591947>'],
    'REP' => ['Augur', '<:augur:568244517732483092>'],
    'XLM' => ['Stellar Lumens', '<:stellar_lumens:568244517778751489>'],
    'USDC' => ['USD Coin', '<:us_stablecoin:568244517887672338>'],
    'XRP' => ['Ripple', '<:ripple:568244517803917332>'],
    'ZEC' => ['Zcash', '<:zcash:568244517816238081>']
  }.freeze

  def initialize(name, balance, usd)
    @name = name
    @balance = balance
    @usd = usd
  end

  attr_reader :name
  attr_reader :balance
  attr_reader :usd

  def add(balance, usd)
    @balance += balance
    @usd += usd
  end

  def full
    TRANSLATIONS[@name][0]
  end

  def emoji
    TRANSLATIONS[@name][1]
  end
end
