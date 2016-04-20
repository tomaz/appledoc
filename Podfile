platform :osx

def default_pods
    pod 'RegexKitLite', :git => 'https://github.com/inquisitiveSoft/RegexKitLite.git'
    #ParseKit '0.0.0.2010.4.29' using latest RegexKitLite
    pod 'ParseKit', :podspec => 'parsekit.podspec.json'
    pod 'GRMustache', '~> 7.0.2'
end

target 'appledoc' do
    default_pods
end

target 'AppledocTests' do
    default_pods
end
