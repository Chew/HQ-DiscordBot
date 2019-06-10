class DbGeek
  def initialize; end

  def newuser(id, username, region)
    data = {
      "id": id,
      "username": username,
      "region": region
    }
    RestClient.post('https://stats.hqtrivia.pro/api/newuser', data, Authorization: CONFIG['sta_api'])
  end

  def getuser(id)
    JSON.parse(RestClient.get("https://stats.hqtrivia.pro/api/user/#{id}", Authorization: CONFIG['sta_api']))
  end

  def updateuser(id, item, value)
    data = {
      "item": item,
      "value": value
    }
    RestClient.put("https://stats.hqtrivia.pro/api/user/#{id}/edit", data, Authorization: CONFIG['sta_api'])
  end

  def getvotes(id)
    results = JSON.parse(RestClient.get("https://stats.hqtrivia.pro/api/user/#{id}/votes", Authorization: CONFIG['sta_api'])).each {} [0]
    [results['month'], results['alltime']]
  end

  def getallvotes
    JSON.parse(RestClient.get('https://stats.hqtrivia.pro/api/votes', Authorization: CONFIG['sta_api'])).each {}
  end
end
