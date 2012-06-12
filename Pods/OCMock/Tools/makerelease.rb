   
class ReleaseManager

    def initialize
        @env = Environment.new()
        @worker = CompositeWorker.new([Logger.new(), Executer.new()])
    end              
    
    def makeAll
      createWorkingDirectories
      downloadSource
      buildModules
      createPackage "ocmock-2.0.1.dmg", "OCMock 2.0.1" 
      openPackageDir
    end
    
    def createWorkingDirectories
        @worker.run("mkdir -p #{@env.sourcedir}")
        @worker.run("mkdir -p #{@env.productdir}")
        @worker.run("mkdir -p #{@env.packagedir}")
    end
    
    def downloadSource
        @worker.run("git archive master | tar -x -v -C #{@env.sourcedir}")
        @worker.chdir(@env.sourcedir) 
        @worker.run("cp -R #{@env.sourcedir}/Source #{@env.productdir}")
    end

    def buildModules
        @worker.chdir("#{@env.sourcedir}/Source")
        @worker.run("xcodebuild -project OCMock.xcodeproj -target OCMock")         
        osxproductdir = "#{@env.productdir}/OSX"                                        
        @worker.run("mkdir -p #{osxproductdir}")
        @worker.run("cp -R build/Release/OCMock.framework #{osxproductdir}")    
        @worker.run("xcodebuild -project OCMock.xcodeproj -target OCMockLib -sdk iphoneos5.0")                                                 
        @worker.run("xcodebuild -project OCMock.xcodeproj -target OCMockLib -sdk iphonesimulator5.0")                                                 
        @worker.run("lipo -create -output build/Release/libOCMock.a build/Release-*/libOCMock.a")      
        iosproductdir = "#{@env.productdir}/iOS"                                           
        @worker.run("mkdir -p #{iosproductdir}")
        @worker.run("cp -R build/Release/libOCMock.a #{iosproductdir}")      
        @worker.run("cp -R build/Release-iphoneos/OCMock #{iosproductdir}")      
    end

    def createPackage(packagename, volumename)    
        @worker.chdir(@env.packagedir)  
        @worker.run("hdiutil create -size 4m temp.dmg -layout NONE") 
        disk_id = nil
        @worker.run("hdid -nomount temp.dmg") { |hdid| disk_id = hdid.readline.split[0] }
        @worker.run("newfs_hfs -v '#{volumename}' #{disk_id}")
        @worker.run("hdiutil eject #{disk_id}")
        @worker.run("hdid temp.dmg") { |hdid| disk_id = hdid.readline.split[0] }
        @worker.run("cp -R #{@env.productdir}/* '/Volumes/#{volumename}'")
        @worker.run("hdiutil eject #{disk_id}")
        @worker.run("hdiutil convert -format UDZO temp.dmg -o #{@env.packagedir}/#{packagename} -imagekey zlib-level=9")
        @worker.run("hdiutil internet-enable -yes #{@env.packagedir}/#{packagename}")
        @worker.run("rm temp.dmg")
    end           
    
    def openPackageDir
        @worker.run("open #{@env.packagedir}") 
    end
    
    def upload(packagename, dest)
        @worker.run("scp #{@env.packagedir}/#{packagename} #{dest}")
    end
    
    def cleanup
        @worker.run("chmod -R u+w #{@env.tmpdir}")
        @worker.run("rm -rf #{@env.tmpdir}");
    end
    
end


## Environment
## use attributes to configure manager for your environment

class Environment
    def initialize()
        @tmpdir = "/tmp/makerelease.#{Process.pid}"
        @sourcedir = tmpdir + "/Source"
        @productdir = tmpdir + "/Products"
        @packagedir = tmpdir
    end
    
    attr_accessor :tmpdir, :sourcedir, :productdir, :packagedir
end


## Logger (Worker)
## prints commands

class Logger
    def chdir(dir)
        puts "## chdir #{dir}"
    end
    
    def run(cmd)
        puts "## #{cmd}"
    end
end


## Executer (Worker)
## actually runs commands

class Executer
    def chdir(dir)
        Dir.chdir(dir)
    end

    def run(cmd, &block)     
        if block == nil
          system(cmd)
        else
          IO.popen(cmd, &block)
        end
    end
end


## Composite Worker (Worker)
## sends commands to multiple workers

class CompositeWorker
    def initialize(workers)
        @workers = workers
    end
    
    def chdir(dir)
        @workers.each { |w| w.chdir(dir) }
    end

    def run(cmd)
         @workers.each { |w| w.run(cmd) }
    end
 
    def run(cmd, &block)
         @workers.each { |w| w.run(cmd, &block) }
    end
end    


ReleaseManager.new.makeAll

