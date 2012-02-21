require "win32ole"

def _load field
    winamp = WIN32OLE.connect "ActiveWinamp.Application"
    position = winamp.playlist.position
    winamp.playlist(position).ATFString("%#{field}%")
end

def artist
    _load "artist"
end

def title
    _load "title"
end

def album
    _load "album"
end

def year
    _load "year"
end

main()