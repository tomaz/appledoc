platform :osx

dependency do |s|
	s.name     = 'ParseKit'
	s.version  = '0.0.2'
	s.license  = 'Apache'
	s.summary  = 'Objective-C/Cocoa String Tokenizer and Parser toolkit. Supports Grammars.'
	s.homepage = 'http://parsekit.com/'
	s.author   = { 'Todd Ditchendorf' => 'todd.ditchendorf@gmail.com' }
	s.source   = { :git => 'https://github.com/itod/parsekit.git', :commit => 'eed5f22' }
	s.source_files = 'include/**/*.{h,m}', 'src/**/*.{h,m}'
	s.clean_paths = "debugapp", "demoapp", "docs", "English.lproj", "frameworks", "info.plist", "jsdemoapp", "JSParseKit-Info.plist", "jssrc", "ParseKit_Prefix.pch", "ParseKitMobile_Prefix.pch", "res", "test", "*.xcodeproj"
	s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'TARGET_OS_SNOW_LEOPARD', 'WARNING_CFLAGS' => '-w' }
	s.framework = 'Foundation'
	s.library = 'icucore'
	s.requires_arc = false
end

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
	s.source   = { :git => 'https://github.com/tomaz/GBCli.git', :commit => '3fa1fde' }
	s.source_files = 'GBCli/src'
	s.clean_paths  = 'GBCli.xcodeproj', 'GBCli/GBCli-Prefix.pch', 'GBCli/GBSettings+Application.*', 'GBCli/main.*'
end

dependency do |s|
	s.name     = 'sundown'
	s.version  = '1.0'
	s.license  = 'MIT'
	s.summary  = 'Standards compliant, fast, secure markdown processing library in C.'
	s.homepage = 'https://github.com/vmg/sundown'
	s.author   = { 'Vicent Martí' => 'vicent@github.com' }
	s.source   = { :git => 'git://github.com/vmg/sundown.git', :commit => 'b6b58da' }
	s.source_files = 'src/*.[hc]', 'html/*.[hc]'
	s.clean_paths = 'examples', 'html_block_names.txt', 'Makefile', 'Makefile.*', '*.def'
end
	
target :AppledocTests do

	dependency do |s|
		s.name     = 'Cedar'
		s.version  = '0.0.3'
		s.license  = 'MIT'
		s.summary  = 'BDD-style testing using Objective-C.'
		s.homepage = 'https://github.com/pivotal/cedar'
		s.author   = { 'Pivotal Labs' => 'http://pivotallabs.com' }
		s.source   = { :git => 'git://github.com/pivotal/cedar.git', :commit => '71930ff' }
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
		s.source = { :git => 'https://github.com/erikdoe/ocmock.git', :commit => '50b43e4' }
		s.summary = 'OCMock is an Objective-C implementation of mock objects.'
		s.description = 'Mock objects for Objective-C'
		s.source_files = 'Source/OCMock/*.[mh]'
		s.clean_paths = 'Examples', 'Tools', 'Source/Frameworks', 'Source/OCMock.xcodeproj', 'Source/OCMockLib', 'Source/OCMockTests', 'Source/OCMock/en.lproj', 'Source/OCMock/OCMock-Info.plist'
		s.license = 'https://github.com/erikdoe/ocmock/blob/master/Source/License.txt'
	end

end
