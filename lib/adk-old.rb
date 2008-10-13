require "adk/appliance"
require "adk/util"
require 'rake'


OUTPUT_DIR="/home/bkearney/appliances"
LOG_DIR="/home/bkearney/appliances/logs"
CACHE = "/root/cache"
AWS_PRIVATE_KEY = "/home/bkearney/aws/pk-MDX35EJTNZGZ6CIGBZXHGZ5E36GVYU4M.pem"
AWS_CERT = "/home/bkearney/aws/cert-MDX35EJTNZGZ6CIGBZXHGZ5E36GVYU4M.pem"
AWS_KEY = "00F2CMD8BHZ8EN5KCAR2" 
AWS_SECRET_KEY = "YsAv0G5pNQDQjYCKdCWxCjwfEg/TdDxrax8azuDd"
AWS_ACCOUNT_NUMBER = "037935454564"

class ADK
  include Adk::Util
  
  def build_appliance(name)
    puts("building #{name}")
    appl = Appliance.get_appliance(name)
    run_command("appliance-creator --name #{appl.name} --config #{appl.kickstart} --cache #{CACHE}")
  end
  
  def ec2_bundle(name, bucket)
    puts("converting appliance #{name} to run on Amazons EC2")
    image_name = "" << name << "-sda.raw"
    output_name = "" << name << "-ec2"    
    puts("converting #{image_name} to #{output_name}")
    run_command("ec2-converter -f #{image_name} -n #{output_name} --inputtype diskimage")
    run_command("ec2-bundle-image -i #{output_name}.img -c #{AWS_CERT} -k #{AWS_KEY} -u #{AWS_ACCOUNT_NUMBER}  -r i386 -d .")   
  end
  
  def list_appliances
    Appliance.all_appliances().each() do |appl|
      puts("#{appl.name} (#{appl.kickstart})")
    end
  end
  
  
  def run_command(cmd)
    output, status = clean_exec(cmd, OUTPUT_DIR)
    puts (cmd)
    if (status != 0)
      puts ("FAIL!")
      puts(output)
    end
  end
end