require 'syndication/rss'
require_relative './simplecache'

$timeout = 300 # seconds

# $dll(cgi,1,rss.rb,rss#<feed url>;<type>;<item index>;<maxfreq>)
def rss url, type = "t", itemnum = 0, maxfreq = $timeout

  type = "t" unless type[/[tdb]/]
  itemnum = itemnum.to_i

  parser = Syndication::RSS::Parser.new
  feed = parser.parse(Simplecache::cache(url, maxfreq).first)

  items = feed.items.nil? ? [] : feed.items.map do |item| 
    body = case type
      when "t" then item.title
      when "d" then item.description
      when "b" then item.title + ":" + item.description
    end
    [ item.pubdate, body ]
  end
  
  items = Simplecache::store(url, items) do |content, to_append|
    content += to_append
    content.compact.uniq.sort_by{ |i| i.first }.reverse.slice(0..10)
  end
  
  if itemnum == 0
    response = items.join(" | ")
  else
    unless items.nil? or items[itemnum].nil?
      response = items[itemnum].last
    else
      response = ""
    end
  end

  response.gsub!(/<\/?[^>]*>/, "").gsub!(/&[a-z]+;/, " ")

end

main()