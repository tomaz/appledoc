platform :osx

def default_pods
    pod 'RegexKitLite', :git => 'https://github.com/inquisitiveSoft/RegexKitLite.git'
    # ParseKit '0.0.0.2010.4.29' using latest RegexKitLite
    pod 'ParseKit', :podspec => 'Specs/ParseKit.podspec'
    # Discount '2.1.5a' with configure and make
    pod 'Discount', :podspec => 'Specs/Discount.podspec'
    pod 'GRMustache', '~> 7.0.2'
    # Minizip '1.1.0.2016.4.24'
    pod 'Minizip/Core', :podspec => 'Specs/Minizip.podspec'
end

def tests_pods
    pod 'GHUnit', '~> 0.5'
end

target 'appledoc' do
    default_pods
end

target 'AppledocTests' do
    default_pods
    tests_pods
end
