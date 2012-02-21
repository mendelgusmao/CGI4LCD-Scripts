require 'digest/sha1'

def cache url, timeout = 60
    content = ""
    
    cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".txt" ].join("")

    if !File::exists?(cache_file)
        FileUtils::touch([cache_file]) 
        timeout = 0
    end
    
    if Time.now - File.new(cache_file).mtime > timeout
        open(url) { |file| content = file.read }
        open(cache_file, "w") { |file| file.write(content) }
    else
        open(cache_file) { |file| content = file.read }
    end
   
    content
end