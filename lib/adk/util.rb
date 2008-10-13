require "tempfile"

module Adk
  module Util
    # Use YAML to serialize and hash into and out of a string.
    def serialize_hash(hash)
      return hash.to_yaml
    end
    module_function :serialize_hash   
    
    # Takes in YAML or an array of "KEY=>VALUE" strings
    def deserialize_hash(data)
      return_value = Hash.new()
      if data.is_a?(String)
        return_value = YAML.load(data)
      elsif data.is_a?(Array)
        data.each() do |datum|
          data_items = datum.split("=>")
          return_value[data_items[0]]=data_items[1]
        end
      end
      return return_value
    end
    module_function :deserialize_hash       
    
    def clean_exec(cmd, dir='.', user=nil, group=nil)
        status = -1
        output = ""
        ouput_file_name="adk-#{Kernel.rand(10000)}.tmp"
        output_file = Tempfile.new(ouput_file_name)   
        output = nil      
        pid = Kernel.fork
        uid = Process.uid
        gid = Process.gid   
        if pid
            # parent                 
            status = Process.wait
        else
            # child            
            if user
                uid = user
                gid = group
                if (user.class == String)
                    uid = User::get_uid(user)
                    gid = User::get_gid(user) if ! gid
                end       
            end     
            STDOUT.reopen(output_file.path)
            STDERR.reopen(output_file.path) 
            Process.setsid  
            Process.uid = uid if uid    
            Process.gid = gid if gid
            Process.euid = uid if uid     
            Dir.chdir(dir) do                
              Kernel.exec(cmd)
            end
        end
        status = $?.exitstatus
        output = File.read(output_file.path)    
        return output, status
    end  
    module_function :clean_exec   
  end
end
