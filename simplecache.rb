require 'open-uri'
require 'yaml'
require 'sqlite3'

class Simplecache

  @@db = SQLite3::Database.new("cache/simple.s3db")

  begin
    @@db.execute("SELECT url FROM cache LIMIT 1")
  rescue
    @@db.execute("CREATE TABLE [cache] ([url] TEXT  UNIQUE NOT NULL PRIMARY KEY, [content] TEXT  NULL, [created] TIMESTAMP DEFAULT CURRENT_TIMESTAMP NULL)")
    @@db.execute("CREATE TABLE [store] ([url] TEXT  NOT NULL, [position] INTEGER  NOT NULL, [content] TEXT  NULL, PRIMARY KEY ([url],[position]))")
  end
  
  def self.cache url, timeout = 60
    content = ""
    missed = false

    rows = @@db.execute("SELECT url, content, created FROM cache WHERE url = ? LIMIT 1", url)

    if rows.empty? 
      created = Time.now
      timeout = 0
    else
      content = rows.first[1]
      rows.first[2] =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/
      created = Time.send(:new, $1, $2, $3, $4, $5, $6.to_i)
    end

    if Time.now - created >= timeout
      content = open(url, "r") { |file| file.read }
      @@db.execute("REPLACE INTO cache (url, content, created) VALUES (?, ?, ?)", url, content, Time.now.to_s) 
      missed = true
    end
    
    [content, missed]

  end
  
  def self.store url, to_append = [], &block

    entries = []
  
    @@db.execute("SELECT content FROM store WHERE url = ? ORDER BY position", url) do |row|
      entries << YAML::load(row[0])
    end  
  
    filtered_entries = yield(entries, to_append) if block_given?

    if filtered_entries != entries
      @@db.execute("DELETE FROM store WHERE url = ?", url)

      position = 0
      filtered_entries.each do |entry|
        @@db.execute("INSERT INTO store (url, position, content) VALUES (?, ?, ?)", url, position, YAML::dump(entry))
        position += 1
      end
      
    end

    filtered_entries

  end

end
