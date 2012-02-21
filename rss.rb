require 'open-uri'
require 'fileutils'
require 'syndication/rss'
require_relative './simplecache'

def rss url, index = 0
    parser = Syndication::RSS::Parser.new
    feed = parser.parse(cache(url, 900))
    feed.items[index.to_i].title unless feed.items[index.to_i].nil?
end

main()