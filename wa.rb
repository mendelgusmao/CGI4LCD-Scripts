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

def state
  case winamp().playstate
    when 1; "$CustomChar(1,0,8,12,14,12,8,0,0)$Chr(176)"
    when 3; "$CustomChar(1,0,0,10,10,10,10,0,0)$Chr(176)"
    when 0; "$CustomChar(1,0,0,30,30,30,30,0,0)$Chr(176)"
  end
end

main()