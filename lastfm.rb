require "nokogiri"
require_relative './simplecache'

$api_key = "6b949cd0b531b1617e92af79343f3b5b"
$timeout = 900 # seconds (15 minutes)

def _request user, method, limit, append = ""
  url = "http://ws.audioscrobbler.com/2.0/?method=%s&user=%s&limit=%s&api_key=%s&%s" % [method, user, limit, $api_key, append]
  data, missed = Simplecache::cache(url, $timeout)
  [Nokogiri::XML(data), missed]
end

# $dll(cgi,1,lastfm.rb,recent#<username>;<index>)
def recent user, index

  friends = _request(user, "user.getfriends", 100, "&recenttracks=1").first.xpath("//friends/user")
  recent_tracks = []

  friends.each do |friend|
    friend_name = friend.xpath("name").text
    track = friend.xpath("recenttrack")

    artist = track.xpath("artist/name").text
    title = track.xpath("name").text
    album = track.xpath("album/name").text
    played = track.xpath("@uts").first.nil? ? 0 : track.xpath("@uts").first.value.to_i

    recent_tracks << [friend_name, artist, title, album, played]
  end

  recent_tracks = Simplecache::store("lastfm:recent", recent_tracks) do |content, to_append|
    content += to_append
    content.compact.uniq.sort_by{ |i| i.last }.reverse[0..10]
  end

  "[%s] %s - %s" % recent_tracks[index.to_i]

end

# $dll(cgi,1,lastfm.rb,tasteometer#<username>;<index>)
def tasteometer user, index

  friends = _request(user, "user.getfriends", 100).first.xpath("//friends/user")
  comparisons = []

  friends.each do |friend|
    friend_name = friend.xpath("name").text
    
    comparison, missed = _request(friend_name, "tasteometer.compare", 3, "type1=user&type2=user&value1=%s&value2=%s" % [user, friend_name])
    bands = comparison.xpath("//comparison/result/artists/artist").map { |e| e.xpath("name") }.join ", "
    comparison = comparison.xpath("//comparison/result/score").text
    
    comparisons << [ friend_name, comparison.to_f * 100, bands ]

    # uncomment the line below if last.fm starts blocking requests
    # sleep 1 if missed

  end

  comparisons = Simplecache::store("lastfm:tasteometer", comparisons) do |content, to_append|
    content += to_append
    content.compact.uniq{ |i| i.first }.sort_by{ |i| i[1] }.reverse[0..10]
  end

  "[%s] %02.2f%% (%s)" % comparisons[index.to_i]

end

main()
