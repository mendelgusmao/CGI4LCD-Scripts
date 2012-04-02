require 'syndication/rss'
require_relative './simplecache'

$timeout = 300

# $dll(cgi,1,rss.rb,rss#<feed url>;<item index>)
def rss url, index = 0

  parser = Syndication::RSS::Parser.new
  feed = parser.parse(Simplecache::cache(url, $timeout).first)

  items = feed.items.nil? ? [] : feed.items.map { |item| [item.pubdate, item.title] } 
  
  items = Simplecache::store(url, items) do |content, to_append|
    content += to_append
    content.compact.uniq.sort_by{ |i| i.first }.reverse.slice(0..10)
  end
  
  unless items.nil? or items[index.to_i].nil?
    items[index.to_i].last
  else
    ""
  end

end

main()