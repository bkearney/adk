require "rubygems"
gem 'rake', '>= 0.7.3'
require "rake"
require "adk/config"
require "adk/appliance"
require "adk/util"
require "adk/force_task"

class ADK
  include Adk::Util
  
  attr_accessor :trace, :verbose
  
  def initialize(force = false)
    Rake.application.init('adk')
    Rake.application.top_level_tasks.clear()  
    add_common_tasks(force)
    @verbose = false
    @trace = true
  end
  
  def verbose(value)
    Rake.application.do_option("--verbose", true) if value
    @verbose = value
  end
  
  def trace(value)
    Rake.application.do_option("--trace", true) if value
    @verbose = true if value
    @trace = value
  end  
    
  def build_appliance(name)
    appl = get_appliance(name)    
    puts("building #{name}")
    add_build_tasks(appl)         
    Rake.application.top_level()      
  end
  
  def ec2_bundle(name, bucket)
    appl = get_appliance(name)        
    puts("converting appliance #{name} to run on Amazons EC2")
    add_build_tasks(appl)
    add_ec2_tasks(appl, bucket)
    Rake.application.top_level()   
  end
  
  def vmx_convert(name)
    appl = get_appliance(name)        
    puts("converting appliance #{name} to vmx")
    add_build_tasks(appl)
    add_vmx_tasks(appl)
    Rake.application.top_level()   
  end  
  
  def list_appliances
    Appliance.all_appliances().each() do |appl|
      puts("#{appl.name}=> ram:#{appl.memory}, cpus: #{appl.cpus}, ks:#{appl.kickstart} ")
    end
  end
  
  def run_command(cmd, directory=Adk::Config.output_directory)
    puts (cmd)    
    output, status = clean_exec(cmd, directory)
    if (status != 0)
      puts ("FAIL!")
      puts(output)
    end   
  end
  
  # Rake file creation
  
  def add_common_tasks(force)
    directory Adk::Config.output_directory
    directory Adk::Config.log_directory  
    force_task :force do |task|
      task.force=force
    end    
  end
  
  def add_build_tasks(appl) 
    file virt_metadata_path(appl) => [kickstart_path(appl), :force, Adk::Config.output_directory] do |task|
      kickstart_location = File.dirname(appl.kickstart)
      run_command("appliance-creator --name #{appl.name} --config #{appl.kickstart} --vmem #{appl.memory} --vcpu #{appl.cpus} --cache #{Adk::Config.cache_directory}")
    end    
    task :build => virt_metadata_path(appl) 
    Rake.application.top_level_tasks << :build 
  end
  
  def add_ec2_tasks(appl, bucket)
    file ec2_image_path(appl) => [virt_metadata_path(appl), :force] do |task|
      run_command("ec2-converter -f #{virt_image_path(appl)} -n #{ec2_image_path_short(appl)} --inputtype diskimage")
    end
    file ec2_manifest_path(appl) => [ec2_image_path(appl), :force] do |task|
      run_command("ec2-bundle-image -i #{ec2_image_path(appl)} -c #{Adk::Config.aws_cert} -k #{Adk::Config.aws_private_key} -u #{Adk::Config.aws_account_number}  -r i386 -d .")
    end
    task "upload_#{appl.name}".to_sym => [ec2_manifest_path(appl)] do |task|
      run_command("ec2-upload-bundle --retry -m #{ec2_manifest_path(appl)} -b #{bucket} -a #{Adk::Config.aws_key} -s #{Adk::Config.aws_secret_key}")
    end    
    task :ec2_bundle =>  "upload_#{appl.name}".to_sym 
    Rake.application.top_level_tasks << :ec2_bundle   
  end  
  
  def add_vmx_tasks(appl)
    file vmx_path(appl) => [virt_metadata_path(appl), :force] do |task|
      run_command("virt-convert -i virt-image -o vmx #{virt_metadata_path(appl)} #{vmx_path(appl)}")
    end
    task :vmx =>  vmx_path(appl)
    Rake.application.top_level_tasks << :vmx   
  end    
  
  #convenience functions
  def get_appliance(name)
    appl = Appliance.get_appliance(name)
    if appl.nil?
      puts("No Appliance named #{name}")
     exit(1)
    end
    appl
  end  
  
  def kickstart_path(appl)
    appl.kickstart()
  end
  
  def virt_name(appl)
    File.join(Adk::Config.output_directory, "#{appl.name}")
  end
    
  def virt_metadata_path(appl) 
    File.join(Adk::Config.output_directory, "#{appl.name}.xml")
  end
  
  def virt_image_path(appl)
    File.join(Adk::Config.output_directory, "#{appl.name}-sda.raw")    
  end
  
  def ec2_image_path_short(appl) 
    File.join(Adk::Config.output_directory, "#{appl.name}-ec2")
  end 
  
  def ec2_image_path(appl) 
    ec2_image_path_short(appl)+".img"
  end 
  
  def ec2_manifest_path(appl)
    "#{ec2_image_path(appl) }.manifest.xml"    
  end
  
  def vmx_path(appl)
    File.join(Adk::Config.output_directory, "#{appl.name}.vmx")
  end
end