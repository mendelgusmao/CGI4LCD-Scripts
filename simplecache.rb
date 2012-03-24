require 'digest/sha1'
require 'fileutils'

def cache url, timeout = 60, binary = false, forced_content = nil
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
        open(cache_file, "rb" + binary) { |file| content = file.read }
        missed = false
    end
   
    [content, missed]
end
