require 'ostruct'
require 'yaml'  

module Adk 
  config = YAML.load_file(File.join(ENV["ADK_HOME"],'adk.yml'))
  puts config

  Config = OpenStruct.new config
end

