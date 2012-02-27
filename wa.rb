require "win32ole"

def winamp
  WIN32OLE.connect "ActiveWinamp.Application"
end

# $dll(cgi,1,wa.rb,get#artist|title|album|year|...)
def get field
    winamp = winamp()
    position = winamp.playlist.position
    winamp.playlist(position).ATFString("%#{field}%")
end

main()