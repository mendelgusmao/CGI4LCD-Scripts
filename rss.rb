require 'open-uri'
require 'fileutils'
require 'syndication/rss'
require_relative './simplecache'

$timeout = 300

# $dll(cgi,1,rss.rb,rss#<feed url>;<item index>)
def rss url, index = 0

  cached_items = cache("file://cache/rss/" + url, 60).first

  begin
    cached_items = Marshal.load(cached_items)
  rescue
    cached_items = []
  end

  parser = Syndication::RSS::Parser.new

  items = parser.parse(cache(url, $timeout).first).items.map { |item|
    [item.pubdate, item.title]
  }

  items += cached_items
  items = items.compact.uniq.sort_by{ |i| i.first }.reverse.slice(0..10)

  cache("file://cache/rss/" + url, 0, true, Marshal.dump(items))
  ""
  items[index.to_i].last unless items.nil? or items[index.to_i].nil?

end

main()