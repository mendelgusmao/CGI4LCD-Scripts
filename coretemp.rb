require "open-uri"

# change to your core temp's directory
csv = Dir.glob("c:/program files/core temp/*.csv").last

$content = open(csv) do |file| 
    $content = file.read
end

def _parse index
  values = $content.split("\n")[-2].split(",")[index]
end

def temp;      
  _parse(1).to_i 
end   

def low_temp;  
  _parse(4).to_i 
end

def high_temp; 
  _parse(5).to_i 
end

def core_load; 
  _parse(6).to_i 
end   

def speed     
  _parse(7).to_i 
end 

def speed_pct cpu_speed
  ((speed().to_f / cpu_speed.to_f) * 100).to_f.round(0)
end

def processor
  $content.match(/Processor:,(.*)/).to_a.last
end

main()