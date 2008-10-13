require 'ostruct'
require 'yaml'  

module Adk 
  config = YAML.load_file(File.join(ENV["ADK_HOME"],'adk.yml'))

  Config = OpenStruct.new config
end

