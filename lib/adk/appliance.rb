HOME="/home/bkearney/src/ace"
class Appliance
  
  @@cache = Hash.new() 
  attr_accessor :name, 
                :kickstart
               
  def initialize(name, kickstart) 
    self.name = name
    self.kickstart = kickstart
  end
  
  
  def Appliance.get_appliance(name)
    return @@cache[name]
  end
  
  def Appliance.add_appliance(appl)
    @@cache[appl.name]= appl
  end
  
  def Appliance.all_appliances
    @@cache.values()
  end
end

Adk::Config.appliances.each do |key, value| 
  Appliance.add_appliance(Appliance.new(key,value))
end

