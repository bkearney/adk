HOME="/home/bkearney/src/ace"
class Appliance
  
  @@cache = Hash.new() 
  attr_accessor :name, 
                :kickstart,
                :memory,
                :cpus
               
  def initialize(name, hash) 
    self.name = name
    self.memory = 256
    self.cpus = 1
    hash.each_pair do |key, value|
      mthd = "#{key}=".to_sym
      self.send(mthd, value)
    end
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

