desc "Run the Appledoc Tests"
task :test do
  ENV['GHUNIT_CLI'] = "1"
  if system("xctool -workspace appledoc.xcworkspace -scheme AppledocTests")
    puts "\033[0;32m** All tests executed successfully"
  else
    puts "\033[0;31m! Unit tests failed"
    exit(-1)
  end
end

task :default => 'test'