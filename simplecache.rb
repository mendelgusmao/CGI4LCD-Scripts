require 'digest/sha1'
require 'fileutils'
require 'open-uri'

class Simplecache

    def self.cache url, timeout = 60
        content = ""
        missed = false
        
        cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".txt" ].join("")

        if url[/^file:/] and !File::exists?(url)
          url = cache_file 
        end

        unless File::exists?(cache_file)
            FileUtils::touch([cache_file]) 
            timeout = 0
        end
        
        if Time.now - File.new(cache_file).mtime > timeout
            open(url, "r") { |file| content = file.read }
            open(cache_file, "w") { |file| file.write(content) }
            missed = true
        else
            open(cache_file, "r") { |file| content = file.read }
            missed = false
        end
       
        [content, missed, cache_file]
    end
    
    def self.store url, to_append = [], &block

        cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".marshal" ].join("")
        
        unless File::exists?(cache_file)
            FileUtils::touch([cache_file]) 
        end        
        
        content = open(cache_file, "rb") { |file| file.read }
        
        begin
            content = Marshal.load(content)
        rescue
            content = []
        end
        
        content = yield(content, to_append) if block_given?
        
        open(cache_file, "wb") { |file| file.write(Marshal.dump(content)) }
        
        content
    end

end    