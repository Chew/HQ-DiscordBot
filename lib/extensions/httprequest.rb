class HTTPRequest
  def initialize; end

  def get(path, key)
    JSON.parse(RestClient.get("https://api-quiz.hype.space/#{path}",
                              Authorization: key,
                              'x-hq-device': 'iPhone10,4',
                              'x-hq-stk': 'MQ==',
                              'x-hq-deviceclass': 'phone',
                              'x-hq-timezone': 'America/Chicago',
                              'user-agent': 'HQ-iOS/147 CFNetwork/1085.4 Darwin/19.0.0',
                              'x-hq-country': 'us',
                              'x-hq-lang': 'en',
                              'x-hq-client': 'iOS/1.4.15 b146'))
  end

  def post(path, data, key)
    JSON.parse(RestClient.get("https://api-quiz.hype.space/#{path}",
                              data,
                              Authorization: key,
                              'x-hq-device': 'iPhone10,4',
                              'x-hq-stk': 'MQ==',
                              'x-hq-deviceclass': 'phone',
                              'x-hq-timezone': 'America/Chicago',
                              'user-agent': 'HQ-iOS/147 CFNetwork/1085.4 Darwin/19.0.0',
                              'x-hq-country': 'us',
                              'x-hq-lang': 'en',
                              'x-hq-client': 'iOS/1.4.15 b146',
                              'Content-Type': :json))
  end
end
