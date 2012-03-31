require 'digest/sha1'
require 'fileutils'

class Simplecache

    def self.cache url, timeout = 60, binary = false, forced_content = nil
        content = ""
        missed = false
        
        binary = binary ? "b" : ""
        
        cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".txt" ].join("")

        unless forced_content.nil?
          open(cache_file, "w" + binary) { |file| file.write(forced_content) }
          return forced_content
        end

        if url[/^file:/] and !File::exists?(url)
          url = cache_file 
        end

        if !File::exists?(cache_file)
            FileUtils::touch([cache_file]) 
            timeout = 0
        end
        
        if Time.now - File.new(cache_file).mtime > timeout
            open(url, "r" + binary) { |file| content = file.read }
            open(cache_file, "w" + binary) { |file| file.write(content) }
            missed = true
        else
            open(cache_file, "r" + binary) { |file| content = file.read }
            missed = false
        end
       
        [content, missed, cache_file]
    end
    
    def self.store url, to_append = nil, &block

        cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".txt" ].join("")
        
        if !File::exists?(cache_file)
            FileUtils::touch([cache_file]) 
        end        
        
        content = open(cache_file, "rb") { |file| file.read }
        
        begin
            content = Marshal.load(content)
        rescue
            content = []
        end
        
        content += to_append
        content = yield(content) if block_given?
        
        open(cache_file, "wb") { |file| file.write(Marshal.dump(content)) }
        
        content
    end

end    