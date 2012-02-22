require "win32ole"

def _load field
    winamp = WIN32OLE.connect "ActiveWinamp.Application"
    position = winamp.playlist.position
    winamp.playlist(position).ATFString("%#{field}%")
end

# $dll(cgi,1,wa.rb,artist)
def artist
    _load "artist"
end

# $dll(cgi,1,wa.rb,title)
def title
    _load "title"
end

# $dll(cgi,1,wa.rb,album)
def album
    _load "album"
end

# $dll(cgi,1,wa.rb,year)
def year
    _load "year"
end

main()