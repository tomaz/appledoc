platform :osx

def default_pods
    pod 'RegexKitLite', :git => 'https://github.com/inquisitiveSoft/RegexKitLite.git'
    #ParseKit '0.5' using latest RegexKitLite
    pod 'ParseKit', :podspec => 'parsekit.podspec.json'
end

target 'appledoc' do
    default_pods

    #target 'AppledocTests' do
    #    inherit! :search_paths
    #end
end

target 'AppledocTests' do
    default_pods
end
