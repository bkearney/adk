require 'rake/clean'
require 'fileutils'

task :setup do |task|
  rm_rf("deps")
  mkdir("deps")
  Dir.chdir("deps") do 
    system("git clone git://git.et.redhat.com/ace")
    system("git clone git://git.et.redhat.com/act")
    system("git clone git://git.fedorahosted.org/hosted/livecd")    
    system("hg clone http://hg.et.redhat.com/virt/applications/virtinst--devel")
    system("git clone git://git.fedorahosted.org/cobbler --depth 2")
    Dir.chdir("cobbler") do
        system("git branch --track  devel origin/devel")
	system("git checkout devel")
    end
  end
end
