Pod::Spec.new do |s|
  s.name     = 'DDMinizip'
  s.version  = '1.0.0.2017.06.25'
  s.license  = 'libz'
  s.summary  = "Based on code from acsolu@gmail.com, expanded and modified to work as a 'drop-in' static library for macOS and iOS"
  s.description = "Based on code from acsolu@gmail.com, expanded and modified to work as a 'drop-in' static library for macOS and iOS"

  s.homepage = 'https://github.com/Daij-Djan/DDMinizip'
  s.author = 'Dominik Pich'

  s.source   = { :git => 'https://github.com/Daij-Djan/DDMinizip.git' }
  s.source_files = 'src/*.{m,h}'
end
