platform :osx

dependency 'ParseKit'

dependency do |s|
	s.name     = 'DDCli'
	s.version  = '1.0'
	s.license  = ''
	s.summary  = 'A framework for building command line based Objective-C tools (utils only!).'
	s.homepage = 'http://www.dribin.org/dave/software/#ddcli'
	s.author   = { 'Dave Dribin' => 'dave@dribin.org' }
	s.source   = { :hg => 'http://www.dribin.org/dave/hg/ddcli' }
	s.source_files = 'lib'
	s.clean_paths  = 'ddcli_main.m', 'ddcli_Prefix.pch', 'ddcli.xcodeproj', 'doc', 'ExampleApp.*', 'SimpleApp.*', 'tools', 'versions.xcconfig', 'lib/DDCliApplication.*', 'lib/DDCliParseException.*', 'lib/DDCommandLineInterface.*', 'lib/DDGetoptLongParser.*'
end

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
