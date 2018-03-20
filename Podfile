platform :osx

def default_pods
    pod 'RegexKitLite', :git => 'https://github.com/inquisitiveSoft/RegexKitLite.git'
    # ParseKit '0.0.0.2010.4.29' using latest RegexKitLite
    pod 'ParseKit', :podspec => 'Specs/ParseKit.podspec'
    # Discount '2.1.5a' with configure and make
    pod 'Discount', :podspec => 'Specs/Discount.podspec'
    pod 'GRMustache', '~> 7.0.2'
    pod 'Minizip/minishared', :git => 'https://github.com/nmoinvaz/minizip.git', :commit => 'c6d04f9c642a730a4d5a295b811ec884b4fe3ba2'
    pod 'DDMinizip', :podspec => 'Specs/DDMinizip.podspec'
end

def tests_pods
    pod 'GHUnit', '~> 0.5'
    pod 'OCMock', '~> 3.4'
end

target 'appledoc' do
    default_pods
end

target 'AppledocTests' do
    default_pods
    tests_pods
end
