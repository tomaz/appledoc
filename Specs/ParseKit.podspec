Pod::Spec.new do |s|
  s.name     = 'ParseKit'
  s.version  = '0.0.0.2010.4.29'
  s.license  = 'Apache'
  s.summary  = 'Objective-C/Cocoa String Tokenizer and Parser toolkit. Supports Grammars.'
  s.description = <<-DESC
ParseKit is a Mac OS X Framework written by Todd Ditchendorf in Objective-C 2.0 and released under the Apache Open Source License Version 2.0. ParseKit is suitable for use on Mac OS X Leopard, Snow Leopard or iOS. ParseKit is an Objective-C implementation of the tools described in Building Parsers with Java by Steven John Metsker.

ParseKit includes additional features beyond the designs from the book and also some changes to match common Cocoa/Objective-C conventions. These changes are relatively superficial, however, and Metsker’s book is the best documentation available for ParseKit.
DESC
  s.homepage = 'http://parsekit.com/'
  s.author   = { 'Todd Ditchendorf' => 'todd.ditchendorf@gmail.com' }
  s.source   = { :git => 'https://github.com/itod/parsekit.git', :commit => '02aebf3d116dedad26b5d2e9de8b3ee16df5ef79' }

  s.source_files = 'include/**/*.{h,m}', 'src/**/*.{h,m}'
  s.exclude_files = 'src/RegexKitLite.{h,m}'
  s.libraries = 'icucore'
  s.requires_arc = false
  s.dependency 'RegexKitLite', '~> 4.0.1'

  s.ios.prefix_header_file = 'ParseKitMobile_Prefix.pch'
  s.ios.frameworks = 'Foundation', 'CoreGraphics'

  s.osx.prefix_header_file = 'ParseKit_Prefix.pch'
  s.osx.frameworks = 'Foundation'
end
