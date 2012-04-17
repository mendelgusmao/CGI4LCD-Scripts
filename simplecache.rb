require 'open-uri'
require 'sqlite3'

class Simplecache

  @@db = SQLite3::Database.new("cache/simple.s3db")
  @@db.busy_timeout(500)

  begin
    @@db.execute("SELECT url FROM cache LIMIT 1")
  rescue
    @@db.execute("CREATE TABLE [cache] ([url] TEXT UNIQUE NOT NULL PRIMARY KEY, [content] TEXT NULL, [created] TIMESTAMP DEFAULT CURRENT_TIMESTAMP NULL)")
    @@db.execute("CREATE TABLE [store] ([url] TEXT NOT NULL, [position] INTEGER NOT NULL, [content] BLOB NULL)")
  end
  
  def self.cache url, timeout = 60
    content = ""
    missed = false

    cached = @@db.execute("SELECT content, created FROM cache WHERE url = ? LIMIT 1", url).first

    if cached.nil? 
      created = Time.now
      timeout = 0
    else
      content = cached.first
      cached.last =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/
      created = Time.new($1, $2, $3, $4, $5, $6.to_i)
    end

    if Time.now - created >= timeout
      content = open(url, "r") { |file| file.read }
      @@db.execute("REPLACE INTO cache (url, content, created) VALUES (?, ?, ?)", url, content, Time.now.to_s) 
      missed = true
    end
    
    [content, missed]

  end
  
  def self.store url, to_append = [], &block
  
    entries = @@db.execute("SELECT content FROM store WHERE url = ? ORDER BY position", url).map { |r| Marshal::load(r.first) }
  
    filtered_entries = yield(entries, to_append) if block_given?

    if filtered_entries != entries
      @@db.execute("DELETE FROM store WHERE url = ?", url)

      position = 0
      filtered_entries.each do |entry|
        @@db.execute("INSERT INTO store (url, position, content) VALUES (?, ?, ?)", url, position, Marshal::dump(entry))
        position += 1
      end
      
    end

    filtered_entries

  end

end
