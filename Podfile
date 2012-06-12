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
	dependency do |s|
		s.name     = 'Cedar'
		s.version  = '0.0.2'
		s.license  = 'MIT'
		s.summary  = 'BDD-style testing using Objective-C.'
		s.homepage = 'https://github.com/pivotal/cedar'
		s.author   = { 'Pivotal Labs' => 'http://pivotallabs.com' }
		s.source   = { :git => 'git://github.com/pivotal/cedar.git' }
		files = FileList['Source/**/*.{h,m}']
		files.exclude(/iPhone/)
		s.source_files = files 
		s.clean_paths = FileList['*'].exclude(/(Source|README.markdown|MIT.LICENSE)$/)
		s.library = 'stdc++'
	end
	
	dependency do |s|
		s.name = 'OCMock'
		s.version = '2.0.2'
		s.homepage = 'http://ocmock.org'
		s.author = { 'Erik Doernenburg' => 'erik@doernenburg.com' }
		s.source = { :git => 'https://github.com/erikdoe/ocmock.git' }
		s.summary = 'OCMock is an Objective-C implementation of mock objects.'
		s.description = 'Mock objects for Objective-C'
		s.source_files = 'Source/OCMock/*.[mh]'
		s.license = 'https://github.com/erikdoe/ocmock/blob/master/Source/License.txt'
	end
end
