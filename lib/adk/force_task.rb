require "rake"
class ForceTask < Rake::Task
  attr_accessor :force
  
  def timestamp
    if force()
      Time.now + 100000
    else
      Time.at(0)
    end
  end
end

def force_task(args, &block)
  ForceTask.define_task(args, &block)
end