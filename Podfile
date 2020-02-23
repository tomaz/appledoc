platform :osx

def default_pods
    pod 'RegexKitLite', :git => 'https://github.com/inquisitiveSoft/RegexKitLite.git'
    # ParseKit '0.0.0.2010.4.29' using latest RegexKitLite
    pod 'ParseKit', :podspec => 'Specs/ParseKit.podspec'
    # Discount '2.1.5a' with configure and make
    pod 'Discount', :podspec => 'Specs/Discount.podspec'
    pod 'GRMustache', '~> 7.0.2'
    pod 'CocoaLumberjack'
end

target 'appledoc' do
    default_pods
end

target 'appledocTests' do
    default_pods
    pod 'OCMock', '~> 3.4'
end
