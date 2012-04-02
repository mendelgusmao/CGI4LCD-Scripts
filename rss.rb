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
    body = { "t" => item.title, 
             "d" => item.description, 
             "b" => "%s:%s" % [item.title, item.description] }[type]

    [ item.pubdate, body ]
  end

  items = Simplecache::store(url + type, items) do |content, to_append|
    content += to_append
    content.compact.uniq.sort_by{ |i| i.first }.reverse.slice(0..10)
  end

  response = ""

  if itemnum == 0
    response = items.map{ |i| i.last }.join(" | ")
  else
    unless items.nil? or items[itemnum - 1].nil?
      response = items[itemnum - 1].last
    end
  end

  response.gsub(/<\/?[^>]*>/, "")
  
end

main()