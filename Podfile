platform :osx

dependency 'ParseKit'

dependency do |s|
  s.name     = 'GBCli'
  s.version  = '1.0'
  s.license  = ''
  s.summary  = 'Objective C foundation tool command line interface library.'
  s.homepage = 'https://gentlebytes.com/appledoc'
  s.author   = { 'Tomaz Kragelj' => 'tkragelj@gmail.com' }
  s.source   = { :git => 'https://github.com/tomaz/GBCli.git' }
  s.source_files = 'GBCli/src'
  s.clean_paths  = 'GBCli.xcodeproj', 'GBCli/GBCli-Prefix.pch', 'GBCli/GBSettings+Application.*', 'GBCli/main.*'
end

target :AppledocTests do
	dependency 'Cedar'
	dependency 'OCMock'
end
