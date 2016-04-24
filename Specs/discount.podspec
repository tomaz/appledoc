Pod::Spec.new do |s|
  s.name     = 'Discount'
  s.version  = '2.1.5a'
  s.license  = 'BSD-style'
  s.summary  = 'C implementation of John Gruber\'s Markdown markup language'
  s.homepage = 'http://www.pell.portland.or.us/~orc/Code/discount'
  s.author   = { 'David Parsons' => 'orc@pell.portland.or.us' }
  s.source   = { :git => 'https://github.com/Orc/discount.git', :tag => 'v'+s.version.to_s }

  s.prepare_command = './configure.sh && make blocktags && rm *.in'
  s.source_files = 'amalloc.{h,c}', 'blocktags', 'config.h', 'Csio.c', 'cstring.h', 'emmatch.c', 'generate.c', 'markdown.{h,c}', 'mkdio.{h,c}', 'resource.c', 'setup.c', 'tags.{h,c}', 'xml.c'
  s.public_header_files = 'mkdio.h'
end
