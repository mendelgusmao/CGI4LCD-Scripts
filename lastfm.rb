require "nokogiri"
require 'open-uri'
require_relative './simplecache'

$api_key = "YOUR API KEY HERE"
$user = "YOUR LASTFM USERNAME HERE"
$timeout = 900

def _request user, method, limit, append = ""
  url = "http://ws.audioscrobbler.com/2.0/?method=%s&user=%s&limit=%s&api_key=%s&%s" % [method, user, limit, $api_key, append]
  data, missed = cache(url, $timeout)
  [Nokogiri::XML(data), missed]
end

# $dll(cgi,1,lastfm.rb,recent#<index>)
def recent index

  cached_tracks, missed = cache("file://cache/lastfm" + index, 60, true)

  if missed

    friends = _request($user, "user.getfriends", 100)[0].xpath("//friends/user")
    recent_tracks = []

    friends.each do |friend|
      friend_name = friend.xpath("name").text
      
      begin
        tracks, missed = _request(friend_name, "user.getrecenttracks", 4)
        tracks = tracks.xpath("//recenttracks/track")
      rescue
        next
      end
      
      tracks.each do |track|
        artist = track.xpath("artist").text
        title = track.xpath("name").text
        album = track.xpath("album").text
        played = track.xpath("date").first.attributes["uts"].value.to_i unless track.xpath("date").empty?
        
        recent_tracks << [friend_name, artist, title, album, played]

      end

      sleep 1 if missed

    end

    recent_tracks.sort_by! { |a| a.last.to_i }.reverse!
    cache("file://cache/lastfm" + index, 0, true, Marshal.dump(recent_tracks[0..9]))
  else
    recent_tracks = Marshal.load(cached_tracks)
  end

  "[%s] %s - %s" % recent_tracks[index.to_i]

end

def tasteometer index

  cached_tracks, missed = cache("file://cache/lastfm/taste" + index, 120, true)

  if missed

    friends = _request($user, "user.getfriends", 100)[0].xpath("//friends/user")
    comparisons = []

    friends.each do |friend|
      friend_name = friend.xpath("name").text
      
      comparison, missed = _request(friend_name, "tasteometer.compare", 3, "type1=user&type2=user&value1=%s&value2=%s" % [$user, friend_name])
      bands = comparison.xpath("//comparison/result/artists/artist").map { |e| e.xpath("name") }.join ", "
      comparison = comparison.xpath("//comparison/result/score").text
      
      comparisons << [ friend_name, comparison.to_f * 100, bands ]

      sleep 1 if missed

    end

    comparisons.sort_by! { |a| a[1] }.reverse!
    cache("file://cache/lastfm/taste" + index, 0, true, Marshal.dump(comparisons[0..9]))
  else
    comparisons = Marshal.load(cached_tracks)
  end

  "[%s] %02.1f%% (%s)" % comparisons[index.to_i]

end

main()
