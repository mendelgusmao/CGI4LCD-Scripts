require "nokogiri"
require 'open-uri'
require 'fileutils'
require_relative './simplecache'

$api_key = "YOUR API KEY HERE"
$user = "YOUR LASTFM USERNAME HERE"
$timeout = 900

def _request user, method, limit
  url = "http://ws.audioscrobbler.com/2.0/?method=%s&user=%s&limit=%s&api_key=%s" % [method, user, limit, $api_key]
  data, missed = cache(url, $timeout)
  [Nokogiri::XML(data), missed]
end

# $dll(cgi,1,lastfm.rb,recent#<index>)
def recent index

  cached_tracks, missed = cache("cache/lastfm", 60)

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
        formatted = "%s - %s (%s)" % [artist, title, album]
        played = track.xpath("date").first.attributes["uts"].value unless track.xpath("date").empty?
        
        recent_tracks << [friend_name, formatted, played.to_i]

      end

      sleep 1 if missed

    end

    cache("cache/lastfm", 0, Marshal.dump(recent_tracks))
  else
    recent_tracks = Marshal.load(cached_tracks)
  end

  "%s: %s" % recent_tracks.sort_by! { |a| a[2] }.reverse![index.to_i]

end

main()
