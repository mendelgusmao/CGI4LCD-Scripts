require 'open-uri'
require 'fileutils'
require 'syndication/rss'
require_relative './simplecache'

# $dll(cgi,1,rss.rb,rss#<feed url>;<item index>)
def rss url, index = 0
    parser = Syndication::RSS::Parser.new
    feed = parser.parse(cache(url, 900)[0])
    feed.items[index.to_i].title unless feed.items[index.to_i].nil?
end

main()